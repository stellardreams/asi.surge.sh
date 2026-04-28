# Standard Operating Procedure: Brick Creation

## Purpose
This SOP defines the process for creating new Bricks in the project.

## Prerequisites
- [ ] Task or pattern identified for extraction
- [ ] Requirements documented
- [ ] Design reviewed

## Steps

### 1. Design Phase (30-60 minutes)

1. **Define the Interface**
   - Identify inputs and outputs
   - Define types for all parameters
   - Document expected behavior

2. **Write the Specification**
   ```typescript
   /**
    * [One-line purpose]
    * 
    * [Detailed description]
    * 
    * @param {Type} paramName - Description
    * @returns {Type} Description
    * @example
    * ```typescript
    * // Example usage
    * ```
    */
   ```

3. **Review Design**
   - Does it follow Single Responsibility Principle?
   - Is it under 200 lines?
   - Are types clear?
   - Is it testable?

### 2. Implementation Phase (1-4 hours)

1. **Create the File**
   - Name: `kebab-case.ts` or `kebab-case.sol`
   - Location: Appropriate module directory
   - Export: Default or named as appropriate

2. **Write the Implementation**
   - Keep it simple
   - Follow existing patterns
   - Add comments for complex logic
   - Stay under 200 lines

3. **Add Type Annotations**
   - All parameters typed
   - Return type specified
   - Use strict mode

### 3. Testing Phase (1-2 hours)

1. **Write Unit Tests**
   - Test all code paths
   - Include edge cases
   - Mock dependencies
   - Aim for 100% coverage

2. **Write Integration Tests**
   - Test with other Bricks
   - Verify interfaces
   - Check data flow

3. **Run Tests**
   ```bash
   npm test
   ```

### 4. Documentation Phase (30-60 minutes)

1. **Add JSDoc Comments**
   - Purpose
   - Parameters
   - Returns
   - Examples
   - Errors

2. **Create Usage Examples**
   - Simple example
   - Complex example
   - Edge cases

3. **Update Registry**
   - Add to `docs/brick-index.json`
   - Tag with `@Brick`

### 5. Review Phase (1-2 hours)

1. **Code Review**
   - Peer review
   - Address feedback
   - Re-run tests

2. **Merge**
   - Squash commits
   - Write commit message
   - Update changelog

## Checklist

Before marking complete:
- [ ] Implementation complete
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Code review approved
- [ ] Added to registry
- [ ] Linting passes

## Templates

### JavaScript/TypeScript Brick Template
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
export function brickName(
  paramName: Type,
  optionalParam?: Type
): ReturnType {
  // Implementation
}
```

### Solidity Brick Template
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BrickName
 * @dev [One-line purpose]
 * 
 * [Detailed description]
 */
contract BrickName {
    /**
     * @dev [One-line purpose]
     * 
     * [Detailed description]
     * 
     * @param paramName Description
     * @return Description of return value
     */
    function brickName(
        Type paramName
    ) external returns (ReturnType) {
        // Implementation
    }
}
```

### Test Template
```typescript
import { describe, it, expect } from 'vitest';
import { brickName } from './brick-name';

describe('brickName', () => {
  it('should [description]', () => {
    // Test implementation
  });

  it('should handle edge case', () => {
    // Edge case test
  });
});
```

## Common Patterns

### Pattern 1: Data Transformation
```typescript
export function transformData(input: InputType): OutputType {
  // Transform logic
}
```

### Pattern 2: Validation
```typescript
export function validateInput(input: unknown): boolean {
  // Validation logic
}
```

### Pattern 3: Service Call
```typescript
export async function callService(
  params: ServiceParams
): Promise<ServiceResult> {
  // Service logic
}
```

## Troubleshooting

### Brick Too Large
- Split into smaller Bricks
- Extract helper functions
- Use composition

### Unclear Interface
- Simplify parameters
- Use builder pattern
- Add more documentation

### Hard to Test
- Reduce dependencies
- Use dependency injection
- Extract pure functions

## Resources

- `docs/BRICK_STANDARDS.md` - Brick standards
- `docs/brick-index.json` - Brick registry
- Issue #45 - Modular Systems Architecture

## Support

For questions or issues:
1. Check existing Bricks for examples
2. Review `docs/BRICK_STANDARDS.md`
3. Open an issue
4. Ask in discussions

---

**Version**: 1.0  
**Last Updated**: 2026-04-26  
**Status**: ✅ Active
