/**
 * @jest-environment node
 */

import { describe, it, expect } from 'vitest';
import { 
  generateBscVerification, 
  displayBscVerification,
  isValidBscAddress 
} from '../../../src/bricks/utils/bsc-verify-helper.js';

describe('BSC Verification Helper Brick', () => {
  describe('generateBscVerification', () => {
    it('should generate verification info for valid address', () => {
      const address = '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7';
      const info = generateBscVerification(address, 'TestToken');
      
      expect(info).toHaveProperty('contractAddress', address);
      expect(info).toHaveProperty('contractName', 'TestToken');
      expect(info).toHaveProperty('network', 'BSC Testnet');
      expect(info).toHaveProperty('verificationUrl');
      expect(info.verificationUrl).toContain('bscscan.com');
      expect(info).toHaveProperty('steps');
      expect(Array.isArray(info.steps)).toBe(true);
      expect(info.steps.length).toBeGreaterThan(0);
    });

    it('should throw error for missing address', () => {
      expect(() => generateBscVerification()).toThrow('Contract address is required');
      expect(() => generateBscVerification('')).toThrow('Contract address is required');
    });

    it('should use default contract name', () => {
      const info = generateBscVerification('0x123...');
      expect(info.contractName).toBe('TestToken');
    });

    it('should include compiler version', () => {
      const info = generateBscVerification('0x123...');
      expect(info.compilerVersion).toBe('v0.8.20+commit.a1b79de6');
    });

    it('should include license', () => {
      const info = generateBscVerification('0x123...');
      expect(info.license).toBe('MIT');
    });

    it('should have getInstructions method', () => {
      const info = generateBscVerification('0x123...');
      expect(typeof info.getInstructions).toBe('function');
      
      const instructions = info.getInstructions();
      expect(typeof instructions).toBe('string');
      expect(instructions.length).toBeGreaterThan(0);
    });
  });

  describe('displayBscVerification', () => {
    it('should be a function', () => {
      expect(typeof displayBscVerification).toBe('function');
    });

    it('should not throw when called with valid address', () => {
      expect(() => displayBscVerification('0x123...')).not.toThrow();
    });
  });

  describe('isValidBscAddress', () => {
    it('should validate correct BSC address', () => {
      expect(isValidBscAddress('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7')).toBe(true);
    });

    it('should reject invalid addresses', () => {
      expect(isValidBscAddress('invalid')).toBe(false);
      expect(isValidBscAddress('0x123')).toBe(false);
      expect(isValidBscAddress('')).toBe(false);
    });

    it('should reject non-string inputs', () => {
      expect(isValidBscAddress(123)).toBe(false);
      expect(isValidBscAddress(null)).toBe(false);
      expect(isValidBscAddress(undefined)).toBe(false);
    });
  });
});
