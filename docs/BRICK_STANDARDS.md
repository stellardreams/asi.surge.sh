# Brick Standards

## Overview
A "Brick" is a modular, atomic unit of code that performs a single task exceptionally well. Bricks are the fundamental building blocks of our system, designed to be reusable, independently testable, and self-documenting.

## Brick Definition

A Brick must:
1. **Perform One Task** - Single responsibility principle
2. **Have Clear I/O** - Well-defined inputs and outputs
3. **Be Independently Testable** - Can be tested in isolation
4. **Be Documented** - Clear docstrings and type hints
5. **Follow Conventions** - Consistent with project standards

## Brick Constraints

- **Maximum Size**: 200 lines of code (excluding comments and blank lines)
- **Exceptions**: Must be documented and approved
- **Dependencies**: Minimize external dependencies; prefer internal Bricks

## Brick Types

### 1. Utility Bricks
Pure functions that transform data.

**Example:**
```typescript
/**
 * Formats a token amount for display
 * 
 * @param {bigint} amount - Amount in wei
 * @param {number} decimals - Token decimals (default: 18)
 * @returns {string} Formatted amount
 * @example
 * formatAmount(1000000000000000000n, 18) // "1.0"
 */
function formatAmount(amount: bigint, decimals: number = 18): string {
  const divisor = 10n ** BigInt(decimals);
  const whole = amount / divisor;
  const fraction = amount % divisor;
  return `${whole}.${fraction.toString().padStart(decimals, '0')}`;
}
```

### 2. Service Bricks
Handle business logic and external interactions.

**Example:**
```typescript
/**
 * Transfers tokens between accounts
 * 
 * @param {string} from - Sender address
 * @param {string} to - Recipient address
 * @param {bigint} amount - Amount to transfer
 * @returns {Promise<boolean>} Success status
 * @throws {Error} If transfer fails
 */
async function transferTokens(
  from: string,
  to: string,
  amount: bigint
): Promise<boolean> {
  // Implementation
}
```

### 3. Validation Bricks
Validate inputs and data structures.

**Example:**
```typescript
/**
 * Validates an Ethereum address
 * 
 * @param {string} address - Address to validate
 * @returns {boolean} True if valid
 * @example
 * isValidAddress("0x...") // true
 */
function isValidAddress(address: string): boolean {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
}
```

### 4. Contract Bricks
Smart contract functions and interfaces.

**Example:**
```solidity
/**
 * @dev Transfers tokens to a recipient
 * @param to The recipient address
 * @param amount The amount to transfer
 * @return success True if transfer succeeded
 */
function transfer(address to, uint256 amount) 
  external 
  returns (bool success);
```

## Brick Lifecycle

### 1. Creation
1. Identify a reusable task or pattern
2. Design the interface (inputs/outputs)
3. Implement with tests
4. Document thoroughly

### 2. Validation
1. Unit tests pass ✅
2. Integration tests pass ✅
3. Code review approved ✅
4. Documentation complete ✅

### 3. Publication
1. Add to brick registry
2. Tag with `@Brick` JSDoc
3. Update dependencies
4. Version appropriately

### 4. Maintenance
1. Monitor for issues
2. Update documentation
3. Refactor as needed
4. Deprecate when obsolete

## Brick Interface Standards

### JavaScript/TypeScript Bricks
```typescript
/**
 * [One-line purpose]
 * 
 * [Detailed description - what problem this Brick solves]
 * 
 * @param {Type} paramName - Description
 * @param {Type} [optionalParam] - Optional parameter description
 * @returns {Type} Description of return value
 * @throws {ErrorType} When something goes wrong
 * @example
 * ```typescript
 * const result = brickName(input);
 * console.log(result);
 * ```
 */
function brickName(param: Type): ReturnType {
  // Implementation
}
```

### Solidity Bricks
```solidity
/**
 * @dev [One-line purpose]
 * 
 * [Detailed description]
 * 
 * @param paramName Description
 * @return Description of return value
 */
function brickName(Type paramName) 
  external 
  returns (ReturnType)
{
  // Implementation
}
```

## Brick Composition

Bricks can be composed to build larger systems:

```
Small Bricks (20-50 lines)
    ↓
Medium Bricks (50-100 lines)
    ↓
Large Bricks (100-200 lines)
    ↓
Systems (200+ lines, composed of Bricks)
```

## Brick Registry

All Bricks are registered in `docs/brick-index.json`:

```json
{
  "bricks": [
    {
      "name": "formatAmount",
      "type": "utility",
      "file": "src/utils/format.ts",
      "description": "Formats token amounts for display",
      "dependencies": [],
      "testCoverage": 100
    }
  ]
}
```

## Brick Testing Standards

### Unit Tests
- Test all code paths
- Include edge cases
- Mock external dependencies
- Aim for 100% coverage

### Integration Tests
- Test Brick composition
- Verify interfaces
- Check data flow
- Test error handling

### Property-Based Tests
- Generate random inputs
- Verify invariants
- Test boundary conditions
- Ensure robustness

## Brick Documentation Requirements

Every Brick must have:
1. ✅ Clear purpose statement
2. ✅ Parameter descriptions
3. ✅ Return value description
4. ✅ Usage example
5. ✅ Error conditions
6. ✅ Type annotations
7. ✅ Test coverage report

## Brick Review Checklist

Before accepting a Brick:
- [ ] Performs a single task
- [ ] Under 200 lines
- [ ] Has clear I/O
- [ ] Fully documented
- [ ] Type hints present
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Code review approved
- [ ] No linting errors
- [ ] Added to registry

## Brick Deprecation

When deprecating a Brick:
1. Mark as `@deprecated` in docs
2. Provide migration path
3. Keep for one major version
4. Remove after migration period
5. Update all dependents

## Brick Versioning

Bricks follow semantic versioning:
- **Major**: Breaking changes to interface
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, no interface changes

## Brick Naming Conventions

- **Functions**: `camelCase` (e.g., `formatAmount`)
- **Contracts**: `PascalCase` (e.g., `TokenTransfer`)
- **Files**: Match primary Brick name
- **Tests**: `brickName.test.ts`

## Brick Performance Guidelines

- Minimize computational complexity
- Avoid unnecessary allocations
- Use efficient data structures
- Profile before optimizing
- Document performance characteristics

## Brick Security Guidelines

- Validate all inputs
- Handle errors gracefully
- Avoid side effects
- Minimize attack surface
- Document security considerations
- Include security tests

## Brick Examples

See `examples/bricks/` for complete working examples of:
- Utility Bricks
- Service Bricks
- Validation Bricks
- Contract Bricks

## Questions?

Refer to:
- `docs/SOPs/` - Standard Operating Procedures
- `docs/brick-index.json` - Brick registry
- Issue #45 - Modular Systems Architecture

---

**Last Updated**: 2026-04-26  
**Version**: 1.0  
**Status**: ✅ Active
