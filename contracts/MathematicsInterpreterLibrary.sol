// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/*
 * @title MathematicsInterpreterLibrary
 *
 * @author YoungDeveloper78
 *
 * @notice This library provides functions for interpreting and calculating the results of mathematical expressions.
 *
 * @dev This library can process expressions containing operators such as +, -, *, /, %, and ^,
 *      as well as parentheses for defining the order of operations.
 *
 * @warning Users of this library should be cautious when providing untrusted input strings,
 *          as it may lead to unexpected results or vulnerabilities if used improperly.
 *
 * @notice This library is provided "as is," and the author makes no guarantees about
 *         its correctness or suitability for any particular purpose.
 */
library MathematicsInterpreterLibrary {
    /**
     * @notice Calculates the result of a mathematical expression.
     * @param input The input string containing the mathematical expression.
     * @return The result of the mathematical expression as an integer (int).
     */
    function calculateExpression(
        string memory input
    ) public pure returns (int) {
        bytes memory inputBytes = bytes(input);
        int[] memory tokens = new int[](0);
        bytes1[] memory operators = new bytes1[](0);

        for (uint i = 0; i < inputBytes.length; i++) {
            bytes1 c = inputBytes[i];
            if (c == bytes1(" ")) {
                continue; // Skip spaces
            } else if (c == bytes1("(")) {
                operators = pushToOperators(operators, c); // Push opening parenthesis
            } else if (c == bytes1(")")) {
                // Process until the matching opening parenthesis is found
                while (
                    operators.length > 0 &&
                    operators[operators.length - 1] != bytes1("(")
                ) {
                    int b = tokens[tokens.length - 1];
                    int a = tokens[tokens.length - 2];
                    bytes1 op = operators[operators.length - 1];
                    int result = calculate(a, b, op);
                    tokens = popFromTokens(tokens);
                    tokens = popFromTokens(tokens);
                    tokens = pushToTokens(tokens, result);
                    operators = popFromOperators(operators);
                }
                operators = popFromOperators(operators); // Pop the matching '('
            } else if (c == bytes1("^")) {
                // Handle exponentiation operator
                operators = pushToOperators(operators, c);
            } else if (
                c == bytes1("+") ||
                c == bytes1("-") ||
                c == bytes1("*") ||
                c == bytes1("/") ||
                c == bytes1("%")
            ) {
                // Process operators based on precedence
                while (
                    operators.length > 0 &&
                    hasPrecedence(c, operators[operators.length - 1])
                ) {
                    int b = tokens[tokens.length - 1];
                    int a = tokens[tokens.length - 2];
                    bytes1 op = operators[operators.length - 1];
                    int result = calculate(a, b, op);
                    tokens = popFromTokens(tokens);
                    tokens = popFromTokens(tokens);
                    tokens = pushToTokens(tokens, result);
                    operators = popFromOperators(operators);
                }
                operators = pushToOperators(operators, c); // Push current operator
            } else {
                // Parse numbers
                int number = 0;
                bool isNegative = false;

                if (
                    c == bytes1("-") &&
                    (i == 0 || inputBytes[i - 1] == bytes1("("))
                ) {
                    // Handle negative numbers
                    isNegative = true;
                    i++;
                }

                while (
                    i < inputBytes.length &&
                    uint8(inputBytes[i]) >= 48 &&
                    uint8(inputBytes[i]) <= 57
                ) {
                    number = number * 10 + int(uint(uint8(inputBytes[i]) - 48));
                    i++;
                }
                i--; // Adjust index to correct position

                if (isNegative) {
                    number = -number; // Negate the number if negative
                }

                tokens = pushToTokens(tokens, number); // Push parsed number to tokens
            }
        }

        // Process remaining operators in the stack
        while (operators.length > 0) {
            int b = tokens[tokens.length - 1];
            int a = tokens[tokens.length - 2];
            bytes1 op = operators[operators.length - 1];
            int result = calculate(a, b, op);
            tokens = popFromTokens(tokens);
            tokens = popFromTokens(tokens);
            tokens = pushToTokens(tokens, result);
            operators = popFromOperators(operators);
        }

        require(tokens.length == 1, "Invalid expression");
        return tokens[0]; // Return the final result
    }

    function pushToOperators(
        bytes1[] memory operators,
        bytes1 item
    ) private pure returns (bytes1[] memory) {
        bytes1[] memory newOperators = new bytes1[](operators.length + 1);
        for (uint i = 0; i < operators.length; i++) {
            newOperators[i] = operators[i];
        }
        newOperators[operators.length] = item; // Add new operator
        return newOperators;
    }

    function popFromOperators(
        bytes1[] memory operators
    ) private pure returns (bytes1[] memory) {
        require(operators.length > 0, "Operators underflow");
        bytes1[] memory newOperators = new bytes1[](operators.length - 1);
        for (uint i = 0; i < newOperators.length; i++) {
            newOperators[i] = operators[i]; // Copy existing operators
        }
        return newOperators;
    }

    function pushToTokens(
        int[] memory tokens,
        int item
    ) private pure returns (int[] memory) {
        int[] memory newTokens = new int[](tokens.length + 1);
        for (uint i = 0; i < tokens.length; i++) {
            newTokens[i] = tokens[i]; // Copy existing tokens
        }
        newTokens[tokens.length] = item; // Add new token
        return newTokens;
    }

    function popFromTokens(
        int[] memory tokens
    ) private pure returns (int[] memory) {
        require(tokens.length > 0, "Tokens underflow");
        int[] memory newTokens = new int[](tokens.length - 1);
        for (uint i = 0; i < newTokens.length; i++) {
            newTokens[i] = tokens[i]; // Copy existing tokens
        }
        return newTokens;
    }

    /**
     * @notice Checks if one operator has precedence over another.
     * @param op1 The first operator.
     * @param op2 The second operator.
     * @return True if op1 has precedence over op2, false otherwise.
     */
    function hasPrecedence(bytes1 op1, bytes1 op2) private pure returns (bool) {
        if (op2 == bytes1("(") || op2 == bytes1(")")) {
            return false; // Parentheses have the lowest precedence
        }
        if (
            (op1 == bytes1("*") ||
                op1 == bytes1("/") ||
                op1 == bytes1("^") ||
                op1 == bytes1("%")) &&
            (op2 == bytes1("+") || op2 == bytes1("-"))
        ) {
            return false; // Higher precedence for * / ^ %
        } else {
            return true; // Otherwise, op1 has precedence
        }
    }

    /**
     * @notice Performs a calculation with two integers and an operator.
     * @param a The first integer.
     * @param b The second integer.
     * @param op The operator (+, -, *, /, ^, %).
     * @return The result of the calculation as an integer (int).
     */
    function calculate(int a, int b, bytes1 op) private pure returns (int) {
        if (op == bytes1("+")) {
            return a + b;
        } else if (op == bytes1("-")) {
            return a - b;
        } else if (op == bytes1("*")) {
            return a * b;
        } else if (op == bytes1("/")) {
            require(b != 0, "Cannot divide by zero");
            return a / b;
        } else if (op == bytes1("^")) {
            int result = 1;
            for (int i = 0; i < b; i++) {
                result *= a; // Calculate power
            }
            return result;
        } else if (op == bytes1("%")) {
            require(b != 0, "Cannot modulo by zero");
            return a % b;
        }
        revert("Invalid operator"); // Fallback for invalid operators
    }

    /**
     * @notice Extracts variable values (unsigned integers) from an input byte string.
     * @param inputBytes The input byte string.
     * @return An array of extracted unsigned integers.
     */
    function extractVariables(
        bytes memory inputBytes
    ) public pure returns (uint8[] memory) {
        uint8[] memory xNumbers = new uint8[](inputBytes.length); // Maximum possible number of x numbers
        uint8 xNumberCount = 0;
        uint8 currentNumber = 0;
        bool isParsingXNumber = false;

        for (uint i = 0; i < inputBytes.length; i++) {
            if (isParsingXNumber) {
                // Continue parsing the current number
                if (uint8(inputBytes[i]) >= 48 && uint8(inputBytes[i]) <= 57) {
                    currentNumber =
                        currentNumber *
                        10 +
                        uint8(uint8(inputBytes[i]) - 48); // Parse digit
                } else {
                    // Stop parsing current number
                    xNumbers[xNumberCount] = currentNumber;
                    xNumberCount++;
                    isParsingXNumber = false;
                    currentNumber = 0; // Reset for next number
                }
            } else if (
                uint8(inputBytes[i]) >= 48 && uint8(inputBytes[i]) <= 57
            ) {
                // Start parsing a new number
                currentNumber = uint8(inputBytes[i]) - 48; // Parse digit
                isParsingXNumber = true; // Mark as parsing number
            }
        }

        // Capture any remaining number after the loop
        if (isParsingXNumber) {
            xNumbers[xNumberCount] = currentNumber;
            xNumberCount++;
        }

        uint8[] memory result = new uint8[](xNumberCount);
        for (uint8 j = 0; j < xNumberCount; j++) {
            result[j] = xNumbers[j]; // Return only parsed numbers
        }

        return result;
    }
}
