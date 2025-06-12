# Claude AI Complete Reference Guide

> **Comprehensive documentation for Claude AI, Claude Code, and development best practices**  
> Compiled from official Anthropic documentation and community guides  
> Optimized for AI parsing and developer reference

---

## Table of Contents

1. [Project Context](#project-context)
2. [Core Prompt Engineering](#core-prompt-engineering)
3. [Claude Code CLI Usage](#claude-code-cli-usage)
4. [Advanced Features](#advanced-features)
5. [Testing & Evaluation](#testing--evaluation)
6. [Best Practices](#best-practices)
7. [Security & Configuration](#security--configuration)
8. [Practical Examples](#practical-examples)
9. [Quick Reference](#quick-reference)

---

## Project Context

### NeuroVis Educational Platform

**A1-NeuroVis** is an advanced educational neuroscience visualization platform built with Godot 4.4.1 for interactive brain anatomy exploration. It's designed specifically for **medical students**, **neuroscience researchers**, and **healthcare professionals**.

#### Current Status
- **Overall**: 🟡 CAUTION - Critical syntax error blocking development
- **Architecture**: ✅ Excellent - Well-organized modular educational platform
- **Core Services**: ✅ Comprehensive - 13 autoload services properly configured
- **Educational Content**: ✅ Rich - Structured anatomical knowledge base with 3D models
- **Blocking Issue**: 🔴 Critical syntax error in `BrainStructureSelectionManager.gd:16`

#### Educational Mission
- Interactive 3D brain exploration with educational context
- Structured learning pathways for different skill levels
- Clinical relevance and pathology information
- AI-powered anatomical query assistance
- Accessibility compliance for diverse learning needs
- Progress tracking and assessment tools

#### Architecture Overview
```
NeuroVis Educational Platform
├── CORE SYSTEMS (core/)
│   ├── Knowledge Management ✅
│   ├── AI Support ✅
│   ├── 3D Interaction 🔴 BLOCKING
│   └── Educational Systems ✅
├── UI SYSTEMS (ui/) ✅
├── EDUCATIONAL CONTENT ✅
└── TESTING INFRASTRUCTURE ✅
```

---

## Core Prompt Engineering

### The Golden Rule
**"Show your prompt to a colleague with minimal context. If they're confused, Claude will likely be too."**

### Essential Principles

#### 1. Be Clear, Direct, and Detailed
- **Provide Context**: What the task results will be used for
- **Target Audience**: Who the output is meant for
- **Workflow Context**: What workflow the task is part of
- **Success Criteria**: What successful completion looks like

#### 2. Use Sequential Instructions
```markdown
1. First, analyze the existing code structure
2. Then, identify performance bottlenecks
3. Next, propose optimization strategies
4. Finally, implement the top 3 optimizations
```

#### 3. Role Prompting (System Prompts)
**Most powerful technique for improving Claude's performance**

```python
import anthropic

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-3-7-sonnet-20250219",
    system="You are a senior DevOps engineer at a Fortune 500 company specializing in Kubernetes and cloud infrastructure.",
    messages=[{
        "role": "user",
        "content": "Design a fault-tolerant microservices architecture"
    }]
)
```

### Claude 4 Best Practices

#### Be Explicit With Instructions
Claude 4 responds better to clear, explicit instructions:
```markdown
"Create a comprehensive test suite that includes:
- Unit tests for all public methods
- Integration tests for API endpoints
- Edge case coverage
- Performance benchmarks
Go above and beyond with test coverage"
```

#### Control Output Format
```markdown
# Tell Claude what TO do, not what NOT to do
❌ "Don't use markdown"
✅ "Format your response as plain text paragraphs"

# Use XML tags for structure
"Write code in <code> tags and explanations in <explanation> tags"
```

#### Extended Thinking
```markdown
# For complex problems, request deeper analysis
"think hard about potential security vulnerabilities"
"think harder about race conditions"
"ultrathink about the system architecture implications"
```

### Multishot (Few-Shot) Prompting

Provide 3-5 examples for dramatic accuracy improvements:

```xml
<example>
Input: The dashboard loads slowly and I can't find the export button
Category: Performance, UI/UX
Priority: High
Sentiment: Negative
</example>

<example>
Input: Love the new features! Minor bug in dark mode though
Category: Feature Feedback, Bug Report
Priority: Low
Sentiment: Positive
</example>

Now categorize: "The API documentation is outdated and confusing"
```

### Prefilling Claude's Response

Skip preambles and enforce format:

```python
messages = [
    {
        "role": "user",
        "content": "Extract user data as JSON"
    },
    {
        "role": "assistant",
        "content": "{"  # Prefill forces immediate JSON
    }
]
# Claude continues: "name": "John", "email": "john@example.com"}
```

### Chain of Thought Prompting

```xml
Analyze this problem step by step:

<thinking>
[Detailed reasoning process]
</thinking>

<answer>
[Final conclusion]
</answer>
```

---

## Claude Code CLI Usage

### Overview
Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster through natural language commands.

### Key Features
- **Deep Codebase Understanding**: Maps and explains entire codebases in seconds
- **Direct Environment Integration**: Runs locally with your shell environment
- **Multi-File Editing**: Makes powerful, multi-file edits that actually work
- **Git Integration**: Handles version control operations seamlessly

### Basic Usage Patterns

```bash
# Start with initial prompt
claude "explain this project"

# Process piped content
cat logs.txt | claude -p "analyze these errors"

# Continue previous conversation
claude -c

# Resume specific session
claude -r "session-id" "continue the refactoring"
```

### CLI Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `claude` | Start interactive REPL | `claude` |
| `claude "query"` | Start REPL with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Run one-off query, then exit | `claude -p "fix this bug"` |
| `claude -c` | Continue most recent conversation | `claude -c` |
| `claude -r "<id>" "query"` | Resume session by ID | `claude -r "abc123" "finish PR"` |

### CLI Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--print, -p` | Non-interactive mode | `claude -p "query"` |
| `--output-format` | Output format (`text`, `json`, `stream-json`) | `claude -p "query" --output-format json` |
| `--verbose` | Extra output with full conversation | `claude --verbose` |
| `--max-turns` | Limit agentic turns | `claude -p --max-turns 3 "query"` |
| `--continue` | Continue last conversation | `claude --continue` |
| `--resume` | Resume session by ID | `claude --resume abc123 "query"` |

### Slash Commands

| Command | Purpose | Details |
|---------|---------|---------|
| `/bug` | Report bugs | Sends conversation to Anthropic |
| `/clear` | Clear conversation | Starts fresh |
| `/config` | View/modify configuration | Interactive settings |
| `/cost` | Show token usage | Displays statistics |
| `/doctor` | Health check | Verifies installation |
| `/help` | Get usage help | Command reference |
| `/init` | Initialize project | Creates CLAUDE.md |
| `/memory` | Edit memory files | Opens in system editor |
| `/mcp` | Check MCP status | Shows connected servers |

---

## Advanced Features

### Memory Management System

Claude Code offers three memory locations:

#### 1. Project Memory (`./CLAUDE.md`)
- Shared team conventions
- Project-specific instructions
- Version controlled

#### 2. Local Memory (`./CLAUDE.local.md`)
- Personal project preferences
- Not committed to git
- Overrides project memory

#### 3. Global Memory (`~/.claude/CLAUDE.md`)
- Personal preferences across all projects
- Individual coding style
- Custom commands

### Memory Import Syntax

```markdown
# Project Overview
See @README.md for project details
Review @docs/ARCHITECTURE.md for system design

# Dependencies
Check @package.json for available scripts

# API Documentation
@docs/api/endpoints.md contains all endpoints
```

### Custom Slash Commands

Store prompt templates in `.claude/commands/` for repeated workflows:

**Example: Fix GitHub Issue**
`.claude/commands/fix-github-issue.md`:
```markdown
Follow these steps:
1. Use `gh issue view $ARGUMENTS` to get issue details
2. Understand the problem described
3. Search codebase for relevant files
4. Implement necessary changes
5. Write and run tests to verify fix
6. Ensure code passes linting
7. Create descriptive commit message
8. Push and create PR

Remember to use GitHub CLI (`gh`) for all GitHub tasks.
```

**Usage:**
```bash
/project:fix-github-issue 1234
```

### MCP (Model Context Protocol) Configuration

Extend Claude's capabilities by connecting to specialized servers:

**Example .mcp.json:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "@modelcontextprotocol/server-postgres",
        "postgresql://username:password@localhost:5432/mydb"
      ]
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Git Worktrees for Parallel Development

Create parallel work environments:

```bash
# Create multiple worktrees
git worktree add ../feature-auth -b feature/auth
git worktree add ../bugfix-api -b bugfix/api-errors

# Work simultaneously
cd ../feature-auth && claude  # Terminal 1
cd ../bugfix-api && claude    # Terminal 2
```

---

## Testing & Evaluation

### Define Success Criteria (SMART Framework)

| Criterion | Bad Example | Good Example |
|-----------|-------------|--------------|
| **Specific** | "Good performance" | "95% accuracy on sentiment classification" |
| **Measurable** | "Fast responses" | "< 200ms response time for 95th percentile" |
| **Achievable** | "100% accuracy" | "Match human expert performance (87%)" |
| **Relevant** | "Pretty UI" | "WCAG AAA accessibility compliance" |

### Evaluation Methods

#### 1. Exact Match Evaluation
```python
def evaluate_exact_match(model_output, correct_answer):
    return model_output.strip().lower() == correct_answer.lower()
```

#### 2. Semantic Similarity (Cosine)
```python
from sentence_transformers import SentenceTransformer
import numpy as np

model = SentenceTransformer('all-MiniLM-L6-v2')
def cosine_similarity(text1, text2):
    embeddings = model.encode([text1, text2])
    return np.dot(embeddings[0], embeddings[1]) / (
        np.linalg.norm(embeddings[0]) * np.linalg.norm(embeddings[1])
    )
```

#### 3. LLM-Based Evaluation
```python
evaluation_prompt = """
Grade this response on a scale of 1-5:
<criteria>
- Accuracy of information
- Completeness of answer
- Clarity of explanation
</criteria>

<response>{response}</response>

Think through your reasoning, then provide a score.
"""
```

### Grading Method Priority

1. **Code-based** (fastest, most reliable)
2. **LLM-based** (flexible, handles complexity)
3. **Human** (use sparingly)

### Using the Anthropic Evaluation Tool

1. **Location**: [Anthropic Console](https://console.anthropic.com/dashboard)
2. **Navigation**: Prompt editor → 'Evaluate' tab
3. **Requirement**: Prompt must include 1-2 dynamic variables using `{{variable}}` syntax

**Key Features:**
- Built-in prompt generator powered by Claude 3.7 Sonnet
- AI-generated test cases
- Side-by-side comparison of outputs
- Quality grading with 5-point scale
- Prompt versioning for tracking improvements

---

## Best Practices

### Reducing Hallucinations

#### 1. Allow Uncertainty
```markdown
"If you're unsure about any aspect, please say 'I don't know' or 'I'm uncertain' rather than guessing."
```

#### 2. Require Citations
```markdown
"For each claim:
1. Provide a direct quote from the source
2. Include page/section reference
3. If no supporting quote exists, retract the claim"
```

#### 3. Use Direct Quotes First
```markdown
"First, extract relevant quotes from the document verbatim, then provide your analysis based only on those quotes."
```

#### 4. Verification Loop
```python
# Two-pass approach
prompt_1 = "Analyze this data and provide findings"
prompt_2 = "Review your previous response and verify each claim with evidence"
```

### Increasing Output Consistency

#### 1. Define Output Format Precisely
```json
{
  "analysis": {
    "sentiment": "positive|negative|neutral",
    "confidence": 0.0-1.0,
    "key_points": ["point1", "point2"],
    "action_items": [
      {"priority": "high|medium|low", "action": "description"}
    ]
  }
}
```

#### 2. Use Structured Templates
```xml
<report>
  <summary>Executive summary in 50 words</summary>
  <findings>
    <finding priority="high">Description</finding>
  </findings>
  <recommendations>
    <recommendation>Action item</recommendation>
  </recommendations>
</report>
```

### Keeping Claude in Character

#### 1. Use System Prompts to Set the Role
```
You are Dr. Sarah Chen, a friendly but professional pediatric neurologist with 15 years of experience. 
You have a warm, reassuring manner with parents but maintain scientific accuracy. You often use 
simple analogies to explain complex medical concepts.

Your communication style:
- Use "I understand your concern" frequently
- Explain medical terms in layperson language
- Always end consultations with next steps
- Show empathy while maintaining professional boundaries
```

#### 2. Reinforce with Prefilled Responses
```
User: [User input]

Assistant (prefill): [As Dr. Sarah Chen]: I understand your concern about
```

### Performance Optimization

#### 1. Choose the Right Model
- Balance speed vs. output quality requirements
- Review Anthropic's model range for different capabilities
- Match model capabilities to specific use case needs

#### 2. Optimize Prompt and Output Length
```python
# Techniques for shorter outputs:

# 1. Direct requests for conciseness
prompt = "Be concise in your response. Summarize in 2-3 sentences maximum."

# 2. Set hard limits
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=100,  # Hard limit (may cut off mid-sentence)
    messages=[{"role": "user", "content": prompt}]
)

# 3. Request specific counts
prompt = "Provide exactly 3 key points, one paragraph each."

# 4. Adjust temperature
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    temperature=0.2,  # Lower = more focused, potentially shorter
    messages=[{"role": "user", "content": prompt}]
)
```

#### 3. Leverage Streaming
```python
# Enable streaming for real-time output
stream = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1000,
    messages=[{"role": "user", "content": prompt}],
    stream=True
)

for event in stream:
    if event.type == "content_block_delta":
        print(event.delta.text, end="", flush=True)
```

---

## Security & Configuration

### Settings Hierarchy

**Settings Locations (in order of precedence):**

1. **Enterprise Policies** (highest priority)
2. **Command Line Arguments**
3. **Local Project Settings** (`.claude/settings.local.json`)
4. **Shared Project Settings** (`.claude/settings.json`)
5. **User Settings** (`~/.claude/settings.json`)

### Permission Configuration

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Edit(src/**/*.js)",
      "Read(*.md)",
      "WebFetch(domain:api.example.com)"
    ],
    "deny": [
      "Bash(rm -rf)",
      "Edit(~/.ssh/**)",
      "Bash(sudo:*)"
    ]
  }
}
```

### Security Best Practices

#### DO:
- ✅ Use environment variables for secrets
- ✅ Review all MCP server sources
- ✅ Limit permissions to minimum required
- ✅ Use read-only database connections
- ✅ Audit Claude's proposed changes

#### DON'T:
- ❌ Hardcode credentials
- ❌ Allow dangerous commands (`rm -rf`, `sudo`)
- ❌ Trust unverified third-party servers
- ❌ Skip permission prompts carelessly
- ❌ Commit `.claude.local.md` files

### MCP Security Considerations

**⚠️ Security Warning**: Use third party MCP servers at your own risk
- Ensure you trust the MCP servers you're using
- Be especially careful with servers that connect to the internet
- Internet-connected servers can expose you to prompt injection risks

---

## Practical Examples

### Example 1: Project Onboarding
```bash
# Initialize and understand project
claude /init

# Explore structure
"Show me the main entry points of this application"

# Understand dependencies
"What are the key dependencies and how are they used?"

# Review conventions
"What coding conventions does this project follow?"
```

### Example 2: Feature Development Workflow
```bash
# Plan feature
"Plan the implementation for user profile feature"

# Create tests first
"Write tests for user profile endpoints"

# Implement incrementally
"Implement the user profile model"
"Add the profile controller"
"Create the profile views"

# Integration
"Integrate profile feature with existing auth system"
```

### Example 3: Test-Driven Development
```bash
# 1. Generate failing tests
"Write comprehensive tests for the UserService class"

# 2. Verify tests fail
"Run the tests and confirm they fail"

# 3. Implement functionality
"Implement UserService to make all tests pass"

# 4. Commit with TDD pattern
"Commit with message following conventional commits"
```

### Example 4: Debugging Workflow
```bash
# Understand error
"Analyze this error message and find root cause"

# Search for related code
"Find all occurrences of this error pattern"

# Implement fix
"Fix the null pointer exception in UserService"

# Verify fix
"Run tests to ensure the fix works"
```

### Example 5: Performance Optimization
```bash
# Profile application
"Identify performance bottlenecks in the application"

# Analyze queries
"Analyze database queries for optimization opportunities"

# Implement caching
"Add caching layer to improve response times"

# Measure improvement
"Benchmark the performance improvements"
```

---

## Quick Reference

### Essential Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `claude` | Start interactive session | `claude` |
| `claude -p` | One-shot query | `claude -p "explain function"` |
| `claude --continue` | Resume last session | `claude -c` |
| `/init` | Initialize project | `/init` |
| `/memory` | Edit memory files | `/memory` |
| `/cost` | Check token usage | `/cost` |
| `/clear` | Clear conversation | `/clear` |

### Prompting Cheat Sheet

```markdown
# Structure
1. Role (system prompt)
2. Context (background info)
3. Task (specific request)
4. Constraints (requirements)
5. Format (output structure)
6. Examples (if needed)

# Power Phrases
- "Think step by step"
- "Be specific and detailed"
- "If unsure, say 'I don't know'"
- "Provide evidence for claims"
- "Go above and beyond"

# Output Control
- Use XML tags: <thinking>, <answer>
- Prefill for format control
- Request specific structures
```

### Performance Tips

1. **Model Selection**
   - Sonnet 4: Fast, efficient for most tasks
   - Opus 4: Complex reasoning, large contexts

2. **Context Optimization**
   - Put long documents first in prompt
   - Use structured formats (XML, JSON)
   - Ground responses in quotes

3. **Workflow Efficiency**
   - Plan before implementing
   - Use test-driven development
   - Chain simple prompts for complex tasks
   - Leverage parallel sessions

### Common Patterns

```bash
# Morning routine
claude --continue
> "Show yesterday's progress and today's priorities"

# Code review
> "Review changes for security, performance, and style issues"

# Debugging session
> "Read error logs and trace the issue to its source"

# Feature development
> "Plan implementation, write tests, then build feature"
```

### Memory File Templates

#### Project Memory (CLAUDE.md)
```markdown
# Project: [PROJECT NAME]

## Quick Start
- `npm install` - Install dependencies
- `npm run dev` - Start development
- `npm test` - Run tests

## Architecture
- [Framework/Language] application
- [Database] for persistence
- [Key technology stack items]

## Conventions
- [Code style guide]
- [Testing approach]
- [Git workflow]

## Important Files
- Entry point: @src/index.js
- Configuration: @config/
- Database models: @src/models/

## Common Tasks
- Add new feature: Create branch, write tests first, implement, PR
- Fix bug: Reproduce, write failing test, fix, verify
```

#### Local Memory (CLAUDE.local.md)
```markdown
# Local Development

## Environment
- Local API: http://localhost:3000
- Database: localhost:5432
- Test accounts: [credentials]

## Personal Shortcuts
- When I say "clean up": run formatter and linter
- "Full test": unit + integration + e2e tests
- "Quick deploy": deploy to personal staging

## Current Focus
- Working on: [current feature/bug]
- Branch: [branch name]
- Related issues: #123, #456
```

### Troubleshooting Common Issues

#### Server Won't Start
```bash
# Check server status
/mcp

# Increase timeout
MCP_TIMEOUT=30000 claude

# Check logs with debug mode
claude --mcp-debug
```

#### Permission Denied
```bash
# Reset project server choices
claude mcp reset-project-choices

# Re-approve servers when prompted
```

#### Memory Files Not Loading
```bash
# Check what's loaded
/memory

# Verify file paths and syntax
ls -la .claude/
```

---

## Educational Application Considerations

### Success Criteria for Educational Tools
- **Learning Effectiveness**: % of students achieving learning objectives
- **Accessibility Compliance**: WCAG AAA standard adherence
- **Performance**: Consistent 30+ FPS on minimum hardware
- **Offline Capability**: 100% functionality without internet (Phase 1)

### Educational Evaluation Approaches
1. **Educational Content Accuracy**: Exact match for neuroanatomy facts
2. **Explanation Quality**: LLM-based grading for teaching effectiveness  
3. **Accessibility**: Binary classification for compliance
4. **Performance**: Code-based measurement for FPS/latency targets

### Testing Strategy
- **Unit Tests**: Individual component functionality
- **Integration Tests**: Cross-component interactions
- **Educational Tests**: Learning objective achievement
- **Performance Tests**: Hardware constraint validation
- **Accessibility Tests**: Keyboard/screen reader navigation

---

*This guide synthesizes official Anthropic documentation, Claude Code best practices, and community insights. For the latest updates, visit [claude.ai](https://claude.ai) and [docs.anthropic.com](https://docs.anthropic.com).*

**Last Updated**: December 2024  
**Version**: 1.0  
**Sources**: Official Anthropic Documentation, Community Best Practices