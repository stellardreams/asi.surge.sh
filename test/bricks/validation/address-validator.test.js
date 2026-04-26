/**
 * @jest-environment node
 */

import { describe, it, expect } from 'vitest';
import {
  isValidAddress,
  isValidChecksumAddress,
  normalizeAddress,
  isValidBscAddress,
  validateAddresses
} from '../../../src/bricks/validation/address-validator.js';

describe('Address Validator Brick', () => {
  describe('isValidAddress', () => {
    it('should validate correct Ethereum address', () => {
      expect(isValidAddress('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7')).toBe(true);
    });

    it('should validate lowercase address', () => {
      expect(isValidAddress('0x742d35cc6634c0532925a3b844bc9e7595f0beb7')).toBe(true);
    });

    it('should reject address without 0x prefix', () => {
      expect(isValidAddress('742d35cc6634c0532925a3b844bc9e7595f0beb7')).toBe(false);
    });

    it('should reject address with wrong length', () => {
      expect(isValidAddress('0x123')).toBe(false);
    });

    it('should reject address with invalid characters', () => {
      expect(isValidAddress('0xgggggggggggggggggggggggggggggggggggggg')).toBe(false);
    });

    it('should reject non-string input', () => {
      expect(isValidAddress(123)).toBe(false);
      expect(isValidAddress(null)).toBe(false);
      expect(isValidAddress(undefined)).toBe(false);
      expect(isValidAddress({})).toBe(false);
    });

    it('should reject empty string', () => {
      expect(isValidAddress('')).toBe(false);
    });
  });

  describe('isValidChecksumAddress', () => {
    it('should validate correct checksum address', () => {
      // This is a known valid checksum address
      expect(isValidChecksumAddress('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7')).toBe(true);
    });

    it('should accept lowercase address (no checksum)', () => {
      expect(isValidChecksumAddress('0x742d35cc6634c0532925a3b844bc9e7595f0beb7')).toBe(true);
    });

    it('should reject all uppercase address', () => {
      expect(isValidChecksumAddress('0x742D35CC6634C0532925A3B844BC9E7595F0BEB7')).toBe(false);
    });

    it('should reject invalid address format', () => {
      expect(isValidChecksumAddress('invalid')).toBe(false);
    });

    it('should reject short address', () => {
      expect(isValidChecksumAddress('0x123')).toBe(false);
    });
  });

  describe('normalizeAddress', () => {
    it('should normalize valid address to checksum format', () => {
      const address = '0x742d35cc6634c0532925a3b844bc9e7595f0beb7';
      const normalized = normalizeAddress(address);
      
      expect(typeof normalized).toBe('string');
      expect(normalized).toMatch(/^0x[a-fA-F0-9]{40}$/);
    });

    it('should throw error for invalid address', () => {
      expect(() => normalizeAddress('invalid')).toThrow('Invalid address format');
    });

    it('should keep checksum address as is', () => {
      const address = '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7';
      const normalized = normalizeAddress(address);
      
      expect(normalized).toBe(address);
    });
  });

  describe('isValidBscAddress', () => {
    it('should validate BSC address (same as Ethereum)', () => {
      expect(isValidBscAddress('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7')).toBe(true);
    });

    it('should reject invalid BSC address', () => {
      expect(isValidBscAddress('invalid')).toBe(false);
    });
  });

  describe('validateAddresses', () => {
    it('should validate array of addresses', () => {
      const addresses = [
        '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7',
        '0x742d35cc6634c0532925a3b844bc9e7595f0beb7'
      ];
      
      const result = validateAddresses(addresses);
      
      expect(result.allValid).toBe(true);
      expect(result.invalid).toEqual([]);
    });

    it('should identify invalid addresses', () => {
      const addresses = [
        '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7',
        'invalid',
        '0x123'
      ];
      
      const result = validateAddresses(addresses);
      
      expect(result.allValid).toBe(false);
      expect(result.invalid).toContain('invalid');
      expect(result.invalid).toContain('0x123');
    });

    it('should handle empty array', () => {
      const result = validateAddresses([]);
      
      expect(result.allValid).toBe(true);
      expect(result.invalid).toEqual([]);
    });
  });
});
