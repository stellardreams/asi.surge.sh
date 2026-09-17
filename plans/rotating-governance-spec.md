# Rotating Governance Spec — RPA-Style 18-Month Rotation

> **Issue:** #50 line 7 `rotating set of tokens for those involved in governance. maybe like a xxRPA program manager model this many months and you rotate`  
> **Whitepaper:** `plans/tokenomics-whitepaper.md:12` + `:66` — 18-month cycles  
> **Contracts:** `contracts/EnhancedSpaceInfrastructureToken.sol:180` (`createVestingSchedule`) / `contracts/SpaceInfrastructureTokenV2.sol:269` + roles `MINTER_ROLE`/`VOTING_ROLE`

## 1. Nutshell

Governance is a **seasonal field-manager permit**, not a permanent landlord title. You receive a time-bound governance token/role for 18 months, then it expires back to the treasury for the next elected manager.

## 2. Roles

| Role | Power | Duration | How granted |
|---|---|---|---|
| Proposer | `createProposal()` | 18 months | Elected via `vote` + `quorum 20%` |
| Validator | `vote()` weight | 18 months | Snapshot at `proposals[proposalId]` |
| Executor | `queueProposal()`/`executeProposal()` | 18 months | `TIMELOCK_DELAY` gated |

All roles use `AccessControl` + `VestingSchedule` expiry, not permanent `Ownable`.

## 3. Mechanics

1. **Nomination:** Anyone with `MIN_PROPOSAL_SHARES` creates proposal `Elect <address> as <role> for 18 months`.
2. **Vote:** `votingPowerAtProposal` snapshot, 3-day period, `QUORUM_PERCENTAGE=20%`.
3. **Grant:** On pass, `grantRole(ROLE, nominee)` + `createVestingSchedule(nominee, block.number, block.number+ ~3,942,000 blocks, amount)` where `amount <= MAX_WALLET` (`20M`, `0.1%` at `EnhancedSpaceInfrastructureToken.sol:34`).
4. **Expiry:** After `endBlock`, `revokeVesting()` / `revokeRole()` auto-or manual; tokens return to `treasury` (`treasury` at `V2.sol:102`).
5. **Handover:** New election must complete 1 month before expiry to avoid gap.

Block estimate: 18 months ≈ 3,942,000 blocks @ 12s (or 2,361,600 @ 15s — use `block.timestamp + 18 months` for clarity).

## 4. Caps & Safeguards

- **Anti-whale:** `require(balanceOf(to)+amount <= MAX_WALLET)` at `EnhancedSpaceInfrastructureToken.sol:91,110,276` / `V2.sol:170,379,552` — rotation respects 20M cap.
- **Mint cap:** `ANNUAL_MINT_CAP = 5%` (`1B` SIT) — rotation mint counts toward `annualMinted`.
- **Quadratic voting (planned):** amplify small holders per whitepaper:42 — to be added in `vote()` vNext.
- **Timelock:** `TIMELOCK_DELAY=86400` (`V2.sol:42`) before execution.

## 5. Why RPA Model

Prevents entrenchment, mirrors DARPA/RPA program-manager rotation, keeps `wikinomics` collective ownership alive. No permanent `owner()`.

## 6. Open Tasks (for #50 master checklist)

- [ ] Implement `grantRoleWithExpiry()` + `revokeRoleAfter()` helpers
- [ ] Add `rotationPeriod = 18 months` constant
- [ ] Test: grant → vote → expiry → revoke → re-elect flow

## 7. How to Test

1. Deploy `SpaceInfrastructureTokenV2` → `TOTAL_SUPPLY()` = 20B.
2. Elect `addr1` as Proposer → `hasRole(PROPOSER, addr1)` true, vesting active.
3. Advance time 18 months + 1 block → `revokeVesting()` → role removed, balance returned.
4. Elect `addr2` → succeeds.

---

> 🤖 **Signed:** OpenCode, powered by **opencode/muse-spark-1.2-contributor-free**  
> 📅 **Date/Time:** September 16, 2026 — 10:10 PM Eastern (ET) / 02:10 UTC

