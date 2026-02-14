# Vercel Deployment Guide for NeuroTrack Apps

This guide covers deploying the Patient, Therapist, and Clinic apps separately on Vercel.

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Vercel CLI** (optional, for CLI deployment):
   ```bash
   npm i -g vercel
   ```
3. **Flutter SDK**: Ensure Flutter is installed and `flutter` is in PATH
4. **Environment Variables**: Prepare your `.env` file values

## Project Structure

Each app is deployed as a separate Vercel project:
- `patient/` → Patient App
- `therapist/` → Therapist App  
- `clinic/` → Clinic App

## Deployment Methods

### Method 1: Vercel Dashboard (Recommended)

#### Step 1: Deploy Patient App

1. **Go to Vercel Dashboard**: [vercel.com/dashboard](https://vercel.com/dashboard)
2. **Click "Add New Project"**
3. **Import Git Repository**:
   - Connect your GitHub/GitLab/Bitbucket repository
   - Select the repository containing NeuroTrack
4. **Configure Project**:
   - **Project Name**: `neurotrack-patient` (or your preferred name)
   - **Root Directory**: `patient`
   - **Framework Preset**: Other
   - **Build Command**: `cd .. && flutter build web --release --web-renderer canvaskit`
   - **Output Directory**: `build/web`
   - **Install Command**: `flutter pub get`
5. **Environment Variables**:
   - Click "Environment Variables"
   - Add the following:
     ```
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     GEMINI_API_KEY=your_gemini_api_key
     ```
6. **Deploy**: Click "Deploy"

#### Step 2: Deploy Therapist App

Repeat the same process with:
- **Project Name**: `neurotrack-therapist`
- **Root Directory**: `therapist`
- Same build/output/install commands
- Same environment variables

#### Step 3: Deploy Clinic App

Repeat the same process with:
- **Project Name**: `neurotrack-clinic`
- **Root Directory**: `clinic`
- Same build/output/install commands
- Same environment variables

### Method 2: Vercel CLI

#### Initial Setup

```bash
# Install Vercel CLI globally
npm i -g vercel

# Login to Vercel
vercel login
```

#### Deploy Patient App

```bash
cd patient

# Link to Vercel project (first time)
vercel link

# Set environment variables
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GEMINI_API_KEY

# Deploy
vercel --prod
```

#### Deploy Therapist App

```bash
cd therapist

# Link to Vercel project (first time)
vercel link

# Set environment variables
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GEMINI_API_KEY

# Deploy
vercel --prod
```

#### Deploy Clinic App

```bash
cd clinic

# Link to Vercel project (first time)
vercel link

# Set environment variables
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GEMINI_API_KEY

# Deploy
vercel --prod
```

## Environment Variables

Each app needs these environment variables in Vercel:

### Required Variables

| Variable | Description | Where to Find |
|----------|-------------|---------------|
| `SUPABASE_URL` | Your Supabase project URL | Supabase Dashboard → Settings → API |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | Supabase Dashboard → Settings → API |
| `GEMINI_API_KEY` | Google Gemini API key | Google AI Studio |

### Setting Environment Variables

**Via Dashboard**:
1. Go to Project Settings → Environment Variables
2. Add each variable for Production, Preview, and Development
3. Save

**Via CLI**:
```bash
vercel env add VARIABLE_NAME
# Enter value when prompted
```

## Build Configuration

Each app has a `vercel.json` file with:
- **Build Command**: `cd .. && flutter build web --release --web-renderer canvaskit`
- **Output Directory**: `build/web`
- **SPA Routing**: All routes rewrite to `index.html`
- **Security Headers**: XSS protection, frame options, etc.
- **Asset Caching**: Long-term caching for static assets

## Important Notes

### Flutter Web Build Requirements

1. **Flutter SDK**: Vercel build environment needs Flutter installed
   - Vercel doesn't have Flutter pre-installed
   - You may need to use a custom build image or install Flutter in build command

2. **Build Time**: Flutter web builds can take 5-10 minutes
   - First build is slower
   - Subsequent builds are faster with caching

3. **Build Image**: Consider using a custom Docker image with Flutter pre-installed

### Custom Build Image (Recommended)

Create a `Dockerfile` in each app directory or use Vercel's build settings:

**Option 1: Install Flutter in Build Command**

Update `vercel.json` build command:
```json
{
  "buildCommand": "bash -c 'curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.6.0-stable.tar.xz | tar xJ && export PATH=\"$PATH:$PWD/flutter/bin\" && cd .. && flutter build web --release --web-renderer canvaskit'"
}
```

**Option 2: Use Vercel Build Settings**

In Vercel Dashboard → Project Settings → Build & Development Settings:
- **Build Command**: Custom command that installs Flutter first
- **Install Command**: `flutter pub get` (after Flutter is available)

### Alternative: Use GitHub Actions + Vercel

1. **Build Flutter apps in GitHub Actions**
2. **Commit build artifacts**
3. **Deploy to Vercel** (just serve static files)

This avoids Flutter installation in Vercel's build environment.

## Post-Deployment Configuration

### 1. Update Supabase Redirect URLs

After deployment, update Supabase redirect URLs:

1. Go to **Supabase Dashboard → Authentication → URL Configuration**
2. Add your Vercel URLs:
   ```
   https://your-patient-app.vercel.app
   https://your-therapist-app.vercel.app
   https://your-clinic-app.vercel.app
   ```

### 2. Update Google OAuth Redirect URIs

1. Go to **Google Cloud Console → APIs & Services → Credentials**
2. Edit your OAuth 2.0 Client
3. Add authorized redirect URIs:
   ```
   https://your-project-id.supabase.co/auth/v1/callback
   ```
   (This should already be set, but verify)

### 3. Custom Domains (Optional)

1. Go to **Project Settings → Domains**
2. Add your custom domain
3. Follow DNS configuration instructions

## Troubleshooting

### Build Fails: "flutter: command not found"

**Solution**: Install Flutter in build environment or use custom Docker image.

**Quick Fix**: Add to build command:
```bash
# Install Flutter
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.6.0-stable.tar.xz | tar xJ
export PATH="$PATH:$PWD/flutter/bin"

# Then build
cd .. && flutter build web --release --web-renderer canvaskit
```

### Build Fails: "Missing .env file"

**Solution**: Add environment variables in Vercel Dashboard, not `.env` file.

### Assets Not Loading (404 errors)

**Solution**: 
- Check `vercel.json` rewrites configuration
- Verify `base href` in `web/index.html` is `/`
- Ensure build output directory is correct

### Routing Issues (404 on refresh)

**Solution**: `vercel.json` already includes rewrites. Verify it's deployed correctly.

### CORS Errors

**Solution**: 
- Check Supabase CORS settings
- Verify redirect URLs are correct
- Check Edge Function CORS headers

## Deployment Checklist

### Before Deployment

- [ ] Flutter web builds successfully locally
- [ ] Environment variables documented
- [ ] `.env` file not committed to git
- [ ] `vercel.json` files created for each app
- [ ] Test apps locally with production build

### During Deployment

- [ ] Deploy Patient App
- [ ] Deploy Therapist App
- [ ] Deploy Clinic App
- [ ] Set environment variables for each
- [ ] Verify builds complete successfully

### After Deployment

- [ ] Test Patient App functionality
- [ ] Test Therapist App functionality
- [ ] Test Clinic App functionality
- [ ] Update Supabase redirect URLs
- [ ] Test OAuth login on all apps
- [ ] Verify API calls work
- [ ] Check browser console for errors
- [ ] Test on mobile devices (if applicable)

## Monitoring

### Vercel Analytics

1. Enable Vercel Analytics in project settings
2. Monitor:
   - Page views
   - Performance metrics
   - Error rates

### Error Tracking

Consider adding:
- Sentry for error tracking
- LogRocket for session replay
- Firebase Analytics

## Cost Considerations

### Vercel Pricing

- **Hobby Plan**: Free for personal projects
  - 100GB bandwidth/month
  - Unlimited deployments
- **Pro Plan**: $20/month
  - 1TB bandwidth/month
  - Team collaboration
  - Analytics

### Bandwidth Usage

Flutter web apps can be large (5-10MB initial load). Monitor usage:
- Patient App: ~5-8MB
- Therapist App: ~5-8MB
- Clinic App: ~3-5MB

## Next Steps

1. ✅ Deploy all three apps
2. ✅ Configure environment variables
3. ✅ Update Supabase redirect URLs
4. ⏳ Set up custom domains (optional)
5. ⏳ Configure monitoring and analytics
6. ⏳ Set up CI/CD for automatic deployments

---

## Quick Reference

### Deploy Commands (CLI)

```bash
# Patient App
cd patient && vercel --prod

# Therapist App
cd therapist && vercel --prod

# Clinic App
cd clinic && vercel --prod
```

### Environment Variables (All Apps)

```
SUPABASE_URL
SUPABASE_ANON_KEY
GEMINI_API_KEY
```

### Build Output

All apps build to: `build/web/`

---

**Need Help?** Check Vercel documentation: [vercel.com/docs](https://vercel.com/docs)
