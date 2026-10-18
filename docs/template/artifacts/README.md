# Forward Tasks Architecture & Operating Standard (SOP)

This document defines the authoritative architecture, formatting conventions, and operating standard for Forward Tasks (FT) artifacts across the repository.

---

## 🎯 1. Core Operating Philosophy: Lean WIP & Single-Item Flow

The purpose of a Forward Tasks document is to eliminate cognitive thrashing and maintain high velocity through **Work-In-Progress (WIP) discipline**:

1. **WIP Limit = 1 to 2 Active Items**: At any given time, the user or agent focuses on at most 1 or 2 focal targets.
2. **High-Level Routing & Dispatching**: FT is a routing dispatcher, **not** an issue comment duplicator. FT answers: *What is my active focus target?* and *Where do I find the instructions/assets?*
3. **Separation of Concerns**:
   - **GitHub Issue Comments**: Contain the granular in-situ deliverables, video assets, git checkout commands, technical logs, numerical criteria, and verification checklists.
   - **Forward Tasks Artifact**: Contains only the high-level focus frame, lineage, in-issue search string, and assignee.
   - *Exception*: Only when an engineering initiative has no corresponding GitHub issue yet may temporary inline specifications or cues be placed directly within FT.

---

## 📐 2. Visual Standard: Nested Rectangular Focus Callouts

To instantly draw visual focus upon opening the document without scrolling:

### A. Nested Rectangle Geometry
- **Outer Rectangle**: Double-line box (`╔═╗║╚═╝`, fixed width of 78 characters).
- **Inner Rectangle**: Single-line box (`┌─┐│└─┘`, width of 72 characters) nested symmetrically inside the outer rectangle.
- **Content of Inner Rectangle**: Contains solely the one-line focal target.
- **No Clutter Inside Rectangles**: Do not place redundant section titles (e.g. `ZONE OF FOCUS`), assignees, criteria, or key checks inside the rectangle. The rectangle exists solely to frame and highlight the target.

### B. The Exact Match Rule
The string inside the inner rectangle **must match the markdown heading immediately below outside the rectangle character-for-character**:

```text
╔════════════════════════════════════════════════════════════════════════════╗
║  ┌──────────────────────────────────────────────────────────────────────┐  ║
║  │ 🔴 FOCAL TARGET 1: [Task ID] — [Task Name / Summary]                  │  ║
║  └──────────────────────────────────────────────────────────────────────┘  ║
╚════════════════════════════════════════════════════════════════════════════╝
```

```markdown
#### 🔴 FOCAL TARGET 1: [Task ID] — [Task Name / Summary]
- **Lineage**: [#01](https://github.com/owner/repo/issues/01) (Child of [#00](https://github.com/owner/repo/issues/00))
- **In-Issue Search String ➡️** : '[Unique Search String for Ctrl+F]'
- **Assignee**: `@genidma` or `AGY`
```

---

## 🔍 3. In-Issue Search String Protocol

GitHub issue comments often accumulate rapidly, making raw comment numbers (e.g. `Comment #6247359442`) ineffective for quick visual navigation.

1. Always provide a unique text search string enclosed in single quotes with the right arrow emoji:
   ```markdown
   - **In-Issue Search String ➡️** : 'Unique Search String'
   ```
2. The contributor can press `Ctrl+F` in their browser and immediately jump to the relevant comment container.
3. When successive comments are added to an issue, update the search string in FT to match the newest active container.

---

## 👥 4. Standard Assignees

To maintain clarity on ownership, active targets are assigned to:
- **`@genidma`**: Human project lead & maintainer.
- **`AGY`**: Antigravity autonomous AI pair programmer.

---

## 📍 5. Document Structure & Layout Priority

To ensure zero-scroll accessibility:
1. **Title**: Document heading (`# Forward Engineering Task Tracker (...)`).
2. **Zone of Focus (Top)**:
   - Nested rectangle callout(s) (1 or 2 focal targets).
   - Corresponding metadata line (Lineage, In-Issue Search String, Assignee).
   - `Next on Deck` (single line preview of the immediate next step).
   - `Queued Initiatives` (1-line pointers to items in the matrix below).
3. **Task Matrix**: Comprehensive status table covering all active and pending packages.
4. **Verification & Testing Quick Reference**: Reproducible local CLI test commands.
5. **Completed Milestones**: Permanent audit ledger of finished tasks.
6. **Visual Dependency Flow (Mermaid.js)**: Architectural and lineage graph.
7. **Text Hierarchy Tree**: Full parent-child issue breakdown.
8. **Initiative Metadata & Lineage (Bottom)**: Administrative metadata block (`Status`, `Environment`, `Parent Initiatives`, `Active Child Packages`, `Target Release`) lives at the very footer of the file.

---

## 🔒 6. Sanitization & Safety Rules

1. **Path Sanitization**: Never reveal host file system paths in public repository documentation, artifacts, or GitHub issue comments.
2. **Branch Protection**: Never merge `main-dev` into `main` or `master` without sign-off approval and concrete verification from `@genidma`.
3. **No Unretracted Claims**: Always verify actual files, CI runs, and commit hashes before asserting completion status.
