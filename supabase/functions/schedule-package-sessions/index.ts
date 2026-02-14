import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-supabase-auth-token',
  'Access-Control-Expose-Headers': 'x-supabase-auth-token',
};

Deno.serve(async (req) => {
  // CRITICAL: Log immediately to verify function is being called
  console.log('🚀 FUNCTION CALLED AT:', new Date().toISOString());
  console.log('Method:', req.method);
  console.log('URL:', req.url);
  console.log('Headers count:', Array.from(req.headers.keys()).length);
  
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    console.log('OPTIONS request - returning CORS headers');
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  try {
    console.log('=== PROCESSING REQUEST ===');
    
    // Log all headers
    const headers: Record<string, string> = {};
    req.headers.forEach((value, key) => {
      headers[key] = key.toLowerCase() === 'authorization' ? 'Bearer ***REDACTED***' : value;
    });
    console.log('Request headers:', JSON.stringify(headers, null, 2));
    
    // Check for Authorization header
    const authHeader = req.headers.get('Authorization');
    console.log('Authorization header present:', !!authHeader);
    console.log('Authorization header starts with Bearer:', authHeader?.startsWith('Bearer ') ?? false);
    
    // Create Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    
    console.log('Environment check:');
    console.log('  SUPABASE_URL present:', !!supabaseUrl);
    console.log('  SUPABASE_SERVICE_ROLE_KEY present:', !!supabaseServiceKey);
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ Missing environment variables');
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }
    
    console.log('Creating Supabase client...');
    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    console.log('✅ Supabase client created');

    // Parse request body
    console.log('Parsing request body...');
    let requestBody;
    try {
      requestBody = await req.json();
      console.log('Request body:', JSON.stringify(requestBody));
    } catch (e) {
      console.error('❌ Error parsing request body:', e);
      return new Response(
        JSON.stringify({ error: 'Invalid request body', details: e.message }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }
    
    const { patient_package_id } = requestBody;
    console.log('patient_package_id:', patient_package_id);

    if (!patient_package_id) {
      console.error('❌ Missing patient_package_id');
      return new Response(
        JSON.stringify({ error: 'patient_package_id is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }
    
    console.log('✅ patient_package_id validated:', patient_package_id);

    // Fetch patient package details
    const { data: patientPackage, error: packageError } = await supabase
      .from('patient_package')
      .select(`
        *,
        package:package_id(
          id,
          name
        ),
        patient:patient_id(
          id,
          therapist_id,
          clinic_id
        )
      `)
      .eq('id', patient_package_id)
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

    const patient = patientPackage.patient as any;
    
    // Check if patient has any therapist assignments for this package
    // (We now use patient_therapist_assignment table instead of patient.therapist_id)
    const { data: assignments, error: assignmentsError } = await supabase
      .from('patient_therapist_assignment')
      .select('therapy_type_id')
      .eq('patient_id', patient.id)
      .eq('patient_package_id', patient_package_id)
      .eq('is_active', true);
    
    if (assignmentsError) {
      console.error('❌ Error checking therapist assignments:', assignmentsError);
      return new Response(
        JSON.stringify({ error: 'Error checking therapist assignments', details: assignmentsError.message }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }
    
    if (!assignments || assignments.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Patient does not have any therapists assigned for this package. Please assign therapists first.' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }
    
    console.log(`✅ Found ${assignments.length} therapist assignment(s) for this package`);

    // Fetch schedule configurations
    console.log('Fetching schedule configs for patient_package_id:', patient_package_id);
    
    // First, try a simple query without joins to see if records exist
    const { data: simpleConfigs, error: simpleError } = await supabase
      .from('package_schedule_config')
      .select('id, patient_package_id, therapy_type_id, days_of_week, time_slot')
      .eq('patient_package_id', patient_package_id);
    
    console.log('Simple query result:');
    console.log('  Error:', simpleError);
    console.log('  Count:', simpleConfigs?.length ?? 0);
    console.log('  Data:', JSON.stringify(simpleConfigs, null, 2));
    
    // Now try with joins
    const { data: scheduleConfigs, error: configError } = await supabase
      .from('package_schedule_config')
      .select(`
        *,
        therapy:therapy_type_id(
          id,
          name
        )
      `)
      .eq('patient_package_id', patient_package_id);

    console.log('Schedule configs query result (with joins):');
    console.log('  Error:', configError);
    console.log('  Count:', scheduleConfigs?.length ?? 0);
    console.log('  Configs:', JSON.stringify(scheduleConfigs, null, 2));

    // Use simple query result if joined query fails or returns empty
    let finalConfigs = scheduleConfigs;
    if (configError || !scheduleConfigs || scheduleConfigs.length === 0) {
      console.log('⚠️ Joined query failed or empty, using simple query result');
      if (simpleError) {
        console.error('❌ Simple query also failed:', simpleError);
        return new Response(
          JSON.stringify({ 
            error: 'Failed to fetch schedule configurations',
            details: simpleError.message 
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        );
      }
      
      if (!simpleConfigs || simpleConfigs.length === 0) {
        console.error('❌ No schedule configurations found for patient_package_id:', patient_package_id);
        // Check if any configs exist at all
        const { data: allConfigs } = await supabase
          .from('package_schedule_config')
          .select('id, patient_package_id')
          .limit(5);
        console.log('Sample of all configs in table:', allConfigs);
        
        return new Response(
          JSON.stringify({ 
            error: 'No schedule configurations found',
            details: `No schedule configurations found for patient_package_id: ${patient_package_id}. Please ensure you have saved the schedule configuration before generating sessions.`
          }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        );
      }
      
      // Use simple configs and fetch therapy names separately
      console.log('Using simple configs, fetching therapy names separately');
      finalConfigs = simpleConfigs;
      
      // Fetch therapy names for each config
      for (const config of finalConfigs) {
        const { data: therapy } = await supabase
          .from('therapy')
          .select('id, name')
          .eq('id', config.therapy_type_id)
          .single();
        config.therapy = therapy;
      }
    }
    
    console.log('✅ Found', finalConfigs.length, 'schedule configurations');

    // Fetch package therapy details for session duration
    const { data: therapyDetails, error: detailsError } = await supabase
      .from('package_therapy_details')
      .select('therapy_type_id, session_duration_minutes')
      .eq('package_id', patientPackage.package_id);

    if (detailsError) {
      return new Response(
        JSON.stringify({ error: 'Failed to fetch therapy details' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Create a map of therapy_type_id -> session_duration_minutes
    const durationMap = new Map<string, number>();
    for (const detail of therapyDetails || []) {
      durationMap.set(detail.therapy_type_id, detail.session_duration_minutes || 60);
    }

    const startsAt = new Date(patientPackage.starts_at);
    const expiresAt = patientPackage.expires_at ? new Date(patientPackage.expires_at) : null;
    if (!expiresAt) {
      return new Response(
        JSON.stringify({ error: 'Package expiration date not set' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    const sessionsToCreate: any[] = [];
    let totalSessionsCreated = 0;

    // Process each schedule configuration
    for (const config of finalConfigs) {
      const therapyTypeId = config.therapy_type_id;
      const daysOfWeek = config.days_of_week as number[];
      const timeSlot = config.time_slot as string; // Format: "HH:MM:SS"
      const duration = durationMap.get(therapyTypeId) || 60;

      // Get assigned therapist for this therapy type
      const { data: assignment, error: assignmentError } = await supabase
        .from('patient_therapist_assignment')
        .select('therapist_id')
        .eq('patient_id', patient.id)
        .eq('therapy_type_id', therapyTypeId)
        .eq('patient_package_id', patient_package_id)
        .eq('is_active', true)
        .maybeSingle();

      if (assignmentError) {
        console.error(`❌ Error fetching assignment for therapy ${therapyTypeId}:`, assignmentError);
        continue;
      }

      if (!assignment) {
        console.warn(`⚠️ No therapist assigned for therapy type ${therapyTypeId}, skipping sessions`);
        continue;
      }

      const assignedTherapistId = assignment.therapist_id;

      // Parse time slot
      const [hours, minutes] = timeSlot.split(':').map(Number);

      // Generate all session dates
      const currentDate = new Date(startsAt);
      while (currentDate <= expiresAt) {
        const dayOfWeek = currentDate.getDay(); // 0=Sunday, 1=Monday, etc.

        if (daysOfWeek.includes(dayOfWeek)) {
          // Create session timestamp
          const sessionDate = new Date(currentDate);
          sessionDate.setHours(hours, minutes, 0, 0);

          // Check if session already exists
          const { data: existingSession } = await supabase
            .from('session')
            .select('id')
            .eq('patient_id', patient.id)
            .eq('therapist_id', assignedTherapistId)
            .eq('timestamp', sessionDate.toISOString())
            .maybeSingle();

          if (!existingSession) {
            sessionsToCreate.push({
              patient_id: patient.id,
              therapist_id: assignedTherapistId, // Use assigned therapist, not patient.therapist_id
              clinic_id: patient.clinic_id,
              package_id: patientPackage.package_id,
              therapy_type_id: therapyTypeId,
              patient_package_id: patient_package_id,
              timestamp: sessionDate.toISOString(),
              duration: duration,
              status: 'pending',
              is_consultation: false,
              mode: 1, // Default to in-person
            });
          }
        }

        // Move to next day
        currentDate.setDate(currentDate.getDate() + 1);
      }
    }

    // Batch insert sessions (Supabase allows up to 1000 rows per insert)
    const batchSize = 500;
    for (let i = 0; i < sessionsToCreate.length; i += batchSize) {
      const batch = sessionsToCreate.slice(i, i + batchSize);
      const { error: insertError } = await supabase
        .from('session')
        .insert(batch);

      if (insertError) {
        console.error('Error inserting sessions batch:', insertError);
        // Continue with next batch even if one fails
      } else {
        totalSessionsCreated += batch.length;
      }
    }

    console.log('✅ SUCCESS: Created', totalSessionsCreated, 'sessions');
    
    return new Response(
      JSON.stringify({
        success: true,
        sessions_created: totalSessionsCreated,
        message: `Successfully created ${totalSessionsCreated} sessions`,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('❌ UNHANDLED ERROR in schedule-package-sessions:');
    console.error('Error type:', error?.constructor?.name);
    console.error('Error message:', error?.message);
    console.error('Error stack:', error?.stack);
    console.error('Full error:', JSON.stringify(error, Object.getOwnPropertyNames(error)));
    
    return new Response(
      JSON.stringify({ 
        error: error?.message || 'Internal server error',
        type: error?.constructor?.name,
        details: error?.stack
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
