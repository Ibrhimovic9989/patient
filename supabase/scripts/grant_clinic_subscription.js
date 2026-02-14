/**
 * Grant Clinic Subscription Script
 * 
 * This script is used by the SaaS owner to grant subscriptions to clinics.
 * Run this script manually via Node.js or Supabase SQL Editor.
 * 
 * Usage:
 *   node grant_clinic_subscription.js <clinic_id> <tier> <months>
 * 
 * Example:
 *   node grant_clinic_subscription.js "uuid-here" "premium" 12
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '../.env' });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY; // Use service role key for admin operations

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function grantSubscription(clinicId, tier, months, grantedBy) {
  try {
    // Validate tier
    const validTiers = ['basic', 'premium', 'enterprise'];
    if (!validTiers.includes(tier)) {
      throw new Error(`Invalid tier. Must be one of: ${validTiers.join(', ')}`);
    }

    // Calculate dates
    const startsAt = new Date();
    const expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + months);

    // Check if clinic exists
    const { data: clinic, error: clinicError } = await supabase
      .from('clinic')
      .select('id, name')
      .eq('id', clinicId)
      .single();

    if (clinicError || !clinic) {
      throw new Error(`Clinic not found: ${clinicId}`);
    }

    // Deactivate any existing active subscriptions
    await supabase
      .from('clinic_subscription')
      .update({ status: 'cancelled' })
      .eq('clinic_id', clinicId)
      .eq('status', 'active');

    // Create new subscription
    const { data, error } = await supabase
      .from('clinic_subscription')
      .insert({
        clinic_id: clinicId,
        subscription_tier: tier,
        status: 'active',
        starts_at: startsAt.toISOString(),
        expires_at: expiresAt.toISOString(),
        granted_by: grantedBy || null,
      })
      .select()
      .single();

    if (error) {
      throw error;
    }

    console.log('✅ Subscription granted successfully!');
    console.log(`Clinic: ${clinic.name}`);
    console.log(`Tier: ${tier}`);
    console.log(`Duration: ${months} months`);
    console.log(`Starts: ${startsAt.toISOString()}`);
    console.log(`Expires: ${expiresAt.toISOString()}`);
    console.log(`Subscription ID: ${data.id}`);

    return data;
  } catch (error) {
    console.error('❌ Error granting subscription:', error.message);
    throw error;
  }
}

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 3) {
    console.log('Usage: node grant_clinic_subscription.js <clinic_id> <tier> <months> [granted_by_user_id]');
    console.log('');
    console.log('Example:');
    console.log('  node grant_clinic_subscription.js "550e8400-e29b-41d4-a716-446655440000" "premium" 12');
    process.exit(1);
  }

  const [clinicId, tier, monthsStr, grantedBy] = args;
  const months = parseInt(monthsStr, 10);

  if (isNaN(months) || months <= 0) {
    console.error('Error: months must be a positive number');
    process.exit(1);
  }

  grantSubscription(clinicId, tier, months, grantedBy)
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { grantSubscription };
