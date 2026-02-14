# GitHub Push Instructions

## Authentication Required

The repository requires authentication. Use one of these methods:

## Method 1: Personal Access Token (Easiest)

### Step 1: Create Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. **Token name**: `NeuroTrack Push`
4. **Expiration**: Choose your preferred duration
5. **Select scopes**: Check `repo` (Full control of private repositories)
6. Click **"Generate token"**
7. **Copy the token immediately** (you won't see it again!)

### Step 2: Push Using Token

Replace `YOUR_TOKEN` with your actual token:

```powershell
git remote set-url origin https://YOUR_TOKEN@github.com/Ibrhimovic9989/patient.git
git push -u origin main
```

Or use your username with token:

```powershell
git remote set-url origin https://ibrhimovic9989:YOUR_TOKEN@github.com/Ibrhimovic9989/patient.git
git push -u origin main
```

## Method 2: SSH (More Secure)

### Step 1: Generate SSH Key (if you don't have one)

```powershell
ssh-keygen -t ed25519 -C "ibrahimshaheer75@gmail.com"
```

Press Enter to accept default location. Optionally set a passphrase.

### Step 2: Add SSH Key to GitHub

1. Copy your public key:
   ```powershell
   cat ~/.ssh/id_ed25519.pub
   ```
   (Or `cat C:\Users\camun\.ssh\id_ed25519.pub`)

2. Go to: https://github.com/settings/keys
3. Click **"New SSH key"**
4. **Title**: `NeuroTrack Development`
5. **Key**: Paste your public key
6. Click **"Add SSH key"**

### Step 3: Update Remote to Use SSH

```powershell
git remote set-url origin git@github.com:Ibrhimovic9989/patient.git
git push -u origin main
```

## Method 3: GitHub CLI

### Step 1: Install GitHub CLI

```powershell
winget install GitHub.cli
```

### Step 2: Authenticate

```powershell
gh auth login
```

Follow the prompts to authenticate.

### Step 3: Push

```powershell
git push -u origin main
```

## Quick Fix: Update Remote URL

If you already have a token, just update the remote:

```powershell
# Replace YOUR_TOKEN with your actual token
git remote set-url origin https://ibrhimovic9989:YOUR_TOKEN@github.com/Ibrhimovic9989/patient.git
git push -u origin main
```

## Troubleshooting

### "Permission denied" error
- Make sure you're using the correct GitHub username
- Verify your token has `repo` scope
- Check that the repository exists and you have write access

### "Repository not found" error
- Verify the repository URL is correct
- Make sure the repository exists on GitHub
- Check that you have access to the repository

### Token in URL Security Note
⚠️ **Important**: If you use a token in the URL, it may be stored in:
- Git config
- Command history
- Credential manager

For better security, use SSH or GitHub CLI after initial setup.

---

**Recommended**: Use Method 1 (Personal Access Token) for quick setup, then switch to Method 2 (SSH) for long-term use.
