## MathematicsInterpreterLibrary

### Overview

The `MathematicsInterpreterLibrary` is a Solidity library designed for interpreting and calculating mathematical expressions. It supports various arithmetic operators, parentheses for defining operation precedence, and features for extracting variable values from input strings.

### Features

- **Arithmetic Operations**: Supports addition, subtraction, multiplication, division, exponentiation, and modulo.
- **Expression Evaluation**: Calculates results based on the order of operations and nested parentheses.
- **Variable Extraction**: Allows extraction of variable values (e.g., those prefixed with 'x') from input strings.

### Installation

To use the `MathematicsInterpreterLibrary` in your Solidity project:

**Prerequisites**

- **Solidity**: Version 0.8.0 or higher.
- **Development Environment**: Set up a Solidity-compatible environment (e.g., Remix, Truffle, Hardhat).

**Steps**

1. **Copy the Library**: You can copy the code directly into your project or clone it from a repository.
2. **Import the Library**: Add the following import statement in your Solidity files:

```solidity
import "./MathematicsInterpreterLibrary.sol";
```

### Usage

**Calculating Expressions**

To calculate a mathematical expression, use the `calculateExpression` function. The input should be a string that represents the expression you want to evaluate:

```solidity
string memory expression = "3 + 5 * (2 ^ 3) - 6";
int result = MathematicsInterpreterLibrary.calculateExpression(expression);
// result will be 19
```
### Usage

**Extracting Variables**

Use the `extractVariables` function to extract variable values from a given input byte string:

```solidity
bytes memory inputBytes = "x1=3,x2=5,x3=2";
uint8[] memory variables = MathematicsInterpreterLibrary.extractVariables(inputBytes);
// variables will contain the values [3, 5, 2]
```
### Usage

**Removing Variable Tokens**

To remove variable tokens from an input string, you can use the `removeXNumbers` function:

```solidity
bytes memory inputBytes = "3 + x1 - 5 * x2";
bytes memory cleanedBytes = MathematicsInterpreterLibrary.removeXNumbers(inputBytes);
// cleanedBytes will contain "3 + - 5 * "
```
