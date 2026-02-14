# Deploy Edge Function for Assessments

## Why You Need This

The patient app uses an edge function called `evaluate-assessments` to:
- Calculate assessment scores
- Determine if a patient is likely autistic (based on cutoff score)
- Store assessment results

**Without deploying this function, assessment submissions will fail!**

## How to Deploy

### Option 1: Using Supabase CLI (Recommended)

1. **Install Supabase CLI** (if not already installed):
   ```powershell
   scoop install supabase
   ```
   OR download from: https://github.com/supabase/cli/releases

2. **Login to Supabase:**
   ```powershell
   supabase login
   ```
   This will open a browser to authenticate.

3. **Link your project:**
   ```powershell
   cd C:\Users\camun\Documents\pts\NeuroTrack
   supabase link --project-ref YOUR_PROJECT_REF
   ```
   You can find your project ref in Supabase Dashboard → Settings → General → Reference ID

4. **Deploy the function:**
   ```powershell
   supabase functions deploy evaluate-assessments
   ```

### Option 2: Using Supabase Dashboard

1. Go to **Supabase Dashboard** → **Edge Functions**
2. Click **Create a new function**
3. Name it: `evaluate-assessments`
4. Copy the contents of `supabase/functions/evaluate-assessments/index.ts`
5. Paste into the editor
6. Also copy `supabase/functions/evaluate-assessments/dto/types.ts` if needed
7. Click **Deploy**

### Option 3: Manual Upload (Alternative)

If CLI doesn't work, you can:
1. Zip the `supabase/functions/evaluate-assessments` folder
2. Upload via Supabase Dashboard → Edge Functions → Deploy

## Verify Deployment

After deploying, test it:

1. Go to **Supabase Dashboard** → **Edge Functions** → `evaluate-assessments`
2. Click **Invoke function**
3. Use this test payload:
   ```json
   {
     "patient_id": "test-id",
     "assessment_id": "some-assessment-id",
     "questions": [
       {
         "question_id": "q1",
         "answer_id": "a1"
       }
     ]
   }
   ```

## What the Function Does

The `evaluate-assessments` function:
1. Receives assessment answers from the patient app
2. Fetches the assessment template from the database
3. Calculates the total score based on answer scores
4. Compares score with cutoff to determine if patient is likely autistic
5. Returns the result to be stored in `assessment_results` table

## Troubleshooting

- **"Function not found"** → Make sure you deployed it with the exact name `evaluate-assessments`
- **"401 Unauthorized"** → Check that your `.env` has the correct `SUPABASE_ANON_KEY`
- **"500 Internal Server Error"** → Check Supabase Edge Function logs in Dashboard
- **"CORS error"** → Make sure you redeployed the function after CORS header changes. The function includes CORS headers, but they only take effect after redeployment.

## After Deployment

Once deployed:
1. ✅ Patient app can submit assessments
2. ✅ Scores are calculated correctly
3. ✅ Results are stored in database
4. ✅ Assessment flow works end-to-end
