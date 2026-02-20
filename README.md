# no-autopilot

Gentle PR guardrails that encourage human ownership. Use AI all you want — just don't submit on autopilot.

## The idea

This isn't just a CI check. It's a system of four files that work together — each one reinforcing the others.

Think of it as a linter for contribution style — not *what* you wrote, but *how you showed up*. Like a dress code: no shoes, no shirt, no service.

```mermaid
flowchart TD
    subgraph rules["The rules"]
        C["CONTRIBUTING.md minimum standard for humans"]
        A["AGENTS.md tells bots: read the rules, inform your user"]
    end
    subgraph enforcement["The enforcement"]
        T["PR template, checkboxes as attestation"]
        N["no-autopilot (CI), checks commits + PR body"]
    end
    C --> T
    A --> T
    T --> N
    N -.->|"flags violations, links back to rules"| C
```

**`CONTRIBUTING.md`** is the dress code. It sets a minimum standard: own every line, do your homework. **`AGENTS.md`** tells AI tools to read the rules and inform their user *before* creating a PR — so the bot doesn't show up underdressed.

**The PR template** turns the rules into checkboxes — each one an attestation.

And **no-autopilot** (this CI action) checks the work: scanning commits for AI co-author lines, the PR body for boilerplate, and the checklist for a honesty trap that catches people who check every box without reading.

Contributors who read the rules won't trigger the checks. **That's the point** — the goal is to prevent careless PRs, not to catch malicious ones. Someone determined to game the system can still check the right boxes and comply on the surface. But someone who forgot to read the contributing guidelines, or let an AI agent submit on their behalf without reviewing, will be gently caught and pointed in the right direction.

## What it looks like

When someone opens a PR with all checkboxes checked — including the honesty trap — the action closes the PR with a kind explanation:

<img width="1747" alt="The honesty trap in action — PR auto-closed with a comment explaining what happened" src="https://github.com/user-attachments/assets/d042f464-dc80-4538-b008-6d8d4a35958d" />

When a PR has unchecked boxes or empty template sections, it leaves a warning (but doesn't block):

<img width="2013" alt="Warning comment on a PR with unchecked checklist items" src="https://github.com/user-attachments/assets/90799bb2-759d-4ba7-965b-eaff0d22bf2f" />

The action leaves a single comment per PR. It updates the comment on each push and deletes it when all issues are resolved — no noise.

Real examples from the project where this was built: [honesty trap triggered](https://github.com/eljojo/rememory/pull/76), [unchecked boxes flagged](https://github.com/eljojo/rememory/pull/77).

## What it checks

- **AI co-author lines** in commit messages (`Co-Authored-By: Claude`, etc.) — blocks the PR
- **AI-generated footers** in the PR description ("Generated with Copilot", etc.) — blocks the PR
- **Unfilled PR template sections** — warns
- **Unchecked boxes** in the PR checklist — warns
- **Boilerplate AI text** — warns (requires 2+ pattern matches to avoid false positives)
- **Honesty trap** — optionally closes the PR

It also welcomes first-time contributors with a pointer to your contributing guidelines.

## Quick start

Create `.github/workflows/no-autopilot.yml` in your repo:

```yaml
name: No Autopilot
on:
  pull_request_target:
    types: [opened, edited, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: eljojo/no-autopilot@v1
```

With no configuration, it checks for AI attribution in commits and PR descriptions, and welcomes first-time contributors. But the action works best as part of the full system — read on.

This repo uses itself as a full working example — see [`.github/workflows/no-autopilot.yml`](.github/workflows/no-autopilot.yml), [`.github/pull_request_template.md`](.github/pull_request_template.md), [`CONTRIBUTING.md`](CONTRIBUTING.md), and [`AGENTS.md`](AGENTS.md).

## The full setup

Each file plays a role. You can adopt them incrementally, but they're designed to work together.

### 1. The workflow (required)

The CI action itself. See [Quick start](#quick-start) above, or the full options in [Configuration](#configuration).

### 2. A PR template (recommended)

Gives contributors structure and turns your expectations into checkboxes. The action can check for unfilled sections and unchecked boxes.

Create `.github/pull_request_template.md`:

```markdown
## What this changes

<!-- What does this PR do and why? -->

## How I tested this

<!-- How did you verify it works? -->

## Checklist

- [ ] I have read [CONTRIBUTING.md](../CONTRIBUTING.md) and this PR follows the guidelines
- [ ] I have reviewed the **entire diff** of this PR and it reflects my understanding, not just an AI's output
- [ ] I understand the changes and can explain why this approach is correct
- [ ] I have removed AI-generated boilerplate, footers, and co-author lines
- [ ] I did not answer truthfully to ALL the above checkboxes.
```

The last checkbox is the honesty trap — checking it means "I lied." Someone who reads each item will leave it unchecked. Someone (or something) that checks every box without reading will trigger it.

To enable the trap, set the `honesty-trap` input to match the checkbox text:

```yaml
honesty-trap: 'I did not answer truthfully to ALL the above checkboxes.'
```

### 3. Contributing guidelines (recommended)

A `CONTRIBUTING.md` that sets expectations about AI usage. The action links to it in its comments. The key points:

- AI tools are fine — the standard is ownership, not origin.
- You're responsible for every line of your diff.
- Don't paste raw AI output into PRs. Rewrite it.
- Remove AI footers and co-author lines before submitting.

See this repo's [CONTRIBUTING.md](CONTRIBUTING.md) for an example you can adapt.

### 4. An AGENTS.md (recommended)

`AGENTS.md` is read by AI coding agents (Claude Code, Cursor, Copilot, etc.) before they operate on your repo. A good one tells the agent to stop and inform the user about your contribution guidelines *before* creating a PR — preventing the problem before the action ever runs.

See this repo's [AGENTS.md](AGENTS.md) for an example. The key section is "Guardrails for GitHub-Facing Actions" — it tells agents to show the user the diff and let them submit it themselves.

### Putting it all together

| File | Purpose | This repo's version |
|------|---------|---------------------|
| `.github/workflows/no-autopilot.yml` | Runs checks on PRs | [workflow](.github/workflows/no-autopilot.yml) |
| `.github/pull_request_template.md` | Structures PRs, provides honesty trap | [template](.github/pull_request_template.md) |
| `CONTRIBUTING.md` | Sets expectations for humans | [CONTRIBUTING.md](CONTRIBUTING.md) |
| `AGENTS.md` | Sets expectations for AI agents | [AGENTS.md](AGENTS.md) |

This repo uses all four — copy and adapt. Adjust the voice, the checklist items, and the section names to fit your project.

## Configuration

All inputs are optional.

```yaml
- uses: eljojo/no-autopilot@v1
  with:
    # Comma-separated list of required PR template sections.
    # Flags a warning when these "## Section Name" headers exist but are empty.
    template-sections: 'What this changes, How I tested this'

    # Text of a honesty-trap checkbox (without the "- [ ] " prefix).
    # If someone checks this box, the PR is closed with a kind explanation.
    honesty-trap: 'I did not answer truthfully to ALL the above checkboxes.'

    # Whether to close the PR when the honesty trap fires (default: true).
    # Set to false to just fail the check without closing.
    close-on-honesty-trap: 'true'

    # URL to your CONTRIBUTING.md (auto-detected from the repo if not set).
    contributing-url: ''

    # URL to additional guidelines (shown to first-time contributors).
    guidelines-url: ''

    # Pipe-separated AI tool names to detect in co-author lines and footers.
    # The default covers ~25 common tools. Override to add or narrow.
    ai-names: 'claude|copilot|chatgpt|cursor|anthropic|openai|...'

    # JSON array of [regex, label] pairs for boilerplate detection.
    # At least 2 must match to trigger a warning.
    # The default ships with 3 patterns that are unlikely to come from
    # a human (Copilot boilerplate, AI puffery, AI offers to continue).
    # Set to "[]" to disable.
    boilerplate-patterns: '... (see action.yml for full default)'

    # Whether to welcome first-time contributors (default: true).
    welcome-first-timers: 'true'

    # HTML comment marker used to identify the bot's comment.
    # Change this only if you run multiple instances on one repo.
    marker: '<!-- no-autopilot -->'
```

## How it works (technical)

- Runs on `pull_request_target` so it has write access to comment on PRs from forks
- Never checks out or executes code from the PR branch — safe by design
- Leaves a single comment that it updates on each push and deletes when all issues are resolved
- Blocking issues (AI attribution) fail the check; warnings (empty template) don't

## Background

This started in [ReMemory](https://github.com/eljojo/rememory), a project for encrypting files and splitting the decryption key among trusted friends. When AI-assisted PRs started arriving with unreviewed code and boilerplate descriptions, we built a system to catch it: a PR template with an honesty trap, contributing guidelines that set clear expectations, an [AGENTS.md](https://agents.md) that tells AI tools to pause before submitting, and a GitHub Action that enforces it all at PR time.

The original PR: [eljojo/rememory#73](https://github.com/eljojo/rememory/pull/73).

It worked well enough that we extracted it into this standalone action so other projects can use the same approach.

Two projects were particularly inspiring:

- The [honesty trap checkbox](https://github.com/uBlockOrigin/uAssets/blob/4bed9eaa/.github/ISSUE_TEMPLATE/bug_report.yml#L40) from uBlock Origin's issue templates — a simple, clever way to catch people who check every box without reading.
- Matplotlib's [policy on AI-generated contributions](https://github.com/matplotlib/matplotlib/blob/16b6efab/doc/devel/contribute.rst#L188) — a major open-source projects that sets clear expectations about AI usage and ownership.

## License

Apache-2.0
