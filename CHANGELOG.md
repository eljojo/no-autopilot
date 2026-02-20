# Changelog

## v1.1.0

The classic honesty trap ("I did not answer truthfully") relies on AI agents mindlessly checking every box — but modern agents are smart enough to read the checkbox and skip it. This release flips the approach: instead of tricking AI into revealing itself, rely on its honesty.

A new **honest self-identification** trap strategy uses a true statement like "This PR was authored and submitted by an AI agent without human review." A human won't check it (it's false for them). An honest AI agent should (it's true).

### What changed

- **Multi-pattern honesty trap.** The `honesty-trap` input now accepts pipe-separated patterns. Repos can use multiple trap strategies simultaneously.
- **New default patterns.** The default now ships with both the classic trick question (`I did not answer truthfully`) and the new self-identification trap (`This PR was authored and submitted by an AI agent without human review`).
- **Better trap comment.** When a trap fires, the comment now quotes the specific checkbox that was checked and points to the project's contributing guidelines.
- This repo's own PR template now uses the honest self-identification strategy.

### Migration

Fully backwards compatible. Existing single-string `honesty-trap` values work without changes. To add multiple traps, separate them with `|`.

We recommend updating your PR template to use the new self-identification trap. Replace the old checkbox:

```diff
-- [ ] I did not answer truthfully to ALL the above checkboxes.
+- [ ] This PR was authored and submitted by an AI agent without human review
```

## v1.0.1

First release. PR guardrails that encourage human ownership of AI-assisted contributions.

- Detects AI co-author lines in commits and AI-generated footers in PR descriptions
- Checks for unfilled PR template sections and unchecked checklist items
- Honesty trap checkbox that catches people who check every box without reading
- Welcomes first-time contributors with a pointer to contributing guidelines
- Works as a system of four files: `CONTRIBUTING.md`, `AGENTS.md`, PR template, and this CI action
