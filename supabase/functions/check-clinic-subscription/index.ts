import { createClient } from "jsr:@supabase/supabase-js@2";

const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!);

/**
 * Edge Function to check clinic subscription status
 * 
 * This function verifies if a clinic has an active subscription.
 * Can be called before critical operations to ensure clinic has access.
 * 
 * @param clinic_id - The clinic ID to check
 * @returns Subscription status and details
 */

Deno.serve(async (req) => {
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Max-Age': '3600',
  };

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  try {
    const { clinic_id } = await req.json();

    if (!clinic_id) {
      return new Response(
        JSON.stringify({ error: 'clinic_id is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Check for active subscription
    const { data, error } = await supabase
      .from('clinic_subscription')
      .select('*')
      .eq('clinic_id', clinic_id)
      .eq('status', 'active')
      .order('expires_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      return new Response(
        JSON.stringify({ error: 'Database error', details: error.message }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (!data) {
      return new Response(
        JSON.stringify({
          has_active_subscription: false,
          message: 'No active subscription found',
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Check if subscription is expired
    const expiresAt = new Date(data.expires_at);
    const now = new Date();
    const isExpired = expiresAt < now;

    if (isExpired) {
      // Update status to expired
      await supabase
        .from('clinic_subscription')
        .update({ status: 'expired' })
        .eq('id', data.id);

      return new Response(
        JSON.stringify({
          has_active_subscription: false,
          message: 'Subscription has expired',
          subscription: {
            tier: data.subscription_tier,
            expires_at: data.expires_at,
          },
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Subscription is active
    return new Response(
      JSON.stringify({
        has_active_subscription: true,
        subscription: {
          id: data.id,
          tier: data.subscription_tier,
          starts_at: data.starts_at,
          expires_at: data.expires_at,
          days_remaining: Math.ceil((expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)),
        },
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
