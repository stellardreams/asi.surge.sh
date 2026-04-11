# Choose and Add an Open Source License

## Status
- **Type**: Legal/Administrative
- **Priority**: Critical
- **Assigned**: Unassigned
- **Milestone**: To be determined

## Description

The repository needs an open-source license to clearly define usage rights and enable collaboration. Currently, the project lacks a license, which means it's not legally open source.

## Options to Investigate

### 1. MIT License
- **Pros**: Simple, permissive, widely adopted, minimal restrictions
- **Cons**: No explicit patent protection
- **Best for**: Web projects, maximum adoption, simplicity

### 2. Apache License 2.0
- **Pros**: Includes patent grant, explicit patent retaliation clause
- **Cons**: More complex, longer (3 pages), patent concerns may be unnecessary
- **Best for**: Projects concerned about software patents

### 3. GNU GPL v3
- **Pros**: Copyleft ensures derivatives remain open source
- **Cons**: Restrictive, may limit commercial adoption
- **Best for**: Projects wanting to enforce open-source derivatives

## Recommendation

Based on the project's nature (static website, philosophical vision, design concepts), the **MIT License** is recommended as the most appropriate. Patent protection is likely unnecessary, and simplicity will encourage wider adoption.

## Tasks

- [ ] Evaluate which license aligns best with project goals
- [ ] Add chosen license file to repository root
- [ ] Update README.md to reference license
- [ ] Consider adding SPDX identifier

## References
- [Choose a License](https://choosealicense.com/)
- [SPDX License List](https://spdx.org/licenses/)

---
*Created: 2026-04-10*
*Last updated: 2026-04-10*