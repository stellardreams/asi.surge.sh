# Standard Operating Procedure: Docstring Template

## Purpose
This SOP defines the standard format for documenting Bricks (functions, classes, contracts).

## JavaScript/TypeScript Docstring Standard

### Function Template
```typescript
/**
 * [One-line purpose - imperative verb phrase]
 * 
 * [Detailed description - 2-4 sentences explaining what this does,
 * why it exists, and when to use it. Include important details about
 * behavior, side effects, and constraints.]
 * 
 * @param {Type} paramName - [Description of parameter, including
 *   valid range, format requirements, and any constraints]
 * @param {Type} [optionalParam] - [Description of optional parameter]
 * @param {...Type} restParam - [Description of rest parameter]
 * @returns {Type} [Description of return value, including format
 *   and any guarantees about the result]
 * @throws {ErrorType} [When this error is thrown and why]
 * @throws {AnotherError} [Additional error conditions]
 * @example
 * ```typescript
 * // Basic usage
 * const result = functionName(input);
 * console.log(result); // Expected output
 * 
 * // With options
 * const result2 = functionName(input, { option: true });
 * 
 * // Error handling
 * try {
 *   functionName(invalidInput);
 * } catch (error) {
 *   console.error(error);
 * }
 * ```
 * @see {@link RelatedFunction} - Related functionality
 * @see {@link https://link|External Reference} - Additional context
 * 
 * @remarks
 * [Additional implementation details, performance characteristics,
 * or important notes that don't fit in the main description]
 */
function functionName(
  paramName: Type,
  optionalParam?: Type,
  ...restParam: Type[]
): ReturnType {
  // Implementation
}
```

### Class Template
```typescript
/**
 * [One-line purpose - noun phrase]
 * 
 * [Detailed description - what this class represents, its role in
 * the system, and how it should be used. Include information about
 * lifecycle, thread safety, and any important behavioral contracts.]
 * 
 * @example
 * ```typescript
 * // Creating an instance
 * const instance = new ClassName(config);
 * 
 * // Using methods
 * instance.methodName(arg);
 * 
 * // Cleanup
 * instance.dispose();
 * ```
 * 
 * @remarks
 * [Important notes about implementation, thread safety, performance,
 * or usage patterns]
 */
class ClassName {
  /**
   * [Constructor description]
   * 
   * @param {Type} param - [Parameter description]
   */
  constructor(param: Type) {
    // Initialization
  }
  
  /**
   * [Method description]
   * 
   * @param {Type} param - [Parameter description]
   * @returns {Type} [Return description]
   */
  methodName(param: Type): ReturnType {
    // Implementation
  }
}
```

## Solidity Docstring Standard

### Contract Template
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ContractName
 * @dev [One-line purpose]
 * 
 * [Detailed description - what this contract does, its role in the
 * system, and important behavioral characteristics. Include
 * information about access control, state management, and any
 * security considerations.]
 * 
 * @author [Author Name]
 * @custom:security-contact [Security contact email]
 * 
 * @notice [Important user-facing information]
 * 
 * @dev [Implementation details, design decisions, and technical
 * notes for developers]
 * 
 * @custom:example
 * ```solidity
 * // Example usage
 * ContractName contract = new ContractName();
 * contract.functionName(param);
 * ```
 */
contract ContractName {
    // State variables
    
    /**
     * @dev [Event description]
     * @param param [Parameter description]
     */
    event EventName(Type param);
    
    /**
     * @dev [Constructor description]
     * @param param [Parameter description]
     */
    constructor(Type param) {
        // Initialization
    }
    
    /**
     * @dev [Function description]
     * 
     * @param param [Parameter description]
     * @return result [Return value description]
     * 
     * @dev Requirements:
     * - [Requirement 1]
     * - [Requirement 2]
     * 
     * @dev Emits:
     * - EventName when [condition]
     * 
     * @dev Reverts if:
     * - [Condition 1]
     * - [Condition 2]
     */
    function functionName(
        Type param
    ) external returns (ReturnType result) {
        // Implementation
    }
}
```

### Function Template
```solidity
/**
 * @dev [One-line purpose]
 * 
 * [Detailed description - what this function does, when it should
 * be called, and any important behavioral details.]
 * 
 * @param param1 [Description of param1]
 * @param param2 [Description of param2]
 * @return result1 [Description of return value 1]
 * @return result2 [Description of return value 2]
 * 
 * @dev Requirements:
 * - Caller must have appropriate role
 * - Contract must not be paused
 * - param1 must be > 0
 * 
 * @dev Emits:
 * - EventName with updated values
 * 
 * @dev Reverts if:
 * - Caller is not authorized
 * - Contract is paused
 * - param1 is invalid
 * 
 * @dev Security considerations:
 * - [Reentrancy: Not vulnerable - state changes before external call]
 * - [Access control: Only role can call]
 * - [Integer overflow: Protected by Solidity 0.8.x]
 */
function functionName(
    Type param1,
    Type param2
) external returns (ReturnType1 result1, ReturnType2 result2) {
    // Implementation
}
```

## Documentation Rules

### Required Elements
Every public function MUST have:
1. ✅ One-line purpose (imperative verb phrase)
2. ✅ Detailed description (2-4 sentences)
3. ✅ All parameters documented
4. ✅ Return value documented
5. ✅ Error conditions documented
6. ✅ At least one usage example

### Optional Elements
Include when relevant:
- Performance characteristics
- Thread safety notes
- Security considerations
- Implementation details
- Related functions/contracts
- External references

### Language Rules
- Use **imperative mood** for one-line purpose ("Calculate total", not "Calculates total")
- Use **present tense** for descriptions
- Be **specific** about behavior and constraints
- Include **units** for numeric values (wei, seconds, etc.)
- Document **edge cases** and **error conditions**

## Examples

### Good Example
```typescript
/**
 * Calculates the total token balance for an account
 * 
 * Sums all token amounts across different token types for the given
 * account address. Returns the total in wei. This function is used
 * by the UI to display account balances and by settlement functions
 * to verify available funds.
 * 
 * @param {string} account - Ethereum address (0x format, checksummed)
 * @param {string[]} [tokenTypes] - Optional list of token types to include
 *   (defaults to all available tokens)
 * @returns {bigint} Total balance in wei (10^18 units per token)
 * @throws {InvalidAddressError} If account is not a valid Ethereum address
 * @throws {NetworkError} If blockchain query fails
 * 
 * @example
 * ```typescript
 * // Get all balances
 * const total = calculateTotalBalance("0x123...");
 * console.log(ethers.formatEther(total));
 * 
 * // Get specific token balances
 * const erc20Total = calculateTotalBalance("0x123...", ["ERC20"]);
 * ```
 * 
 * @remarks
 * This function makes multiple contract calls and may be expensive
 * for accounts with many token holdings. Consider caching results
 * for frequently accessed accounts.
 */
function calculateTotalBalance(
  account: string,
  tokenTypes?: string[]
): bigint {
  // Implementation
}
```

### Bad Example (Don't Do This)
```typescript
// ❌ No documentation
function calcBalance(a, t) {
  return 0;
}

// ❌ Incomplete documentation
/**
 * Gets balance.
 * @param a Account
 * @returns Balance
 */
function getBalance(a) {
  return 0;
}

// ❌ Wrong tense
/**
 * Calculated the balance.
 * @param account The account.
 * @returns The balance.
 */
function calculateBalance(account) {
  return 0;
}
```

## Validation

Use this checklist when reviewing documentation:

- [ ] One-line purpose is clear and imperative
- [ ] Detailed description explains "what" and "why"
- [ ] All parameters are documented with types
- [ ] Return value is documented with type
- [ ] Error conditions are documented
- [ ] At least one example is provided
- [ ] Example is correct and runnable
- [ ] No spelling or grammar errors
- [ ] Units are specified for numeric values
- [ ] Edge cases are mentioned

## Tools

### TypeDoc
Generate API documentation from JSDoc comments:
```bash
npm run docs:generate
```

### ESLint
Enforce documentation rules:
```bash
npm run lint:docs
```

### Prettier
Format documentation:
```bash
npm run format:docs
```

## Resources

- [TypeDoc Documentation](https://typedoc.org/)
- [JSDoc Reference](https://jsdoc.app/)
- [Solidity NatSpec](https://docs.soliditylang.org/en/latest/natspec-format.html)

## Support

For documentation questions:
1. Check existing Bricks for examples
2. Review this SOP
3. Ask in discussions
4. Open an issue

---

**Version**: 1.0  
**Last Updated**: 2026-04-26  
**Status**: ✅ Active
