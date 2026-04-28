/**
 * @jest-environment node
 */

import { describe, it, expect } from 'vitest';
import { getBscTestnetFaucets, displayBscFaucetInfo } from '../../../src/bricks/utils/bsc-faucet-info.js';

describe('BSC Faucet Info Brick', () => {
  describe('getBscTestnetFaucets', () => {
    it('should return an array of faucet objects', () => {
      const faucets = getBscTestnetFaucets();
      
      expect(Array.isArray(faucets)).toBe(true);
      expect(faucets.length).toBeGreaterThan(0);
    });

    it('should return faucets with required properties', () => {
      const faucets = getBscTestnetFaucets();
      
      faucets.forEach(faucet => {
        expect(faucet).toHaveProperty('name');
        expect(faucet).toHaveProperty('url');
        expect(faucet).toHaveProperty('description');
        expect(typeof faucet.name).toBe('string');
        expect(typeof faucet.url).toBe('string');
        expect(typeof faucet.description).toBe('string');
      });
    });

    it('should include official BSC faucet', () => {
      const faucets = getBscTestnetFaucets();
      const hasOfficialFaucet = faucets.some(f => 
        f.name.toLowerCase().includes('bsc') || 
        f.name.toLowerCase().includes('official')
      );
      
      expect(hasOfficialFaucet).toBe(true);
    });

    it('should return valid URLs', () => {
      const faucets = getBscTestnetFaucets();
      
      faucets.forEach(faucet => {
        expect(faucet.url).toMatch(/^https?:\/\//);
        expect(faucet.url.length).toBeGreaterThan(10);
      });
    });
  });

  describe('displayBscFaucetInfo', () => {
    it('should be a function', () => {
      expect(typeof displayBscFaucetInfo).toBe('function');
    });

    it('should not throw when called', () => {
      expect(() => displayBscFaucetInfo()).not.toThrow();
    });
  });
});
