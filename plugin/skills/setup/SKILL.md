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

Open the `verification_url` in the user's browser:

```bash
open "$VERIFICATION_URL"       # macOS
# xdg-open "$VERIFICATION_URL" # Linux
```

### Step 5: Display the verification code

Tell the user:

> Your browser has been opened. Please verify the code shown matches:
>
> **`USER_CODE`**
>
> Then click "Authorize" in the browser. Waiting for approval...

Replace `USER_CODE` with the actual `user_code` from step 3.

### Step 6: Poll for approval

Poll the device code endpoint every `interval` seconds (default 5), up to `expires_in / interval` times:

```bash
curl -s "$BASE_URL/api/cli/auth/poll?device_code=$DEVICE_CODE"
```

Check the `status` field in the response:
- `authorization_pending` — keep polling (sleep `interval` seconds between polls)
- `approved` — the response includes `api_key`, proceed to step 7
- `denied` — tell the user authorization was denied, stop
- `expired` — tell the user the code expired, suggest re-running `/pluggedin:setup`

### Step 7: Save the API key

Read the existing `.claude/settings.local.json` file (create if it does not exist). Merge the `PLUGGEDIN_API_KEY` into the `env` object, preserving any existing keys. Write the file back.

The resulting file should look like:
```json
{
  "env": {
    "PLUGGEDIN_API_KEY": "pg_in_..."
  }
}
```

If `PLUGGEDIN_API_BASE_URL` or `PLUGGEDIN_MCP_ENDPOINT` are set in the environment, include them in the file as well.

### Step 8: Done

Tell the user:

> Setup complete! Your API key has been saved to `.claude/settings.local.json`.
>
> **Please restart Claude Code** for the changes to take effect, then run `/pluggedin:status` to verify.

## Manual Setup (Fallback)

If the device authorization flow fails, provide these manual instructions:

1. **Get your API key** from https://plugged.in/settings (API Keys section)
   - Click "Generate API Key"
   - Copy the key (starts with `pg_in_`)

2. **Configure the API key** in `.claude/settings.local.json`:
   ```json
   {
     "env": {
       "PLUGGEDIN_API_KEY": "pg_in_your_key_here"
     }
   }
   ```

3. **Restart Claude Code** and run `/pluggedin:status`
