# plugin-packager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Convert Claude Code skill repositories into dual-distributable packages (Plugin + Agent Skills).

**[日本語版 README はこちら](README.ja.md)**

## Why plugin-packager?

There are multiple ways to distribute Claude Code skills, and the same evaluation happens every session with inconsistent conclusions:

- `/plugin install` (Anthropic official) — distributes skills + commands + hooks as a package
- `npx skills add` (Vercel Agent Skills) — skills only, no commands/hooks
- `install.sh` (legacy) — git clone + shell script copy

**plugin-packager** unifies the decision criteria and automates the structural conversion.

## What It Does

1. **Scans** your repository for skills, commands, hooks, and existing manifests
2. **Analyzes** the component composition and recommends the optimal distribution method
3. **Converts** the directory structure to be Plugin-compatible (`skills/`, `commands/` at root)
4. **Generates** `plugin.json`, `marketplace.json`, and install section for README
5. **Reports** compatibility status for both Plugin and Agent Skills

### Distribution Decision Matrix

| Components Found | Recommended Method |
|---|---|
| skills only | Agent Skills (`npx skills add`) as primary |
| skills + commands | Plugin (`/plugin install`) recommended |
| skills + commands + hooks | Plugin required |
| hooks only | Plugin required |

## Installation

### As a Plugin (Recommended)

```
# Add marketplace
/plugin marketplace add hummer98/plugin-packager

# Install
/plugin install plugin-packager@hummer98-plugins
```

### Skills Only (via Agent Skills)

```bash
npx skills add hummer98/plugin-packager
```

> **Note**: This installs skills only (no `/package` slash command). You can still use the skill via natural language (e.g. "package this repo for distribution"), but the `/package` command won't be available. Use the plugin install above for the full experience.

### Manual Install (Legacy)

```bash
git clone https://github.com/hummer98/plugin-packager.git
cd plugin-packager
./install.sh
```

```bash
# Check installation status
./install.sh --check

# Uninstall
./install.sh --uninstall
```

## Usage

### Quick Start

Run the `/package` command in any Claude Code skill repository:

```
You:    /package
Claude: Scanning repository...

        === Repository Analysis ===

        Components:
          [found] skills/my-skill/SKILL.md (frontmatter: OK)
          [found] .claude/commands/my-cmd.md (needs migration)
          [not found] hooks/

        Recommended: Plugin (/plugin install) — commands detected

        Proceed with conversion? (y/n)

You:    y
Claude: Converting...
        ✓ Moved .claude/commands/my-cmd.md → commands/my-cmd.md
        ✓ Generated .claude-plugin/plugin.json
        ✓ Generated .claude-plugin/marketplace.json
        ✓ Updated README.md install section

        === Compatibility Report ===
        Plugin:       OK
        Agent Skills: Partial (commands not distributed)
```

### Natural Language

You don't need the slash command. Just describe what you want:

```
You: Package this repo for plugin distribution
You: Check if this repo is distributable as an Agent Skill
You: Convert .claude/skills to plugin structure
```

### Options

- `/package --dry-run` — Analyze only, no changes
- `/package --force` — Convert without confirmation
- `/package hummer98/my-plugin` — Specify owner/repo explicitly

## What Gets Generated

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin manifest (name, version, paths) |
| `.claude-plugin/marketplace.json` | Marketplace catalog entry |
| `install.sh` | Legacy installer (copy to `~/.claude/`) |
| README install section | 3-tier installation instructions |

## Repository Structure

```
plugin-packager/
├── .claude-plugin/
│   ├── plugin.json             # Plugin manifest
│   └── marketplace.json        # Marketplace catalog
├── skills/
│   └── plugin-packager/
│       └── SKILL.md            # Packaging knowledge & procedures
├── commands/
│   └── package.md              # /package slash command
├── install.sh                  # Legacy installer
├── CLAUDE.md                   # Development guide
├── LICENSE                     # MIT
├── README.md                   # English
└── README.ja.md                # Japanese
```

## License

MIT License — see [LICENSE](LICENSE) for details.
