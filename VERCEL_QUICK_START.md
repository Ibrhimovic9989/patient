# Quick Start: Deploy to Vercel

## Prerequisites

- Vercel account ([vercel.com](https://vercel.com))
- GitHub/GitLab/Bitbucket repository with your code
- Flutter SDK installed locally (for testing)

## Quick Deployment Steps

### 1. Deploy Patient App

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import your repository
3. Configure:
   - **Project Name**: `neurotrack-patient`
   - **Root Directory**: `patient`
   - **Framework**: Other
   - **Build Command**: `bash build.sh` (auto-detected from `vercel.json`)
   - **Output Directory**: `build/web` (auto-detected from `vercel.json`)
4. Add Environment Variables:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GEMINI_API_KEY`
5. Click **Deploy**

### 2. Deploy Therapist App

Repeat with:
- **Project Name**: `neurotrack-therapist`
- **Root Directory**: `therapist`

### 3. Deploy Clinic App

Repeat with:
- **Project Name**: `neurotrack-clinic`
- **Root Directory**: `clinic`

## Environment Variables

Add these to each project in Vercel Dashboard → Settings → Environment Variables:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GEMINI_API_KEY=your-gemini-key
```

## Post-Deployment

1. **Update Supabase Redirect URLs**:
   - Add your Vercel URLs to Supabase Dashboard → Authentication → URL Configuration

2. **Test Each App**:
   - Patient: `https://your-patient-app.vercel.app`
   - Therapist: `https://your-therapist-app.vercel.app`
   - Clinic: `https://your-clinic-app.vercel.app`

## Troubleshooting

### Build Fails

If build fails with "flutter: command not found", the `vercel.json` files include automatic Flutter installation. If it still fails:

1. Check build logs in Vercel Dashboard
2. Verify Flutter version in build command matches your local version
3. Consider using GitHub Actions to build and commit artifacts

### Assets Not Loading

- Verify `base href="/"` in `web/index.html`
- Check `vercel.json` rewrites configuration
- Ensure build output is `build/web`

## Need More Details?

See [VERCEL_DEPLOYMENT_GUIDE.md](./VERCEL_DEPLOYMENT_GUIDE.md) for comprehensive guide.
