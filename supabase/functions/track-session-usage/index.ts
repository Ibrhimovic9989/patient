import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  try {
    // Get authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // Parse request body
    const { session_id } = await req.json();

    if (!session_id) {
      return new Response(
        JSON.stringify({ error: 'session_id is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Fetch session details
    const { data: session, error: sessionError } = await supabase
      .from('session')
      .select('patient_package_id, therapy_type_id, status')
      .eq('id', session_id)
      .single();

    if (sessionError || !session) {
      return new Response(
        JSON.stringify({ error: 'Session not found' }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Only track if session is accepted or completed
    if (session.status !== 'accepted' && session.status !== 'completed') {
      return new Response(
        JSON.stringify({ message: 'Session status does not require tracking' }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Only track if session is linked to a package
    if (!session.patient_package_id || !session.therapy_type_id) {
      return new Response(
        JSON.stringify({ message: 'Session is not linked to a package' }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Fetch current patient package
    const { data: patientPackage, error: packageError } = await supabase
      .from('patient_package')
      .select('sessions_used')
      .eq('id', session.patient_package_id)
      .single();

    if (packageError || !patientPackage) {
      return new Response(
        JSON.stringify({ error: 'Patient package not found' }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Update sessions_used JSONB
    const sessionsUsed = (patientPackage.sessions_used as Record<string, number>) || {};
    const therapyTypeId = session.therapy_type_id as string;
    const currentCount = sessionsUsed[therapyTypeId] || 0;
    sessionsUsed[therapyTypeId] = currentCount + 1;

    // Update patient package
    const { error: updateError } = await supabase
      .from('patient_package')
      .update({ sessions_used: sessionsUsed })
      .eq('id', session.patient_package_id);

    if (updateError) {
      return new Response(
        JSON.stringify({ error: 'Failed to update session usage' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Check if package limits are reached (optional - can be enhanced)
    // Fetch package therapy details to check session counts
    const { data: packageData } = await supabase
      .from('patient_package')
      .select(`
        package_id,
        package:package_id(
          package_therapy_details(
            therapy_type_id,
            session_count
          )
        )
      `)
      .eq('id', session.patient_package_id)
      .single();

    let limitReached = false;
    let sessionCount = 'N/A';
    if (packageData?.package?.package_therapy_details) {
      const therapyDetails = packageData.package.package_therapy_details as any[];
      const detail = therapyDetails.find((d: any) => d.therapy_type_id === therapyTypeId);
      if (detail) {
        sessionCount = detail.session_count.toString();
        if (sessionsUsed[therapyTypeId] >= detail.session_count) {
          limitReached = true;
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        sessions_used: sessionsUsed,
        limit_reached: limitReached,
        message: `Session usage updated. ${sessionsUsed[therapyTypeId]}/${sessionCount} sessions used for this therapy type.`,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Error in track-session-usage:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
