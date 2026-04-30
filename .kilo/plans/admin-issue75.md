# Plan: admin-issue75

GitHub Issue: [https://github.com/stellardreams/asi.surge.sh/issues/75](https://github.com/stellardreams/asi.surge.sh/issues/75)

---

plan code name: admin-issue75  
version: 1.0.0  
author: antigravity by google deepmind (no affiliation) as original author  
co-author: kilo/inclusionai/ling-2.6-1t:free (equal lifting - 40%)  
co-author: kilo/x-ai/grok-code-fast-1:optimized:free (rewrite plan for 75, assist with mysterious propulsion and other plans. integrate changes inside readme. contribution - 40%)  
time started: 16:20 Eastern / 20:20 UTC  
date completed: tbd  
status: in progress  
pending review: will be approved line by line  
rate of completion:85%
---

## Assessment of Duplicate Strategic Plans (Issue #75) via 01. Antigravity by Google DeepMind (no affiliation with either, as of yet) 🙏 and then 02. kilo/inclusionai/ling-2.6-1t:free (no affiliation)

To ensure a single source of truth and streamline the project structure, an audit has been performed:

### 1. Audit of Duplicate Files (with Updated Duplicate Mapping (Color-Coded))
Identified that the following files in the local codebase are duplicates of the primary plans maintained in the `master/plans` directory on GitHub.

The markers in the **"Group"** column visually link each plan file to its duplicate in the root directory.

| Group | Local Path [Source Code] | Local File Name | Status | GitHub Counterpart (master/plans) | investigation output by kilo/inclusionai/ling-2.6-1t:free | duplicate removed from root? | links via plans.html updated? |
| :---: | :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| 🔵 | `plans/` | `plan-foundations.md` | Plan File | [View on GitHub](https://github.com/stellardreams/asi.surge.sh/blob/master/plans/plan-foundations.md) | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | n/a | ✅ |
| 🔵 | Root | `ledger-foundations.md` | **Duplicate** | *(Links to Group 🔵 Above)* | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | ✅ | n/a |
| 🟢 | `plans/` | `plan-life-support.md` | Plan File | [View on GitHub](https://github.com/stellardreams/asi.surge.sh/blob/master/plans/plan-life-support.md) | hash: 35A740645B5E17C41701E705CFC24CB5DB3352133F2260954B6BE8AA086F1914 | n/a | ✅ |
| 🟢 | Root | `ledger-life-support.md` | **Duplicate** | *(Links to Group 🟢 Above)* | hash: 35A740645B5E17C41701E705CFC24CB5DB3352133F2260954B6BE8AA086F1914 | ✅ | n/a |
| 🟡 | `plans/` | `plan-prosperity.md` | Plan File | [View on GitHub](https://github.com/stellardreams/asi.surge.sh/blob/master/plans/plan-prosperity.md) | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | n/a | ✅ |
| 🟡 | Root | `ledger-prosperity.md` | **Duplicate** | *(Links to Group 🟡 Above)* | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | ✅ | n/a |
| 🔴 | `plans/` | `plan-stewardship.md` | Plan File | [View on GitHub](https://github.com/stellardreams/asi.surge.sh/blob/master/plans/plan-stewardship.md) | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | n/a | ✅ |
| 🔴 | Root | `ledger-stewardship.md` | **Duplicate** | *(Links to Group 🔴 Above)* | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | ✅ | n/a |
| 🟣 | `plans/` | `plan-lamport-systems-engineering.md` | Plan File | [View on GitHub](https://github.com/stellardreams/asi.surge.sh/blob/master/plans/plan-lamport-systems-engineering.md) | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | n/a | ✅ |
| 🟣 | Root | `ledger-lamport-systems-engineering.md` | **Duplicate** | *(Links to Group 🟣 Above)* | hash: 4A399C1D576ED893A642FD11B3ABD47C9487C875C534D77EF7A8030F6CDC74AF | ✅ | n/a |
| ⚪ | `plans/` | `tokenomics-whitepaper.md` | Unique | [View on GitHub](https://github.com/stellardreams/asi.surge.sh/blob/master/plans/tokenomics-whitepaper.md) | — | N/A | ✅ |

### 2. Proposed Resolution Strategy

> "Simplicity is the ultimate sophistication." - Leonardo da Vinci

```
flowchart TD
    A[decision] --> B[plans]
    A --> C[.kilo/plans/]
```

#### 2.b Original Proposition

1. **Website Integration**: Update `plans.html` to link directly to the GitHub-hosted versions of each plan.
2. **Cleanup**: Remove all local `.md` duplicates from the root and `plans/` directories to eliminate confusion.