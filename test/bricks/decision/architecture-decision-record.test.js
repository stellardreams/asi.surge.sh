/**
 * @jest-environment node
 */

import { describe, it, expect } from 'vitest';
import { ArchitectureDecisionRecord, ADRManager, predefinedADRs } from '../../../src/bricks/decision/architecture-decision-record.js';

describe('ArchitectureDecisionRecord', () => {
  describe('constructor', () => {
    it('should create ADR with required fields', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test Decision',
        context: 'Test context',
        decision: 'Test decision'
      });
      
      expect(adr.id).toBe('ADR-001');
      expect(adr.title).toBe('Test Decision');
      expect(adr.status).toBe('proposed');
      expect(adr.author).toBe('system');
    });

    it('should accept optional fields', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision',
        alternatives: ['Alt1', 'Alt2'],
        consequences: ['Con1', 'Con2'],
        tags: ['tag1', 'tag2']
      });
      
      expect(adr.alternatives).toHaveLength(2);
      expect(adr.consequences).toHaveLength(2);
      expect(adr.tags).toHaveLength(2);
    });
  });

  describe('validate', () => {
    it('should validate complete ADR', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision'
      });
      
      expect(adr.validate()).toBe(true);
    });

    it('should invalidate incomplete ADR', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test'
      });
      
      expect(adr.validate()).toBe(false);
    });
  });

  describe('toMarkdown', () => {
    it('should convert ADR to markdown', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test Decision',
        context: 'Test context',
        decision: 'Test decision',
        consequences: ['Consequence 1']
      });
      
      const md = adr.toMarkdown();
      
      expect(md).toContain('# ADR-001: Test Decision');
      expect(md).toContain('## Context');
      expect(md).toContain('## Decision');
      expect(md).toContain('## Consequences');
    });
  });

  describe('toJSON', () => {
    it('should convert ADR to JSON', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision'
      });
      
      const json = adr.toJSON();
      
      expect(json.id).toBe('ADR-001');
      expect(json.title).toBe('Test');
      expect(json.context).toBe('Context');
      expect(json.decision).toBe('Decision');
    });
  });
});

describe('ADRManager', () => {
  let manager;

  beforeEach(() => {
    manager = new ADRManager();
  });

  describe('add', () => {
    it('should add ADR', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision'
      });
      
      expect(manager.add(adr)).toBe(true);
      expect(manager.get('ADR-001')).toBe(adr);
    });

    it('should reject invalid ADR', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test'
      });
      
      expect(() => manager.add(adr)).toThrow('Invalid ADR');
    });

    it('should reject duplicate ADR', () => {
      const adr1 = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision'
      });
      
      const adr2 = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test2',
        context: 'Context2',
        decision: 'Decision2'
      });
      
      manager.add(adr1);
      expect(() => manager.add(adr2)).toThrow('already exists');
    });
  });

  describe('get', () => {
    it('should retrieve ADR by ID', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision'
      });
      
      manager.add(adr);
      expect(manager.get('ADR-001')).toBe(adr);
    });

    it('should return null for non-existent ADR', () => {
      expect(manager.get('ADR-999')).toBeNull();
    });
  });

  describe('findByTag', () => {
    it('should find ADRs by tag', () => {
      const adr1 = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test1',
        context: 'Context',
        decision: 'Decision',
        tags: ['ethers', 'blockchain']
      });
      
      const adr2 = new ArchitectureDecisionRecord({
        id: 'ADR-002',
        title: 'Test2',
        context: 'Context',
        decision: 'Decision',
        tags: ['architecture']
      });
      
      manager.add(adr1);
      manager.add(adr2);
      
      const results = manager.findByTag('ethers');
      expect(results).toHaveLength(1);
      expect(results[0].id).toBe('ADR-001');
    });
  });

  describe('findByStatus', () => {
    it('should find ADRs by status', () => {
      const adr1 = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test1',
        context: 'Context',
        decision: 'Decision',
        status: 'accepted'
      });
      
      const adr2 = new ArchitectureDecisionRecord({
        id: 'ADR-002',
        title: 'Test2',
        context: 'Context',
        decision: 'Decision',
        status: 'proposed'
      });
      
      manager.add(adr1);
      manager.add(adr2);
      
      const results = manager.findByStatus('accepted');
      expect(results).toHaveLength(1);
      expect(results[0].id).toBe('ADR-001');
    });
  });

  describe('getAll', () => {
    it('should return all ADRs sorted', () => {
      const adr2 = new ArchitectureDecisionRecord({
        id: 'ADR-002',
        title: 'Test2',
        context: 'Context',
        decision: 'Decision'
      });
      
      const adr1 = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test1',
        context: 'Context',
        decision: 'Decision'
      });
      
      manager.add(adr2);
      manager.add(adr1);
      
      const all = manager.getAll();
      expect(all).toHaveLength(2);
      expect(all[0].id).toBe('ADR-001');
      expect(all[1].id).toBe('ADR-002');
    });
  });

  describe('exportMarkdown', () => {
    it('should export ADRs as markdown', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision'
      });
      
      manager.add(adr);
      const md = manager.exportMarkdown();
      
      expect(md).toContain('# Architecture Decision Records');
      expect(md).toContain('# ADR-001: Test');
    });
  });

  describe('exportJSON', () => {
    it('should export ADRs as JSON', () => {
      const adr = new ArchitectureDecisionRecord({
        id: 'ADR-001',
        title: 'Test',
        context: 'Context',
        decision: 'Decision'
      });
      
      manager.add(adr);
      const json = manager.exportJSON();
      
      expect(json.version).toBe('1.0');
      expect(json.decisions).toHaveLength(1);
    });
  });
});

describe('predefinedADRs', () => {
  it('should have predefined ADRs', () => {
    expect(predefinedADRs).toHaveLength(2);
    expect(predefinedADRs[0].id).toBe('ADR-001');
    expect(predefinedADRs[1].id).toBe('ADR-002');
  });

  it('should validate all predefined ADRs', () => {
    predefinedADRs.forEach(adr => {
      expect(adr.validate()).toBe(true);
    });
  });
});
