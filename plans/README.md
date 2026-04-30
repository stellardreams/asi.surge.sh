# Plans Directory

This directory contains the canonical strategic plan documents for the Awakened Imagination project.

## Location Decision Rationale

**Decision:** Strategic plans live in `plans/` (root level) as the canonical location.

**Rationale:**
- All strategic documents (foundations, life-support, prosperity, stewardship, lamport-systems-engineering) are already located here and marked as "Plan File" in the audit table
- GitHub master branch points to `plans/` directory for all these documents
- Tokenomics-whitepaper.md sits in `plans/` as "Unique" (no duplicate exists)
- The cleanup work removed duplicates FROM root, preserving originals in `plans/`
- `.kilo/plans/` directory is reserved for administrative plans and templates (like admin-issue75.md)

**Directory Structure:**
- `plans/` - Canonical strategic plan documents (public-facing)
- `.kilo/plans/` - Administrative plans, templates, and internal documentation

**Maintenance:**
- New strategic plans should be placed directly in `plans/`
- Administrative plans (like this README's creation) go in `.kilo/plans/`
- All plan files should follow the established naming convention: `plan-[topic].md`

## Available Plans

- [Plan for Interplanetary Foundations](plan-foundations.md)
- [Plan for Planetary Life Support](plan-life-support.md)
- [Plan for Global Prosperity](plan-prosperity.md)
- [Plan for Orbital Stewardship](plan-stewardship.md)
- [Systems Engineering Plan - Leslie Lamport](plan-lamport-systems-engineering.md)
- [Tokenomics Whitepaper](tokenomics-whitepaper.md)
- [Space Flourishing Framework](SPACE_FLOURISHING_FRAMEWORK.md)

## Contributing

When creating new plans:
1. Place strategic plans in this `plans/` directory
2. Use the naming convention: `plan-[topic].md`
3. Ensure GitHub master branch compatibility
4. Update plans.html if adding new public-facing plans

---

*Decision documented: 2026-04-29 22:15 Eastern / 02:15 UTC*