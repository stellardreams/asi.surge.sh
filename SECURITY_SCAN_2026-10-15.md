# Security Scan Report - asi.surge.sh
**Date:** 2026-10-15
**Scope:** npm dependency review (Dependabot + `npm audit`) following restoration of the Token Contract CI workflow

---

## Executive Summary
All dependency alerts with a patched version available upstream have been resolved. **Both critical advisories are closed.** Four alerts remain open and **cannot be closed by any upgrade** — each one's latest published release is itself still vulnerable, or the advisory has no patch at all.

**Status: no critical alerts open. 2 high, 1 medium, 1 low remain, all blocked upstream.**

---

## ✅ RESOLVED

| advisory | severity | package | resolution |
|---|---|---|---|
| GHSA-p8wg-vrv2-v86f | critical | handlebars | 4.7.9 → 4.7.10 (PR #89) |
| GHSA-8r5x-fm3f-whwj | critical | handlebars | 4.7.9 → 4.7.10 (PR #89) |
| GHSA-xw65-4hp5-5hc7 | medium | handlebars | 4.7.9 → 4.7.10 (PR #89) |
| GHSA-vrf4-mx87-p53w | high | @libp2p/peer-store | Dependabot bump (PR #90) |
| GHSA-32mq-hpph-xfvr | high | @libp2p/kad-dht | Dependabot bump (PR #91) |
| GHSA-96hv-2xvq-fx4p | high | ws | 8.18.0 → 8.22.0 via override (PR #92) |
| GHSA-58qx-3vcg-4xpx | medium | ws | 8.18.0 → 8.22.0 via override (PR #92) |
| GHSA-5c6j-r48x-rmvq | high | serialize-javascript | 6.0.2 → 7.1.2 via override (PR #92) |
| GHSA-qj8w-gfj5-8c6v | medium | serialize-javascript | 6.0.2 → 7.1.2 via override (PR #92) |

### Why `overrides` rather than a `mocha` bump
`ws` and `serialize-javascript` are both transitive. `mocha` 12 would pull
`serialize-javascript@7` legitimately, but `mocha` is pinned to `^10.2.0` by both
`eth-gas-reporter` and `solidity-coverage`, so bumping it would violate two Hardhat
plugin ranges. Overriding the leaf dependency is the smaller, safer change.

Compatibility was verified rather than assumed. `serialize-javascript` 6 and 7 both
export a single function via `module.exports`, not an object exposing
`.serialize`/`.deserialize`. `mocha` invokes it directly at
`lib/nodejs/buffered-worker-pool.js:162`, so the forced major bump is API-compatible.
Confirmed by round-tripping an options object through the installed 7.1.2.

---

## ⚠️ OPEN — NO UPSTREAM PATCH AVAILABLE

These are **not** neglected findings. Each was checked against the GitHub advisory
database; `first_patched_version` is `null` in every case.

| advisory | severity | package | vulnerable range | installed | latest release | blocked because |
|---|---|---|---|---|---|---|
| GHSA-vfj7-8cjw-p6xm | high | braces | ≤ 3.0.3 | 3.0.3 | 3.0.3 | installed **is** the latest release |
| GHSA-86w9-cpqp-85rv | high | node-forge | ≤ 1.4.0 | 1.4.0 | 1.4.0 | no patched version published |
| GHSA-hp3w-g68c-fv3c | medium | sprintf-js | ≤ 1.1.3 | 1.0.3 | 1.1.3 | the latest release is itself vulnerable |
| GHSA-848j-6mx2-7j84 | low | elliptic | ≤ 6.6.1 | 6.6.1 | 6.6.1 | installed **is** the latest release |

### Reachability
None of these are direct dependencies. They arrive through the Hardhat plugin chain:

- `sprintf-js` ← `argparse` ← `js-yaml` ← `sc-istanbul` (coverage tooling)
- `node-forge`, `braces`, `elliptic` ← hardhat's own dependency tree

All are **build-time**. They are not present in published site assets, and the
deployed output is static HTML/CSS/JS. Exploitability from a deployed artefact is
therefore low, though `serialize-javascript`'s RCE class is worth noting as a
pattern to watch for if any of these packages later reach a runtime path.

### Recommended handling
**Leave these alerts open.** They are accurate: the code is genuinely running
vulnerable versions. Closing them as "not affected" or "tolerable risk" would
suppress a true signal and make the report look cleaner than reality.

Re-check on each release. When upstream ships patches, the alerts will reopen as
fixable and should be resolved the same way as the table above.

---

## 🔍 RELATED FINDINGS — CI availability

Independent of dependencies, the Token Contract CI workflow had been non-functional
since 2026-04-16 and had never surfaced any of the above. Five distinct causes were
found and fixed:

1. Trigger filter set to `main` while the default branch is `master`
2. `actions/upload-artifact@v3` — retired by GitHub in January 2025
3. `actions/checkout@v3` and `setup-node@v3` — Node 20 forced-migration
4. `node-version: '18'` — Hardhat 3 requires ≥ 22.13.0
5. `package-lock.json` excluded by `.gitignore`, so `npm ci` and `cache: npm` could not resolve

Plus a sixth surfaced once CI ran: `hardhat.config.cjs` is invisible to Hardhat 3,
which recognises only `hardhat.config.js` and `hardhat.config.ts`. The project was
running Hardhat ^3.4.1 with a Hardhat 2 config.

Until the workflow was revived, **no dependency advisory in this project could be
caught by CI at all**. The four open alerts above existed undetected for six months.

---

## Notes on method

Counts differ between `gh api dependabot/alerts` and `npm audit` because Dependabot
deduplicates by advisory while `npm audit` counts every affected path. Both were used:
Dependabot for authoritative severity and patched versions, `npm audit` for tree-wide
totals. Baseline before remediation was 40 (`npm audit`); after, 39, with both
moderate-severity advisories in scope cleared.

A transient `+2` low-severity count on `ethers` and `@ethersproject/providers` was
investigated and ruled out: the resolved versions are byte-identical before and after
(`ethers` 5.8.0 and 6.17.0, `@ethersproject/providers` 5.8.0). It is an artifact of
audit graph shape following lockfile deduplication, not a regression.

---

**Reviewed by:** OpenCode, powered by **opencode/space-bunny-free**
**Status:** 9 resolved · 4 open (all upstream-blocked) · 0 critical open