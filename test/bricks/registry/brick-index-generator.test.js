/**
 * @jest-environment node
 */

import { describe, it, expect, vi } from 'vitest';
import { BrickIndexGenerator } from '../../../src/bricks/registry/brick-index-generator.js';

vi.mock('fs/promises');
vi.mock('path');

describe('BrickIndexGenerator', () => {
  let generator;
  let mockFs;
  let mockPath;

  beforeEach(() => {
    mockFs = {
      readdir: vi.fn(),
      readFile: vi.fn(),
      mkdir: vi.fn(),
      writeFile: vi.fn()
    };
    
    mockPath = {
      join: vi.fn((...args) => args.join('/')),
      relative: vi.fn((a, b) => b.replace(a + '/', '')),
      dirname: vi.fn(() => 'docs'),
      extname: vi.fn(() => '.js'),
      basename: vi.fn((file, ext) => file.replace(ext, ''))
    };
    
    vi.mocked(require('fs/promises')).mockReturnValue(mockFs);
    vi.mocked(require('path')).mockReturnValue(mockPath);
    
    generator = new BrickIndexGenerator({
      brickDir: 'src/bricks',
      outputFile: 'docs/brick-index.json'
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('constructor', () => {
    it('should create instance with default options', () => {
      const gen = new BrickIndexGenerator();
      expect(gen).toBeDefined();
      expect(gen.options.brickDir).toBe('src/bricks');
    });

    it('should accept custom options', () => {
      const gen = new BrickIndexGenerator({ brickDir: 'custom' });
      expect(gen.options.brickDir).toBe('custom');
    });
  });

  describe('scanDirectory', () => {
    it('should scan directory for brick files', async () => {
      mockFs.readdir.mockResolvedValue([
        { name: 'utils', isDirectory: () => true },
        { name: 'test.js', isDirectory: () => false }
      ]);
      
      const files = await generator.scanDirectory('src/bricks');
      expect(mockFs.readdir).toHaveBeenCalled();
    });

    it('should handle missing directory gracefully', async () => {
      const error = new Error('ENOENT');
      error.code = 'ENOENT';
      mockFs.readdir.mockRejectedValue(error);
      
      const files = await generator.scanDirectory('nonexistent');
      expect(files).toEqual([]);
    });
  });

  describe('isBrickFile', () => {
    it('should identify brick files', () => {
      expect(generator.isBrickFile('brick.js')).toBe(true);
      expect(generator.isBrickFile('brick.ts')).toBe(true);
    });

    it('should exclude test files', () => {
      expect(generator.isBrickFile('brick.test.js')).toBe(false);
      expect(generator.isBrickFile('brick.spec.ts')).toBe(false);
    });
  });

  describe('extractJSDoc', () => {
    it('should extract JSDoc comment', () => {
      const content = `/**
       * Test function
       */
      function test() {}`;
      
      const jsdoc = generator.extractJSDoc(content);
      expect(jsdoc).toContain('/**');
      expect(jsdoc).toContain('Test function');
    });

    it('should return null for no JSDoc', () => {
      const content = 'function test() {}';
      const jsdoc = generator.extractJSDoc(content);
      expect(jsdoc).toBeNull();
    });
  });

  describe('parseJSDocTags', () => {
    it('should parse JSDoc tags', () => {
      const jsdoc = `/**
       * Test function
       * @param {string} name - Name parameter
       * @returns {boolean} Result
       */`;
      
      const tags = generator.parseJSDocTags(jsdoc);
      expect(tags.description).toBe('Test function');
      expect(tags.params).toHaveLength(1);
      expect(tags.returns).toBeDefined();
    });
  });

  describe('analyzeBrick', () => {
    it('should analyze brick file', async () => {
      const content = `/**
       * Test brick
       * @param {string} input - Input param
       * @returns {string} Output
       */
      export function testBrick(input) {
        return input;
      }`;
      
      mockFs.readFile.mockResolvedValue(content);
      mockPath.relative.mockReturnValue('src/bricks/test.js');
      
      const brick = await generator.analyzeBrick('/full/path/test.js');
      
      expect(brick).toBeDefined();
      expect(brick.name).toBe('test');
      expect(brick.type).toBe('utility');
      expect(brick.lines).toBeGreaterThan(0);
    });
  });

  describe('generateIndex', () => {
    it('should generate complete index', async () => {
      mockFs.readdir.mockResolvedValue([]);
      
      const index = await generator.generateIndex();
      
      expect(index).toBeDefined();
      expect(index.version).toBe('2.0');
      expect(index.bricks).toEqual([]);
      expect(index.statistics).toBeDefined();
    });
  });

  describe('saveIndex', () => {
    it('should save index to file', async () => {
      mockFs.readdir.mockResolvedValue([]);
      
      await generator.saveIndex();
      
      expect(mockFs.mkdir).toHaveBeenCalled();
      expect(mockFs.writeFile).toHaveBeenCalled();
    });
  });
});
