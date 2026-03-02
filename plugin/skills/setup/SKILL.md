---
name: setup
description: "Configure your Plugged.in API key and MCP connection for Claude Code integration"
user-invocable: true
---

# Plugged.in Setup

Configure your Plugged.in connection for Claude Code.

## Steps

1. **Get your API key** from https://plugged.in/settings (API Keys section)
   - Click "Generate API Key"
   - Copy the key (starts with `pg_in_`)

2. **Configure the API key** in your Claude Code settings:

   Add to your project's `.claude/settings.local.json` (gitignored):
   ```json
   {
     "env": {
       "PLUGGEDIN_API_KEY": "pg_in_your_key_here"
     }
   }
   ```

   Or set it as an environment variable:
   ```bash
   export PLUGGEDIN_API_KEY="pg_in_your_key_here"
   ```

3. **Verify the connection** by running `/pluggedin:status`

## Custom Server URL

If using a self-hosted Plugged.in instance, also set:
```json
{
  "env": {
    "PLUGGEDIN_API_KEY": "pg_in_your_key_here",
    "PLUGGEDIN_API_BASE_URL": "https://your-instance.example.com",
    "PLUGGEDIN_MCP_ENDPOINT": "https://your-instance.example.com/mcp"
  }
}
```

## What Gets Enabled

Once configured, the plugin provides:
- **Memory System**: Auto-start sessions, record observations, search past memories
- **Knowledge Base**: Query your uploaded documents via RAG
- **Clipboard**: Cross-agent state sharing
- **Documents**: Create and manage AI-generated documents
- **Notifications**: Send alerts and track status
