/**
 * Architecture Decision Record (ADR)
 * 
 * Captures and tracks architectural decisions for the project.
 * Each ADR documents a significant choice, its context, and consequences.
 * 
 * @example
 * ```javascript
 * const adr = new ArchitectureDecisionRecord({
 *   id: 'ADR-001',
 *   title: 'Use ethers v6 for blockchain interactions',
 *   context: 'Project was using ethers v5 which is deprecated',
 *   decision: 'Migrate to ethers v6',
 *   consequences: ['Better TypeScript support', 'Native BigInt']
 * });
 * ```
 */
export class ArchitectureDecisionRecord {
  constructor(options = {}) {
    this.id = options.id;
    this.title = options.title;
    this.status = options.status || 'proposed';
    this.date = options.date || new Date().toISOString().split('T')[0];
    this.author = options.author || 'system';
    this.context = options.context;
    this.decision = options.decision;
    this.consequences = options.consequences || [];
    this.alternatives = options.alternatives || [];
    this.tradeoffs = options.tradeoffs || [];
    this.implementation = options.implementation;
    this.references = options.references || [];
    this.tags = options.tags || [];
  }

  /**
   * Validates the ADR
   * 
   * @returns {boolean} True if valid
   */
  validate() {
    const required = ['id', 'title', 'context', 'decision'];
    return required.every(field => this[field]);
  }

  /**
   * Converts ADR to markdown format
   * 
   * @returns {string} Markdown representation
   */
  toMarkdown() {
    let md = `# ${this.id}: ${this.title}\n\n`;
    md += `**Status**: ${this.status}\n`;
    md += `**Date**: ${this.date}\n`;
    md += `**Author**: ${this.author}\n\n`;

    if (this.tags.length > 0) {
      md += `**Tags**: ${this.tags.join(', ')}\n\n`;
    }

    md += `## Context\n\n${this.context}\n\n`;
    md += `## Decision\n\n${this.decision}\n\n`;

    if (this.alternatives.length > 0) {
      md += `## Alternatives Considered\n\n`;
      this.alternatives.forEach((alt, i) => {
        md += `${i + 1}. ${alt}\n`;
      });
      md += '\n';
    }

    if (this.tradeoffs.length > 0) {
      md += `## Tradeoffs\n\n`;
      this.tradeoffs.forEach((tradeoff, i) => {
        md += `- ${tradeoff}\n`;
      });
      md += '\n';
    }

    if (this.consequences.length > 0) {
      md += `## Consequences\n\n`;
      this.consequences.forEach((consequence, i) => {
        md += `- ${consequence}\n`;
      });
      md += '\n';
    }

    if (this.implementation) {
      md += `## Implementation\n\n${this.implementation}\n\n`;
    }

    if (this.references.length > 0) {
      md += `## References\n\n`;
      this.references.forEach((ref, i) => {
        md += `- ${ref}\n`;
      });
      md += '\n';
    }

    return md;
  }

  /**
   * Converts ADR to JSON
   * 
   * @returns {Object} JSON representation
   */
  toJSON() {
    return {
      id: this.id,
      title: this.title,
      status: this.status,
      date: this.date,
      author: this.author,
      context: this.context,
      decision: this.decision,
      alternatives: this.alternatives,
      tradeoffs: this.tradeoffs,
      consequences: this.consequences,
      implementation: this.implementation,
      references: this.references,
      tags: this.tags
    };
  }
}

/**
 * ADR Manager
 * 
 * Manages a collection of Architecture Decision Records
 * 
 * @example
 * ```javascript
 * const manager = new ADRManager();
 * manager.add(adr);
 * const decisions = manager.findByTag('ethers');
 * ```
 */
export class ADRManager {
  constructor() {
    this.decisions = new Map();
  }

  /**
   * Adds an ADR
   * 
   * @param {ArchitectureDecisionRecord} adr - ADR to add
   * @returns {boolean} True if added
   */
  add(adr) {
    if (!adr.validate()) {
      throw new Error('Invalid ADR: missing required fields');
    }

    if (this.decisions.has(adr.id)) {
      throw new Error(`ADR with id ${adr.id} already exists`);
    }

    this.decisions.set(adr.id, adr);
    return true;
  }

  /**
   * Gets an ADR by ID
   * 
   * @param {string} id - ADR ID
   * @returns {ArchitectureDecisionRecord|null} ADR or null
   */
  get(id) {
    return this.decisions.get(id) || null;
  }

  /**
   * Finds ADRs by tag
   * 
   * @param {string} tag - Tag to search for
   * @returns {Array<ArchitectureDecisionRecord>} Matching ADRs
   */
  findByTag(tag) {
    return Array.from(this.decisions.values()).filter(
      adr => adr.tags.includes(tag)
    );
  }

  /**
   * Finds ADRs by status
   * 
   * @param {string} status - Status to search for
   * @returns {Array<ArchitectureDecisionRecord>} Matching ADRs
   */
  findByStatus(status) {
    return Array.from(this.decisions.values()).filter(
      adr => adr.status === status
    );
  }

  /**
   * Gets all ADRs
   * 
   * @returns {Array<ArchitectureDecisionRecord>} All ADRs
   */
  getAll() {
    return Array.from(this.decisions.values())
      .sort((a, b) => a.id.localeCompare(b.id));
  }

  /**
   * Exports all ADRs as markdown
   * 
   * @returns {string} Markdown document
   */
  exportMarkdown() {
    const adrs = this.getAll();
    let md = '# Architecture Decision Records\n\n';
    md += `Total Decisions: ${adrs.length}\n\n`;
    md += '---\n\n';

    adrs.forEach(adr => {
      md += adr.toMarkdown();
      md += '---\n\n';
    });

    return md;
  }

  /**
   * Exports all ADRs as JSON
   * 
   * @returns {Object} JSON representation
   */
  exportJSON() {
    return {
      version: '1.0',
      generated: new Date().toISOString(),
      decisions: this.getAll().map(adr => adr.toJSON())
    };
  }
}

// Predefined ADRs for the project
export const predefinedADRs = [
  new ArchitectureDecisionRecord({
    id: 'ADR-001',
    title: 'Use ethers v6 for blockchain interactions',
    status: 'accepted',
    date: '2026-04-25',
    author: 'kiloAI',
    context: 'Project was using ethers v5 which has been deprecated and has breaking API changes compared to v6',
    decision: 'Migrate all blockchain interactions to ethers v6',
    alternatives: [
      'Continue using ethers v5 with compatibility layer',
      'Switch to web3.js instead'
    ],
    tradeoffs: [
      'Breaking changes require test updates',
      'Learning curve for team members familiar with v5'
    ],
    consequences: [
      'Native BigInt support eliminates need for BigNumber wrapper',
      'Better TypeScript integration',
      'Modern API with improved error handling'
    ],
    implementation: 'Updated hardhat.config.cjs, test files, and deployment scripts to use ethers v6 API',
    references: ['https://docs.ethers.org/v6/', 'Issue #34'],
    tags: ['ethers', 'blockchain', 'migration']
  }),
  new ArchitectureDecisionRecord({
    id: 'ADR-002',
    title: 'Implement Brick-based modular architecture',
    status: 'proposed',
    date: '2026-04-26',
    author: 'kiloAI',
    context: 'Project needs better code organization and reusability as it scales',
    decision: 'Adopt Brick pattern with strict documentation standards',
    alternatives: [
      'Traditional layered architecture',
      'Microservices approach'
    ],
    tradeoffs: [
      'Initial overhead to refactor existing code',
      'Requires discipline to maintain standards'
    ],
    consequences: [
      'Improved code reusability',
      'Better AI-assisted development',
      'Easier onboarding for new contributors'
    ],
    implementation: 'Create BRICK_STANDARDS.md, SOPs, and refactor utilities into Bricks',
    references: ['Issue #45', 'README.md - Wikinomics Code Structure'],
    tags: ['architecture', 'modular', 'documentation']
  })
];
