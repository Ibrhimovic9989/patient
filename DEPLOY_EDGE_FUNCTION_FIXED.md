# Deploy Edge Function - Fixed Import Issue

## The Problem

When deploying via Supabase Dashboard, the import `@supabase/supabase-js` fails because Deno needs explicit JSR/npm package specification.

## The Fix

The import has been updated to use JSR format directly:
```typescript
import { createClient } from "jsr:@supabase/supabase-js@2";
```

## How to Deploy

### Option 1: Using Supabase Dashboard (Easiest)

1. **Go to Supabase Dashboard** → **Edge Functions**
2. **Click "Create a new function"** or edit existing `evaluate-assessments`
3. **Copy the ENTIRE contents** of:
   - `supabase/functions/evaluate-assessments/index.ts`
   - `supabase/functions/evaluate-assessments/dto/types.ts` (if deploying separately)
4. **Paste into the editor**
5. **Click "Deploy"**

### Option 2: Using Supabase CLI (Recommended for Production)

1. **Install Supabase CLI:**
   ```powershell
   scoop install supabase
   ```

2. **Login:**
   ```powershell
   supabase login
   ```

3. **Link your project:**
   ```powershell
   cd C:\Users\camun\Documents\pts\NeuroTrack
   supabase link --project-ref ouzgddcxfynjhwjnvdtb
   ```
   (Replace with your actual project ref if different)

4. **Deploy:**
   ```powershell
   supabase functions deploy evaluate-assessments
   ```

## Verify Deployment

1. Go to **Supabase Dashboard** → **Edge Functions** → `evaluate-assessments`
2. Click **"Invoke function"**
3. Test with this payload:
   ```json
   {
     "patient_id": "00000000-0000-0000-0000-000000000000",
     "assessment_id": "your-assessment-id-here",
     "questions": [
       {
         "question_id": "aq10_q1",
         "answer_id": "aq10_q1_o1"
       }
     ]
   }
   ```

## What Changed

- ✅ Import changed from `@supabase/supabase-js` to `jsr:@supabase/supabase-js@2`
- ✅ This works with Deno runtime used by Supabase Edge Functions
- ✅ No need for `deno.json` when deploying via Dashboard

## Troubleshooting

- **"Failed to bundle"** → Make sure you copied the entire `index.ts` file with the fixed import
- **"Module not found"** → The JSR import should work automatically with Supabase's Deno runtime
- **"500 Error"** → Check Edge Function logs in Dashboard for detailed error messages
