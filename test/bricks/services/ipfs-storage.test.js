/**
 * @jest-environment node
 */

import { describe, it, expect, vi } from 'vitest';
import { IPFSStorage } from '../../../src/bricks/services/ipfs-storage.js';

// Mock Helia modules
vi.mock('helia', () => ({
  createHelia: vi.fn()
}));

vi.mock('@helia/unixfs', () => ({
  unixfs: vi.fn()
}));

describe('IPFS Storage Brick', () => {
  let storage;
  let mockHelia;
  let mockFs;

  beforeEach(() => {
    mockFs = {
      addBytes: vi.fn(),
      cat: vi.fn()
    };
    
    mockHelia = {
      stop: vi.fn()
    };
    
    require('helia').createHelia.mockResolvedValue(mockHelia);
    require('@helia/unixfs').unixfs.mockReturnValue(mockFs);
    
    storage = new IPFSStorage({ autoInit: false });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('constructor', () => {
    it('should create instance with default options', () => {
      const instance = new IPFSStorage();
      expect(instance).toBeDefined();
      expect(instance.initialized).toBe(false);
    });

    it('should accept options', () => {
      const instance = new IPFSStorage({ autoInit: false });
      expect(instance.autoInit).toBe(false);
    });
  });

  describe('init', () => {
    it('should initialize Helia node', async () => {
      await storage.init();
      
      expect(storage.initialized).toBe(true);
      expect(storage.helia).toBe(mockHelia);
      expect(storage.fs).toBe(mockFs);
    });

    it('should throw error if initialization fails', async () => {
      const error = new Error('Failed to create Helia');
      require('helia').createHelia.mockRejectedValue(error);
      
      await expect(storage.init()).rejects.toThrow('Failed to create Helia');
      expect(storage.initialized).toBe(false);
    });
  });

  describe('storeBlueprint', () => {
    beforeEach(async () => {
      await storage.init();
    });

    it('should store blueprint and return CID', async () => {
      const mockCid = { toString: () => 'QmTest123' };
      mockFs.addBytes.mockResolvedValue(mockCid);
      
      const blueprint = {
        type: '3-stage-AMU',
        name: 'Test Design',
        components: []
      };
      
      const cid = await storage.storeBlueprint(blueprint);
      
      expect(cid).toBe('QmTest123');
      expect(mockFs.addBytes).toHaveBeenCalled();
    });

    it('should throw error if not initialized', async () => {
      const uninitializedStorage = new IPFSStorage({ autoInit: false });
      
      await expect(uninitializedStorage.storeBlueprint({}))
        .rejects
        .toThrow('IPFSStorage not initialized');
    });

    it('should throw error if storage fails', async () => {
      const error = new Error('Storage failed');
      mockFs.addBytes.mockRejectedValue(error);
      
      await expect(storage.storeBlueprint({}))
        .rejects
        .toThrow('Failed to store blueprint');
    });
  });

  describe('retrieveBlueprint', () => {
    beforeEach(async () => {
      await storage.init();
    });

    it('should retrieve blueprint by CID', async () => {
      const blueprint = { type: 'test', name: 'Test' };
      const content = JSON.stringify(blueprint, null, 2);
      const chunks = [Buffer.from(content)];
      
      mockFs.cat.mockImplementation(async function* () {
        yield chunks[0];
      });
      
      const result = await storage.retrieveBlueprint('QmTest123');
      
      expect(result).toEqual(blueprint);
    });

    it('should throw error if not initialized', async () => {
      const uninitializedStorage = new IPFSStorage({ autoInit: false });
      
      await expect(uninitializedStorage.retrieveBlueprint('QmTest123'))
        .rejects
        .toThrow('IPFSStorage not initialized');
    });
  });

  describe('store', () => {
    beforeEach(async () => {
      await storage.init();
    });

    it('should store arbitrary data', async () => {
      const mockCid = { toString: () => 'QmData456' };
      mockFs.addBytes.mockResolvedValue(mockCid);
      
      const data = { key: 'value' };
      const cid = await storage.store(data);
      
      expect(cid).toBe('QmData456');
    });
  });

  describe('retrieve', () => {
    beforeEach(async () => {
      await storage.init();
    });

    it('should retrieve arbitrary data', async () => {
      const data = { key: 'value' };
      const content = JSON.stringify(data, null, 2);
      const chunks = [Buffer.from(content)];
      
      mockFs.cat.mockImplementation(async function* () {
        yield chunks[0];
      });
      
      const result = await storage.retrieve('QmTest123');
      
      expect(result).toEqual(data);
    });
  });

  describe('isInitialized', () => {
    it('should return initialization status', () => {
      expect(storage.isInitialized()).toBe(false);
    });
  });

  describe('close', () => {
    beforeEach(async () => {
      await storage.init();
    });

    it('should close Helia node', async () => {
      await storage.close();
      
      expect(mockHelia.stop).toHaveBeenCalled();
      expect(storage.initialized).toBe(false);
    });
  });
});
