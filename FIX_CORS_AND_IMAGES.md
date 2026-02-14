# Fix CORS Error & Image URLs

## Issue 1: CORS Error

The edge function needs CORS headers to allow requests from `http://localhost:50001`.

**✅ Fixed!** The edge function now includes CORS headers.

### Deploy the Updated Function

1. **Go to Supabase Dashboard** → **Edge Functions** → `evaluate-assessments`
2. **Copy the entire contents** of `supabase/functions/evaluate-assessments/index.ts`
3. **Paste into the editor** (replace existing code)
4. **Click "Deploy"**

The function now:
- ✅ Handles OPTIONS preflight requests
- ✅ Returns CORS headers on all responses
- ✅ Allows requests from any origin (for development)

## Issue 2: Wrong Image URLs

The assessments table still has old image URLs pointing to the wrong Supabase project.

### Fix Image URLs

1. **Go to Supabase Dashboard** → **SQL Editor**
2. **Run this SQL:**
   ```sql
   UPDATE assessments 
   SET image_url = NULL 
   WHERE image_url LIKE '%gezbvdcskabwweanvfhu%' 
      OR image_url LIKE '%ouzgddcxfynjhwjnvdtb%';
   ```

   Or copy from: `supabase/schemas/fix_assessment_images.sql`

3. **Verify:**
   ```sql
   SELECT name, image_url FROM assessments;
   ```
   All `image_url` should be `NULL`.

## After Both Fixes

1. ✅ **Redeploy the edge function** (with CORS headers)
2. ✅ **Run the SQL** to fix image URLs
3. ✅ **Refresh the browser** - CORS error should be gone
4. ✅ **Image errors should stop** (images will be NULL, but no more broken URLs)

## Test the Edge Function

After deploying, test it:
1. Go to **Supabase Dashboard** → **Edge Functions** → `evaluate-assessments`
2. Click **"Invoke function"**
3. Use this test payload:
   ```json
   {
     "patient_id": "00000000-0000-0000-0000-000000000000",
     "assessment_id": "your-assessment-id",
     "questions": [
       {
         "question_id": "aq10_q1",
         "answer_id": "aq10_q1_o1"
       }
     ]
   }
   ```

## Troubleshooting

- **Still getting CORS error** → Make sure you redeployed the function with the updated code
- **Image errors persist** → Check that the SQL UPDATE ran successfully
- **Function returns 500** → Check Edge Function logs in Dashboard for detailed errors
