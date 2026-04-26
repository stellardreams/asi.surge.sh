/**
 * Test Runner for Bricks
 * 
 * Provides comprehensive test execution with coverage reporting,
 * integration testing, and property-based testing capabilities.
 * 
 * @example
 * ```javascript
 * const runner = new TestRunner();
 * runner.addTestSuite('validation', validationTests);
 * const results = await runner.runAll();
 * ```
 */
export class TestRunner {
  constructor(options = {}) {
    this.options = {
      verbose: options.verbose ?? false,
      coverage: options.coverage ?? true,
      timeout: options.timeout ?? 5000,
      ...options
    };
    this.testSuites = new Map();
    this.results = [];
  }

  /**
   * Adds a test suite to the runner
   * 
   * @param {string} name - Suite name
   * @param {Object} suite - Test suite object
   */
  addTestSuite(name, suite) {
    this.testSuites.set(name, suite);
    if (this.options.verbose) {
      console.log(`📦 Registered test suite: ${name}`);
    }
  }

  /**
   * Runs all registered test suites
   * 
   * @returns {Promise<Object>} Test results
   */
  async runAll() {
    const startTime = Date.now();
    this.results = [];

    for (const [name, suite] of this.testSuites) {
      const result = await this.runSuite(name, suite);
      this.results.push(result);
    }

    const endTime = Date.now();
    
    return this.generateReport(endTime - startTime);
  }

  /**
   * Runs a single test suite
   * 
   * @private
   * @param {string} name - Suite name
   * @param {Object} suite - Test suite
   * @returns {Promise<Object>} Suite results
   */
  async runSuite(name, suite) {
    const suiteResult = {
      name: name,
      tests: [],
      passed: 0,
      failed: 0,
      skipped: 0,
      duration: 0,
      error: null
    };

    const startTime = Date.now();

    try {
      for (const testName in suite) {
        if (testName.startsWith('_')) continue;
        
        const testFn = suite[testName];
        if (typeof testFn !== 'function') continue;

        const testResult = await this.runTest(testName, testFn);
        suiteResult.tests.push(testResult);

        if (testResult.passed) {
          suiteResult.passed++;
        } else {
          suiteResult.failed++;
        }
      }
    } catch (error) {
      suiteResult.error = error.message;
    } finally {
      suiteResult.duration = Date.now() - startTime;
    }

    return suiteResult;
  }

  /**
   * Runs a single test
   * 
   * @private
   * @param {string} name - Test name
   * @param {Function} fn - Test function
   * @returns {Promise<Object>} Test result
   */
  async runTest(name, fn) {
    const result = {
      name: name,
      passed: false,
      duration: 0,
      error: null
    };

    const startTime = Date.now();
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => reject(new Error('Test timeout')), this.options.timeout);
    });

    try {
      await Promise.race([fn(), timeoutPromise]);
      result.passed = true;
    } catch (error) {
      result.error = error.message;
      if (this.options.verbose) {
        console.error(`❌ Test failed: ${name}`);
        console.error(`   ${error.message}`);
      }
    } finally {
      result.duration = Date.now() - startTime;
    }

    if (this.options.verbose && result.passed) {
      console.log(`✅ Test passed: ${name}`);
    }

    return result;
  }

  /**
   * Generates test report
   * 
   * @private
   * @param {number} totalDuration - Total execution time
   * @returns {Object} Test report
   */
  generateReport(totalDuration) {
    const totalTests = this.results.reduce((sum, r) => sum + r.tests.length, 0);
    const passedTests = this.results.reduce((sum, r) => sum + r.passed, 0);
    const failedTests = this.results.reduce((sum, r) => sum + r.failed, 0);

    return {
      summary: {
        totalSuites: this.results.length,
        totalTests: totalTests,
        passed: passedTests,
        failed: failedTests,
        skipped: this.results.reduce((sum, r) => sum + r.skipped, 0),
        passRate: totalTests > 0 ? (passedTests / totalTests * 100).toFixed(2) + '%' : '0%',
        duration: totalDuration
      },
      suites: this.results,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Runs property-based tests
   * 
   * @param {Function} property - Property function
   * @param {Object} options - Test options
   * @returns {Promise<Object>} Property test results
   */
  async runPropertyTest(property, options = {}) {
    const iterations = options.iterations || 100;
    const results = {
      property: property.name || 'anonymous',
      iterations: iterations,
      passed: 0,
      failed: 0,
      counterexamples: []
    };

    for (let i = 0; i < iterations; i++) {
      try {
        const input = this.generateRandomInput(options.inputGenerator);
        const isValid = await property(input);
        
        if (isValid) {
          results.passed++;
        } else {
          results.failed++;
          results.counterexamples.push(input);
        }
      } catch (error) {
        results.failed++;
        results.counterexamples.push({ error: error.message });
      }
    }

    return results;
  }

  /**
   * Generates random input for property testing
   * 
   * @private
   * @param {Function} generator - Input generator function
   * @returns {*} Random input
   */
  generateRandomInput(generator) {
    if (generator) {
      return generator();
    }
    
    // Default random generators
    const types = [
      () => Math.random(),
      () => Math.floor(Math.random() * 1000),
      () => Math.random() > 0.5,
      () => `test_${Math.random().toString(36).substr(2, 9)}`
    ];
    
    return types[Math.floor(Math.random() * types.length)]();
  }
}

/**
 * Integration test helper
 * 
 * Tests interactions between multiple bricks
 * 
 * @example
 * ```javascript
 * const integration = new IntegrationTest();
 * integration.addStep('validate', validateBrick);
 * integration.addStep('transform', transformBrick);
 * const result = await integration.run(input);
 * ```
 */
export class IntegrationTest {
  constructor() {
    this.steps = [];
  }

  /**
   * Adds a test step
   * 
   * @param {string} name - Step name
   * @param {Function} brick - Brick function
   */
  addStep(name, brick) {
    this.steps.push({ name, brick });
  }

  /**
   * Runs integration test
   * 
   * @param {*} input - Initial input
   * @returns {Promise<Object>} Test results
   */
  async run(input) {
    const results = {
      steps: [],
      final: null,
      error: null
    };

    let current = input;

    for (const step of this.steps) {
      try {
        const startTime = Date.now();
        current = await step.brick(current);
        const duration = Date.now() - startTime;

        results.steps.push({
          name: step.name,
          passed: true,
          duration: duration,
          output: current
        });
      } catch (error) {
        results.steps.push({
          name: step.name,
          passed: false,
          error: error.message
        });
        results.error = error.message;
        break;
      }
    }

    results.final = current;
    return results;
  }
}
