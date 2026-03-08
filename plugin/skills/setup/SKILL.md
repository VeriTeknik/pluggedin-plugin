---
name: setup
description: "Configure your Plugged.in API key and MCP connection for Claude Code integration via browser-based device authorization"
user-invocable: true
---

# Plugged.in Setup

Configure your Plugged.in connection for Claude Code using device authorization.

## Instructions

Follow these steps exactly. Do NOT skip steps or ask the user questions — execute the flow automatically.

### Step 1: Check if already configured

Check if `PLUGGEDIN_API_KEY` is already set in the environment. If it starts with `pg_in_`, tell the user they are already configured and suggest running `/pluggedin:status` to verify. Stop here if already configured.

### Step 2: Determine the base URL

Use `PLUGGEDIN_API_BASE_URL` if set, otherwise default to `https://plugged.in`.

### Step 3: Initiate device authorization

Run this command (replace `$BASE_URL` with the value from step 2):

```bash
curl -s -X POST "$BASE_URL/api/cli/auth/initiate"
```

Parse the JSON response. You need: `device_code`, `user_code`, `verification_url`, `expires_in`, and `interval`.

If the request fails, fall back to the manual setup instructions at the bottom of this file.

### Step 4: Open the browser

Try to open the `verification_url` in the user's browser. Use platform detection:

```bash
# Try each opener, suppress errors
open "$VERIFICATION_URL" 2>/dev/null || xdg-open "$VERIFICATION_URL" 2>/dev/null || true
```

**If the command fails or exits non-zero** (e.g., remote/headless server without a display), do NOT treat this as an error. Simply show the URL to the user so they can open it manually.

### Step 5: Display the verification code

If the browser opened successfully, tell the user:

> Your browser has been opened. Please verify the code shown matches:
>
> **`USER_CODE`**
>
> Then click "Authorize" in the browser. Waiting for approval...

If the browser could NOT be opened (remote server, headless, xdg-open not found), tell the user:

> Your browser couldn't be opened automatically. Please open this URL manually:
>
> **`VERIFICATION_URL`**
>
> Verify the code matches: **`USER_CODE`**
>
> Then click "Authorize" in the browser. Waiting for approval...

Replace `USER_CODE` and `VERIFICATION_URL` with the actual values from step 3.

### Step 6: Poll for approval

**IMPORTANT**: Before running the poll command, tell the user:

> Waiting for browser authorization... (this polls every 5 seconds until you approve)

Then poll the device code endpoint every `interval` seconds (default 5), up to `expires_in / interval` times:

```bash
curl -s "$BASE_URL/api/cli/auth/poll?device_code=$DEVICE_CODE"
```

Check the `status` field in the response:
- `authorization_pending` — keep polling (sleep `interval` seconds between polls)
- `approved` — the response includes `api_key`, proceed to step 7
- `denied` — tell the user authorization was denied, stop
- `expired` — tell the user the code expired, suggest re-running `/pluggedin:setup`

### Step 7: Save the API key

Save the API key to `~/.config/pluggedin/credentials.json` (XDG-compliant, outside any git repo):

```bash
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/pluggedin"
```

Write the credentials file to `${XDG_CONFIG_HOME:-$HOME/.config}/pluggedin/credentials.json`:
```json
{
  "api_key": "pg_in_...",
  "base_url": "https://plugged.in"
}
```

If `PLUGGEDIN_API_BASE_URL` is set in the environment, use that value for `base_url`. If `PLUGGEDIN_MCP_ENDPOINT` is set, include it as `mcp_endpoint`.

**Also** save to `.claude/settings.local.json` (both project-level and user-level) so that hook scripts receive the API key as an environment variable:

```json
{
  "env": {
    "PLUGGEDIN_API_KEY": "pg_in_...",
    "PLUGGEDIN_API_BASE_URL": "https://plugged.in"
  }
}
```

Read any existing `.claude/settings.local.json` first and merge — don't overwrite other settings.

### Step 8: Done

Tell the user:

> Setup complete! Your API key has been saved to:
> - `~/.config/pluggedin/credentials.json` (primary — used by MCP proxy)
> - `.claude/settings.local.json` (for the hook scripts environment)
>
> The MCP proxy will detect the new key within a few seconds. Run `/pluggedin:status` to verify.

## Manual Setup (Fallback)

If the device authorization flow fails, provide these manual instructions:

1. **Get your API key** from https://plugged.in/settings (API Keys section)
   - Click "Generate API Key"
   - Copy the key (starts with `pg_in_`)

2. **Save the credentials**:
   ```bash
   mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/pluggedin"
   cat > "${XDG_CONFIG_HOME:-$HOME/.config}/pluggedin/credentials.json" << 'EOF'
   {
     "api_key": "pg_in_your_key_here"
   }
   EOF
   ```

3. **Also add to Claude settings** so hook scripts can access it:
   Create/edit both `.claude/settings.local.json` (project) and `~/.claude/settings.local.json` (user):
   ```json
   {
     "env": {
       "PLUGGEDIN_API_KEY": "pg_in_your_key_here"
     }
   }
   ```

4. Run `/pluggedin:status` to verify (the MCP proxy picks up the key automatically)
