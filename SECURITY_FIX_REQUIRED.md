# 🔴 URGENT: Security Fix Required

## Critical Security Issue Fixed

The hardcoded Azure OpenAI API key has been removed from the source code. However, **you must complete the following steps immediately**:

### Step 1: Rotate the Exposed API Key ⚠️

**The API key that was in the code is now compromised and must be rotated immediately.**

1. Go to Azure Portal → Your OpenAI resource
2. Navigate to **Keys and Endpoint**
3. **Regenerate** the API key
4. This will invalidate the old key

### Step 2: Set Environment Variables in Supabase

After rotating the key, set the new values as Supabase Edge Function secrets:

```bash
# Set Azure OpenAI configuration
supabase secrets set AZURE_OPENAI_ENDPOINT="https://razam-mac1ml8q-eastus2.cognitiveservices.azure.com/"
supabase secrets set AZURE_OPENAI_API_KEY="<YOUR_NEW_ROTATED_KEY>"
supabase secrets set AZURE_OPENAI_DEPLOYMENT="gpt-5.2-chat"
supabase secrets set AZURE_OPENAI_API_VERSION="2024-04-01-preview"
```

### Step 3: Redeploy the Edge Function

```bash
supabase functions deploy analyze-milestones
```

### Step 4: Verify the Fix

1. Test the edge function to ensure it works with environment variables
2. Check that the old API key no longer works
3. Verify no API keys are visible in the deployed function code

### Step 5: Review Git History

If this repository is public or shared:
1. Consider the key as compromised
2. Review who has access to the repository
3. Check Azure logs for unauthorized usage
4. Consider making the repository private if it contains sensitive information

---

## What Was Changed

**File**: `supabase/functions/analyze-milestones/index.ts`

**Before**:
```typescript
const AZURE_OPENAI_API_KEY = "YOUR_API_KEY_HERE" // ⚠️ EXPOSED KEY - REMOVED FOR SECURITY
```

**After**:
```typescript
const AZURE_OPENAI_API_KEY = Deno.env.get('AZURE_OPENAI_API_KEY') ?? ''
```

The function now validates that the environment variables are set and returns an error if they're missing.

---

## Prevention

To prevent this in the future:

1. ✅ **Never commit API keys to version control**
2. ✅ **Use environment variables for all secrets**
3. ✅ **Add `.env` files to `.gitignore`**
4. ✅ **Use secret scanning tools** (GitHub Secret Scanning, GitGuardian, etc.)
5. ✅ **Review code before committing**
6. ✅ **Use pre-commit hooks** to detect secrets

---

## Status

- [x] Code updated to use environment variables
- [ ] API key rotated in Azure Portal
- [ ] Environment variables set in Supabase
- [ ] Edge function redeployed
- [ ] Function tested and verified

**Complete all steps before deploying to production!**
