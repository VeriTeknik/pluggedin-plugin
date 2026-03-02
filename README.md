# pluggedin-plugin

The official Claude Code plugin for [Plugged.in](https://plugged.in) -- the AI Infrastructure Platform.

## What It Does

This plugin connects Claude Code to the Plugged.in platform, giving you access to 1,500+ MCP tools, persistent memory across sessions, a RAG-powered knowledge base, cross-agent clipboard, notifications, and collective best practices -- all through a single plugin installation. Memory sessions start and end automatically, observations are captured in the background, and relevant memories are injected before context compaction so nothing important is lost.

## Quick Start

### Prerequisites

- Claude Code (latest version recommended)
- Node.js >= 18.0.0 (for `npx`)
- A [Plugged.in](https://plugged.in) account (free)
- An API key from your Plugged.in dashboard (Settings > API Keys)

### Installation

Inside Claude Code, open the plugin manager and add the marketplace:

```bash
/plugin marketplace add VeriTeknik/pluggedin-plugin
```

Then install the plugin:

```bash
/plugin install pluggedin@VeriTeknik-pluggedin-plugin
```

Or use the interactive plugin manager (`/plugin`) to browse and install from the **Discover** tab.

The plugin uses the Anthropic MCP proxy to connect to the Plugged.in MCP endpoint. The `.mcp.json` configuration:

```json
{
  "mcpServers": {
    "pluggedin": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-proxy", "--endpoint", "https://mcp.plugged.in/mcp"],
      "env": {
        "PLUGGEDIN_API_KEY": "your-api-key"
      }
    }
  }
}
```

### Setup

After installing, run the `/pluggedin:setup` skill to configure your connection:

1. Get your API key from https://plugged.in/settings (API Keys section) -- it starts with `pg_in_`
2. Add it to your project's `.claude/settings.local.json` (gitignored):

```json
{
  "env": {
    "PLUGGEDIN_API_KEY": "pg_in_your_key_here"
  }
}
```

Or export it as an environment variable:

```bash
export PLUGGEDIN_API_KEY="pg_in_your_key_here"
```

3. Verify the connection with `/pluggedin:status`

## Features

### MCP Tools (24 tools via the Plugged.in platform)

#### Memory (7 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_memory_session_start` | Start a memory session for the current conversation |
| `pluggedin_memory_session_end` | End session and trigger Z-report generation |
| `pluggedin_memory_observe` | Record an observation (error, preference, decision, etc.) |
| `pluggedin_memory_search` | Semantic search across memories (returns summaries) |
| `pluggedin_memory_details` | Get full content for specific memories by UUID |
| `pluggedin_memory_search_with_context` | Archetype-enhanced search — returns personal memories + collective patterns filtered through Shadow/Sage/Hero/Trickster based on context |
| `pluggedin_memory_individuation` | Get individuation score (0-100) with Memory Depth, Learning Velocity, Collective Contribution, Self-Awareness components and tips |

#### Knowledge Base (1 tool)

| Tool | Purpose |
|------|---------|
| `pluggedin_ask_knowledge_base` | RAG query against your uploaded documents |

#### Clipboard (6 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_clipboard_set` | Set entry by name or index |
| `pluggedin_clipboard_get` | Get entries by name, index, or list all |
| `pluggedin_clipboard_delete` | Delete entries or clear all |
| `pluggedin_clipboard_list` | List all entries with metadata |
| `pluggedin_clipboard_push` | Push to stack (auto-increment index) |
| `pluggedin_clipboard_pop` | Pop from stack (LIFO) |

#### Documents (5 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_create_document` | Create and save AI-generated documents |
| `pluggedin_list_documents` | List documents with filtering |
| `pluggedin_search_documents` | Search documents semantically |
| `pluggedin_get_document` | Retrieve a specific document |
| `pluggedin_update_document` | Update or append to a document |

#### Notifications (4 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_send_notification` | Send custom notifications with optional email |
| `pluggedin_list_notifications` | List notifications with filters |
| `pluggedin_mark_notification_done` | Mark notification as done |
| `pluggedin_delete_notification` | Delete a notification |

#### Discovery (1 tool)

| Tool | Purpose |
|------|---------|
| `pluggedin_discover_tools` | Discover all available tools from configured MCP servers |

### Skills (9 built-in slash commands)

| Skill | Command | Description |
|-------|---------|-------------|
| **Setup** | `/pluggedin:setup` | Configure your API key and MCP connection |
| **Status** | `/pluggedin:status` | Check connection status, active session, and memory statistics |
| **Memory Workflow** | `/pluggedin:memory-workflow` | Manage the full memory session lifecycle (start, observe, end) |
| **Memory Search** | `/pluggedin:memory-search` | Semantic search across past memories with progressive disclosure |
| **Memory Status** | `/pluggedin:memory-status` | View memory ring counts, decay stages, and session info |
| **Memory Forget** | `/pluggedin:memory-forget` | Delete specific memories (with confirmation safeguards) |
| **Memory Extraction** | *(automatic)* | Smart background capture of error patterns, decisions, and insights |
| **RAG Context** | `/pluggedin:rag-context` | Search your knowledge base for relevant documentation |
| **Platform Tools** | `/pluggedin:platform-tools` | Complete reference catalog of all available MCP tools |

### Agents (2 built-in)

| Agent | Purpose |
|-------|---------|
| **Memory Curator** | Classifies fresh observations into memory ring types: Procedures (repeatable workflows), Practice (successful habits), Long-term (validated insights), and Shocks (critical failures that bypass decay) |
| **Focus Assistant** | Manages a working set of 7+/-2 most relevant items for the current task context, inspired by human working memory limits. Updates the set as task context shifts. |

### Lifecycle Hooks (5 automatic hooks)

The plugin manages memory sessions and Jungian intelligence automatically through Claude Code lifecycle hooks:

| Hook | Trigger | What It Does |
|------|---------|--------------|
| **SessionStart** | Claude Code session begins | Starts a new memory session, displays your individuation score and maturity level |
| **PreToolUse** | Before any tool execution | Queries archetype-routed collective patterns and injects relevant suggestions (Shadow for errors, Sage for knowledge, Hero for workflows, Trickster after consecutive failures) |
| **PreCompact** | Before context compaction (auto or manual) | Searches for memories relevant to the current project and injects them into context so they survive compaction |
| **PostToolUse (Bash)** | After any Bash command execution | Records temporal events for synchronicity detection; captures tool results as observations; queries CBP for known error solutions |
| **Stop** | Claude Code session ends | Ends the memory session, triggers Z-report generation, and cleans up temporary state |

## Jungian Intelligence Layer (v3.2.0)

The plugin integrates four cognitive capabilities inspired by Jungian psychology:

- **Synchronicity Detection**: Discovers temporal patterns across profiles — tool co-occurrences, failure correlations, and emergent workflows
- **Dream Processing**: Batch consolidation that clusters and merges semantically similar memories during off-peak hours
- **Archetype-Driven Behavior**: Context-aware pattern delivery through Shadow (error recovery), Sage (best practices), Hero (workflow guidance), and Trickster (creative alternatives after repeated failures)
- **Individuation Metrics**: Per-profile maturity scoring (0-100) across Memory Depth, Learning Velocity, Collective Contribution, and Self-Awareness

These features work automatically through the lifecycle hooks — no manual configuration needed.

## Architecture

```
Claude Code
    |
    |-- Lifecycle Hooks (session-start, pre-compact, observe, session-end)
    |       |
    |       v
    |   Plugged.in API (https://plugged.in/api/...)
    |
    |-- MCP Proxy (@anthropic-ai/mcp-proxy)
    |       |
    |       v
    |   Plugged.in MCP Endpoint (https://mcp.plugged.in/mcp)
    |       |
    |       v
    |   1,500+ MCP Tools (memory, knowledge base, clipboard, docs, notifications)
    |
    |-- Skills (slash commands for common operations)
    |
    |-- Agents (background memory management)
```

- The **MCP proxy** connects to the Plugged.in MCP endpoint, providing access to all platform tools within Claude Code
- **Hooks** manage the memory session lifecycle automatically -- no manual intervention needed
- **Skills** provide slash commands for common operations like searching memory, checking status, and querying the knowledge base
- **Agents** handle background memory management: classifying observations and maintaining the working set

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PLUGGEDIN_API_KEY` | Yes | -- | Your Plugged.in API key (starts with `pg_in_`) |
| `PLUGGEDIN_MCP_ENDPOINT` | No | `https://mcp.plugged.in/mcp` | MCP server endpoint URL |
| `PLUGGEDIN_API_BASE_URL` | No | `https://plugged.in` | API base URL (for self-hosted instances) |

### Self-Hosted Instances

If running a self-hosted Plugged.in instance, configure all three environment variables:

```json
{
  "env": {
    "PLUGGEDIN_API_KEY": "pg_in_your_key_here",
    "PLUGGEDIN_API_BASE_URL": "https://your-instance.example.com",
    "PLUGGEDIN_MCP_ENDPOINT": "https://your-instance.example.com/mcp"
  }
}
```

## Memory System Overview

The plugin implements a human cognition-inspired memory architecture with concentric rings:

- **Fresh Memory**: Raw observations captured during a session (unclassified)
- **Procedures**: Repeatable processes, how-to instructions, step-by-step workflows
- **Practice**: Repeated successful patterns, habits, coding conventions
- **Long-term**: Validated insights and facts (requires high confidence)
- **Shocks**: Critical failures and security events (bypass normal decay)

Memories undergo natural decay through stages: full -> compressed -> summary -> essence -> forgotten. Shock memories are exempt from decay.

Search uses progressive disclosure for token efficiency:
1. **Layer 1 (Search)**: Returns lightweight summaries (50-150 tokens each)
2. **Layer 2 (Timeline)**: Adds temporal context
3. **Layer 3 (Details)**: Returns full memory content

## Links

- **Platform**: https://plugged.in
- **Documentation**: https://docs.plugged.in
- **Plugin Repository**: https://github.com/VeriTeknik/pluggedin-plugin
- **Main App Repository**: https://github.com/VeriTeknik/pluggedin-app
- **MCP Proxy Repository**: https://github.com/VeriTeknik/pluggedin-mcp

## License

MIT
