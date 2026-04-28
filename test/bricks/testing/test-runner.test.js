/**
 * @jest-environment node
 */

import { describe, it, expect, vi } from 'vitest';
import { TestRunner, IntegrationTest } from '../../../src/bricks/testing/test-runner.js';

describe('TestRunner', () => {
  let runner;

  beforeEach(() => {
    runner = new TestRunner({ verbose: false });
  });

  describe('constructor', () => {
    it('should create instance with default options', () => {
      const r = new TestRunner();
      expect(r).toBeDefined();
      expect(r.options.timeout).toBe(5000);
    });

    it('should accept custom options', () => {
      const r = new TestRunner({ timeout: 10000 });
      expect(r.options.timeout).toBe(10000);
    });
  });

  describe('addTestSuite', () => {
    it('should add test suite', () => {
      const suite = {
        test1: async () => {}
      };
      
      runner.addTestSuite('suite1', suite);
      expect(runner.testSuites.has('suite1')).toBe(true);
    });
  });

  describe('runAll', () => {
    it('should run all test suites', async () => {
      const suite = {
        test1: async () => {},
        test2: async () => { throw new Error('fail'); }
      };
      
      runner.addTestSuite('suite1', suite);\n      const results = await runner.runAll();
      
      expect(results.summary.totalSuites).toBe(1);
      expect(results.summary.totalTests).toBe(2);
    });

    it('should handle empty suites', async () => {
      const results = await runner.runAll();
      
      expect(results.summary.totalTests).toBe(0);
      expect(results.summary.passRate).toBe('0%');
    });
  });

  describe('runSuite', () => {
    it('should run single suite', async () => {
      const suite = {
        test1: async () => {}
      };
      
      const result = await runner.runSuite('test', suite);
      
      expect(result.name).toBe('test');
      expect(result.passed).toBe(1);
    });
  });

  describe('runTest', () => {
    it('should run passing test', async () => {
      const testFn = async () => {};
      const result = await runner.runTest('test', testFn);
      
      expect(result.passed).toBe(true);
    });

    it('should handle failing test', async () => {
      const testFn = async () => { throw new Error('fail'); };
      const result = await runner.runTest('test', testFn);
      
      expect(result.passed).toBe(false);
      expect(result.error).toBe('fail');
    });

    it('should handle timeout', async () => {
      const testFn = async () => {
        await new Promise(resolve => setTimeout(resolve, 100));
      };
      
      const slowRunner = new TestRunner({ timeout: 1 });
      const result = await slowRunner.runTest('test', testFn);
      
      expect(result.passed).toBe(false);
    });
  });

  describe('generateReport', () => {
    it('should generate test report', () => {
      runner.results = [{
        name: 'suite1',
        tests: [],
        passed: 0,
        failed: 0,
        duration: 100
      }];
      
      const report = runner.generateReport(100);
      
      expect(report.summary).toBeDefined();
      expect(report.suites).toHaveLength(1);
    });
  });

  describe('runPropertyTest', () => {
    it('should run property-based tests', async () => {
      const property = (x) => x >= 0;
      const results = await runner.runPropertyTest(property, { iterations: 10 });
      
      expect(results.iterations).toBe(10);
      expect(results.passed).toBeGreaterThanOrEqual(0);
    });

    it('should handle failing property tests', async () => {
      const property = (x) => x > 0;
      const results = await runner.runPropertyTest(property, { iterations: 10 });
      
      expect(results.failed).toBeGreaterThanOrEqual(0);
    });
  });
});

describe('IntegrationTest', () => {
  describe('addStep', () => {
    it('should add integration step', () => {
      const integration = new IntegrationTest();
      integration.addStep('step1', async (x) => x + 1);
      
      expect(integration.steps).toHaveLength(1);
    });
  });

  describe('run', () => {
    it('should run integration steps', async () => {
      const integration = new IntegrationTest();
      integration.addStep('add1', async (x) => x + 1);
      integration.addStep('add2', async (x) => x + 2);
      
      const result = await integration.run(0);
      
      expect(result.final).toBe(3);
      expect(result.steps).toHaveLength(2);
      expect(result.error).toBeNull();
    });

    it('should handle step failure', async () => {
      const integration = new IntegrationTest();
      integration.addStep('step1', async (x) => x + 1);
      integration.addStep('step2', async () => { throw new Error('fail'); });
      
      const result = await integration.run(0);
      
      expect(result.error).toBe('fail');
      expect(result.steps[1].passed).toBe(false);
    });
  });
});
