# Vercel Deployment Summary

## ✅ What's Been Set Up

### 1. Vercel Configuration Files

Created `vercel.json` for each app:
- ✅ `patient/vercel.json`
- ✅ `therapist/vercel.json`
- ✅ `clinic/vercel.json`

Each configuration includes:
- Build command with Flutter installation
- Output directory (`build/web`)
- SPA routing (all routes → `index.html`)
- Security headers
- Asset caching

### 2. Environment Variable Handling

The build commands automatically create `.env` files in `web/` directories from Vercel environment variables:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GEMINI_API_KEY`

### 3. Documentation

- ✅ `VERCEL_DEPLOYMENT_GUIDE.md` - Comprehensive guide
- ✅ `VERCEL_QUICK_START.md` - Quick reference
- ✅ `.vercelignore` - Files to exclude from deployments

## 🚀 Deployment Steps

### Option 1: Vercel Dashboard (Easiest)

1. **Go to [vercel.com/new](https://vercel.com/new)**
2. **Import your repository**
3. **For each app, configure:**
   - Project Name: `neurotrack-patient` / `neurotrack-therapist` / `neurotrack-clinic`
   - Root Directory: `patient` / `therapist` / `clinic`
   - Framework: Other
   - Build/Output: Auto-detected from `vercel.json`
4. **Add Environment Variables** (same for all apps):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GEMINI_API_KEY`
5. **Deploy**

### Option 2: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy Patient App
cd patient
vercel link
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GEMINI_API_KEY
vercel --prod

# Deploy Therapist App
cd ../therapist
vercel link
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GEMINI_API_KEY
vercel --prod

# Deploy Clinic App
cd ../clinic
vercel link
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GEMINI_API_KEY
vercel --prod
```

## 📋 Important Notes

### Build Time

- First build: ~10-15 minutes (Flutter installation + build)
- Subsequent builds: ~5-8 minutes (cached Flutter)

### Build Command Details

The build command:
1. Checks if Flutter is installed
2. If not, downloads and installs Flutter 3.6.0
3. Creates `.env` file from Vercel environment variables
4. Runs `flutter pub get`
5. Builds web app with CanvasKit renderer
6. Outputs to `build/web/`

### Environment Variables

**Required for all apps:**
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `GEMINI_API_KEY` - Google Gemini API key

**Where to set:**
- Vercel Dashboard → Project Settings → Environment Variables
- Add for: Production, Preview, Development

## 🔧 Post-Deployment Checklist

- [ ] All three apps deployed successfully
- [ ] Environment variables set for each app
- [ ] Test Patient App login
- [ ] Test Therapist App login
- [ ] Test Clinic App login
- [ ] Update Supabase redirect URLs:
  - Add Vercel URLs to Supabase Dashboard → Authentication → URL Configuration
- [ ] Test OAuth flows on all apps
- [ ] Verify API calls work
- [ ] Check browser console for errors
- [ ] Test on mobile devices (if applicable)

## 🐛 Troubleshooting

### Build Fails: "flutter: command not found"

The build command should auto-install Flutter. If it fails:
1. Check build logs in Vercel Dashboard
2. Verify the Flutter download URL is accessible
3. Consider using a custom Docker image with Flutter pre-installed

### Build Fails: "Missing .env file"

The build command creates `.env` automatically. If it fails:
1. Verify environment variables are set in Vercel
2. Check build logs for environment variable errors
3. Ensure variables are set for the correct environment (Production/Preview)

### Assets Not Loading (404)

1. Verify `base href="/"` in `web/index.html`
2. Check `vercel.json` rewrites configuration
3. Ensure build output is `build/web`
4. Check browser console for specific 404 errors

### Routing Issues (404 on refresh)

The `vercel.json` includes rewrites. If still failing:
1. Verify `vercel.json` is in the correct location
2. Check Vercel project settings match the configuration
3. Try redeploying

## 📊 Expected Build Output

Each app should produce:
- `build/web/index.html`
- `build/web/main.dart.js`
- `build/web/assets/` (fonts, images, etc.)
- `build/web/flutter_bootstrap.js`
- `build/web/.env` (created during build)

## 🔗 Useful Links

- [Vercel Documentation](https://vercel.com/docs)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Vercel Environment Variables](https://vercel.com/docs/concepts/projects/environment-variables)

## 💡 Tips

1. **Use Vercel's Preview Deployments**: Test changes before production
2. **Monitor Build Logs**: Check for warnings or errors
3. **Set Up Custom Domains**: After deployment, add your domains
4. **Enable Analytics**: Track usage and performance
5. **Set Up CI/CD**: Auto-deploy on git push (enabled by default)

---

**Ready to deploy?** Start with [VERCEL_QUICK_START.md](./VERCEL_QUICK_START.md) for the fastest path!
