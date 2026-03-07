---
name: rag-context
description: "Search the user's knowledge base for relevant documentation, guides, and reference material. Use when you need information that might be in uploaded documents."
user-invokable: true
argument-hint: "<search query>"
---

# RAG Context

Search the Plugged.in knowledge base for relevant documentation.

## Usage

Call `pluggedin_ask_knowledge_base` with the query: "$ARGUMENTS"

The knowledge base contains documents the user has uploaded to Plugged.in, including:
- Technical documentation
- Architecture guides
- API references
- Meeting notes
- Design documents

## When to Use

- Before asking the user for information that might be documented
- When you need context about project architecture or conventions
- When looking for specific API documentation or integration guides
- When the user references a document or guide

## Response Format

The knowledge base returns:
- **answer**: AI-generated answer based on matching documents
- **sources**: Document titles and IDs that contributed to the answer
- **metadata**: Relevance scores and document details

If the answer references specific documents, you can retrieve full content with `pluggedin_get_document`.
