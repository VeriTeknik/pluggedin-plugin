---
name: platform-tools
description: "Complete reference for all Plugged.in MCP tools - memory, knowledge base, clipboard, documents, and notifications. Use when you need to know what tools are available."
user-invocable: true
argument-hint: "[category]"
---

# Plugged.in Platform Tools

Complete catalog of available MCP tools organized by category.

## Memory (5 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_memory_session_start` | Start a memory session for the current conversation |
| `pluggedin_memory_session_end` | End session and trigger Z-report generation |
| `pluggedin_memory_observe` | Record an observation (error, preference, decision, etc.) |
| `pluggedin_memory_search` | Semantic search across memories (Layer 1 - summaries) |
| `pluggedin_memory_details` | Get full content for specific memories (Layer 3) |

## Knowledge Base (1 tool)

| Tool | Purpose |
|------|---------|
| `pluggedin_ask_knowledge_base` | RAG query against uploaded documents |

## Clipboard (6 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_clipboard_set` | Set entry by name or index |
| `pluggedin_clipboard_get` | Get entries (by name, index, or list all) |
| `pluggedin_clipboard_delete` | Delete entries or clear all |
| `pluggedin_clipboard_list` | List all entries with metadata |
| `pluggedin_clipboard_push` | Push to stack (auto-increment index) |
| `pluggedin_clipboard_pop` | Pop from stack (LIFO) |

## Documents (5 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_create_document` | Create and save AI-generated documents |
| `pluggedin_list_documents` | List documents with filtering |
| `pluggedin_search_documents` | Search documents semantically |
| `pluggedin_get_document` | Retrieve a specific document |
| `pluggedin_update_document` | Update or append to a document |

## Notifications (4 tools)

| Tool | Purpose |
|------|---------|
| `pluggedin_send_notification` | Send custom notifications with optional email |
| `pluggedin_list_notifications` | List notifications with filters |
| `pluggedin_mark_notification_done` | Mark notification as done |
| `pluggedin_delete_notification` | Delete a notification |

## Discovery (1 tool)

| Tool | Purpose |
|------|---------|
| `pluggedin_discover_tools` | Discover tools from configured MCP servers |

## Best Practices

- **Memory**: Start sessions early, observe often, end properly
- **Search before ask**: Check knowledge base and memory before asking the user
- **Clipboard for pipelines**: Use push/pop for ordered data, named entries for semantic access
- **Progressive disclosure**: Search first (cheap), details only when needed (expensive)
