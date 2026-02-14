# Fix Missing Database Tables

## The Problem

The therapist app is trying to query tables that don't exist:
- `profession` table (404 error)
- `profession_details` table (404 error)

## The Solution

**Run the SQL script to create the missing tables:**

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Copy and paste the contents of `supabase/schemas/profession_tables.sql`
3. Click **Run** to execute the script

This will:
- ✅ Create `profession` table
- ✅ Create `profession_details` table
- ✅ Insert default profession data (Neuropsychologist, Neurologist, etc.)
- ✅ Insert sample regulatory bodies, specializations, and therapies
- ✅ Create indexes for better performance

## After Running the Script

1. **Refresh your therapist app** (or restart it)
2. The errors should be gone
3. The profession dropdown should work
4. You should be able to select regulatory bodies, specializations, and therapies

## Note

The script uses `ON CONFLICT DO NOTHING` so it's safe to run multiple times. If you need to add more professions or details, you can modify the INSERT statements in the script.
