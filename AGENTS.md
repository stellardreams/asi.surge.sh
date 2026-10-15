# AGENTS.md — working rules for this repository

Operational rules for any AI agent or human contributor working in `asi.surge.sh`.
These exist because they were learned the hard way. Where one of these rules
conflicts with a general habit, this file wins.

---

## 🚨 Protected branches — never delete

**`master`, `main`, and `main-dev` are permanent. Never delete them, in any
circumstance, on any branch operation.**

### Why this rule exists

On 2026-10-15, a PR was opened from `main-dev` into `master` and merged with
`gh pr merge --delete-branch`. GitHub deleted the PR's head branch — which was
`main-dev`. That silently removed the staging branch the entire branching
workflow depends on. The mistake was invisible: the merge reported success and
CI was green. It was only caught by explicitly listing remote branches
afterwards.

Every later session would have started at workflow Step 1 and either stalled on
a missing `main-dev` or, worse, invented a substitute branch.

### The indirect-deletion trap

`--delete-branch` is the dangerous flag, not `git branch -D`. GitHub deletes
whatever branch the PR's head points at.

| Situation | Safe? |
|---|---|
| `gh pr merge 93 --delete-branch` where head is `fix/foo` | ✅ yes, throwaway branch |
| `gh pr merge 93 --delete-branch` where head is `main-dev` | ❌ **never** |
| `gh pr merge 93 --delete-branch` where head is `master` | ❌ **never** |
| `git branch -d <protected>` | ❌ **never** |

### Rules

1. **Check the PR head before merging.** If it is `master`, `main`, or
   `main-dev`, omit `--delete-branch` entirely.
2. **After any merge that used `--delete-branch`, verify:**
   ```bash
   gh api repos/stellardreams/asi.surge.sh/branches --jq '.[].name'
   ```
   All three protected branches must still be present.
3. **`--delete-branch` is only ever for throwaway branches** — `feat/*`,
   `fix/*`, `docs/*`, `ci/*` — and only once merged.
4. **Never substitute another branch** for a missing protected one. Stop and
   ask.

### Recovery

```bash
git push origin main-dev:refs/heads/main-dev      # restore the branch
git checkout main-dev
git reset --hard origin/master                    # squash-merge left it diverged
git push --force-with-lease origin main-dev       # resync
```

Use `--force-with-lease`, never bare `--force`.

---

## Verification gate — nothing gets checked off without proof

Applies to issue bodies, comments, and any checklist.

An item may only change `- [ ]` → `- [x]` when **concrete execution or tool
verification happened in the session**: command output observed, tests run, file
inspected on disk, API response confirmed.

Never check off an item because it looks done, because a comment claims it was
done, or because of a blanket instruction like "mark them all done". A stale
claim in an old comment is not evidence.

**User-owned items** — anything requiring Adeel's MetaMask, private key, funds,
credentials, or manual approval — may only be checked off when Adeel explicitly
names that specific item. Never under a general completion request.

A checklist ledger is an *auditing* tool. It reports truth. It never justifies
marking anything complete.

---

## Verify before asserting

Check the actual artifact, not your memory of it.

- Claims about a library's API → read the installed package or its types.
- Claims about a file → read it.
- Claims about CI → read the run.

When a claim is wrong, say so plainly and correct it in the same breath. An
unretracted wrong claim is worse than no claim.

---

## Secrets

No key, mnemonic, or RPC credential is ever committed. Deployment secrets are
read from the environment (`PRIVATE_KEY`, `BSC_TESTNET_RPC_URL`) so that CI
stays green without them. If `.env` is absent, config must degrade to a working
read-only state rather than crash.

---

## Commit messages

Say what was wrong, what the evidence was, and what you could not verify.
Record mistaken earlier claims explicitly — the correction is the useful part.

A useful message answers: *what was broken, how do I know, what did you check,
and what remains unproven?*