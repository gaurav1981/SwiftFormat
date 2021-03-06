//
//  Rules.swift
//  SwiftFormat
//
//  Version 0.8.2
//
//  Created by Nick Lockwood on 12/08/2016.
//  Copyright 2016 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/SwiftFormat
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

public typealias FormatRule = (Formatter) -> Void

/// Implement the following rules with respect to the spacing around parens:
/// * There is no space between an opening paren and the preceding identifier,
///   unless the identifier is one of the specified keywords
/// * There is no space between an opening paren and the preceding closing brace
/// * There is no space between an opening paren and the preceding closing square bracket
/// * There is space between a closing paren and following identifier
/// * There is space between a closing paren and following opening brace
/// * There is no space between a closing paren and following opening square bracket
public func spaceAroundParens(formatter: Formatter) {
    func spaceAfter(identifier: String) -> Bool {
        switch identifier {
        case "internal",
            "case",
            "for",
            "guard",
            "if",
            "in",
            "return",
            "switch",
            "where",
            "while",
            "as",
            "catch",
            "is",
            "let",
            "rethrows",
            "throw",
            "throws",
            "try":
            return true
        default:
            return false
        }
    }

    formatter.forEachToken("(") { i, token in
        guard let previousToken = formatter.tokenAtIndex(i - 1) else {
            return
        }
        if spaceAfter(previousToken.string) {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
        } else if previousToken.type == .Whitespace {
            if let token = formatter.tokenAtIndex(i - 2) {
                if (token.type == .EndOfScope && ["]", "}", ")", ">"].contains(token.string)) ||
                    (token.type == .Identifier && !spaceAfter(token.string)) {
                    formatter.removeTokenAtIndex(i - 1)
                }
            }
        }
    }
    formatter.forEachToken(")") { i, token in
        guard let nextToken = formatter.tokenAtIndex(i + 1) else {
            return
        }
        if nextToken.type == .Identifier || nextToken.string == "{" {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
        } else if nextToken.type == .Whitespace && formatter.tokenAtIndex(i + 2)?.string == "[" {
            formatter.removeTokenAtIndex(i + 1)
        }
    }
}

/// Remove whitespace immediately inside parens
public func spaceInsideParens(formatter: Formatter) {
    formatter.forEachToken("(") { i, token in
        if formatter.tokenAtIndex(i + 1)?.type == .Whitespace {
            formatter.removeTokenAtIndex(i + 1)
        }
    }
    formatter.forEachToken(")") { i, token in
        if formatter.tokenAtIndex(i - 1)?.type == .Whitespace &&
            formatter.tokenAtIndex(i - 2)?.type != .Linebreak {
            formatter.removeTokenAtIndex(i - 1)
        }
    }
}

/// Implement the following rules with respect to the spacing around square brackets:
/// * There is no space between an opening bracket and the preceding identifier,
///   unless the identifier is one of the specified keywords
/// * There is no space between an opening bracket and the preceding closing brace
/// * There is no space between an opening bracket and the preceding closing square bracket
/// * There is space between a closing bracket and following identifier
/// * There is space between a closing bracket and following opening brace
public func spaceAroundBrackets(formatter: Formatter) {
    func spaceAfter(identifier: String) -> Bool {
        switch identifier {
        case "case",
            "guard",
            "if",
            "in",
            "return",
            "switch",
            "where",
            "while",
            "as",
            "is":
            return true
        default:
            return false
        }
    }

    formatter.forEachToken("[") { i, token in
        guard let previousToken = formatter.tokenAtIndex(i - 1) else {
            return
        }
        if spaceAfter(previousToken.string) {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
        } else if previousToken.type == .Whitespace {
            if let token = formatter.tokenAtIndex(i - 2) {
                if (token.type == .EndOfScope && ["]", "}", ")"].contains(token.string)) ||
                    (token.type == .Identifier && !spaceAfter(token.string)) {
                    formatter.removeTokenAtIndex(i - 1)
                }
            }
        }
    }
    formatter.forEachToken("]") { i, token in
        guard let nextToken = formatter.tokenAtIndex(i + 1) else {
            return
        }
        if nextToken.type == .Identifier || nextToken.string == "{" {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
        } else if nextToken.type == .Whitespace && formatter.tokenAtIndex(i + 2)?.string == "[" {
            formatter.removeTokenAtIndex(i + 1)
        }
    }
}

/// Remove whitespace immediately inside square brackets
public func spaceInsideBrackets(formatter: Formatter) {
    formatter.forEachToken("[") { i, token in
        if formatter.tokenAtIndex(i + 1)?.type == .Whitespace {
            formatter.removeTokenAtIndex(i + 1)
        }
    }
    formatter.forEachToken("]") { i, token in
        if formatter.tokenAtIndex(i - 1)?.type == .Whitespace &&
            formatter.tokenAtIndex(i - 2)?.type != .Linebreak {
            formatter.removeTokenAtIndex(i - 1)
        }
    }
}

/// Ensure that there is space between an opening brace and the preceding
/// identifier, and between a closing brace and the following identifier.
public func spaceAroundBraces(formatter: Formatter) {
    formatter.forEachToken("{") { i, token in
        if let previousToken = formatter.tokenAtIndex(i - 1) {
            switch previousToken.type {
            case .Whitespace, .Linebreak:
                break
            case .StartOfScope:
                if previousToken.string == "\"" {
                    fallthrough
                }
            default:
                formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
            }
        }
    }
    formatter.forEachToken("}") { i, token in
        if formatter.tokenAtIndex(i + 1)?.type == .Identifier {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
        }
    }
}

/// Ensure that there is space immediately inside braces
public func spaceInsideBraces(formatter: Formatter) {
    formatter.forEachToken("{") { i, token in
        if let nextToken = formatter.tokenAtIndex(i + 1) {
            if nextToken.type == .Whitespace {
                if formatter.tokenAtIndex(i + 2)?.string == "}" {
                    formatter.removeTokenAtIndex(i + 1)
                }
            } else if nextToken.type != .Linebreak && nextToken.string != "}" {
                formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
            }
        }
    }
    formatter.forEachToken("}") { i, token in
        if let previousToken = formatter.tokenAtIndex(i - 1) where
            previousToken.type != .Whitespace && previousToken.type != .Linebreak && previousToken.string != "{" {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
        }
    }
}

/// Ensure there is no space between an opening chevron and the preceding identifier
public func spaceAroundGenerics(formatter: Formatter) {
    formatter.forEachToken("<", ofType: .StartOfScope) { i, token in
        if formatter.tokenAtIndex(i - 1)?.type == .Whitespace &&
            formatter.tokenAtIndex(i - 2)?.type == .Identifier {
            formatter.removeTokenAtIndex(i - 1)
        }
    }
}

/// Remove whitespace immediately inside chevrons
public func spaceInsideGenerics(formatter: Formatter) {
    formatter.forEachToken("<", ofType: .StartOfScope) { i, token in
        if formatter.tokenAtIndex(i + 1)?.type == .Whitespace {
            formatter.removeTokenAtIndex(i + 1)
        }
    }
    formatter.forEachToken(">", ofType: .EndOfScope) { i, token in
        if formatter.tokenAtIndex(i - 1)?.type == .Whitespace &&
            formatter.tokenAtIndex(i - 2)?.type != .Linebreak {
            formatter.removeTokenAtIndex(i - 1)
        }
    }
}

/// Implement the following rules with respect to the spacing around operators:
/// * Infix operators are separated from their operands by a space on either
///   side. Does not affect prefix/postfix operators, as required by syntax.
/// * Punctuation such as commas and colons is consistently followed by a
///   single space, unless it appears at the end of a line, and is not
///   preceded by a space, unless it appears at the beginning of a line.
public func spaceAroundOperators(formatter: Formatter) {
    func isLvalue(token: Token) -> Bool {
        switch token.type {
        case .Identifier, .Number, .EndOfScope:
            return true
        default:
            return false
        }
    }

    func isRvalue(token: Token) -> Bool {
        switch token.type {
        case .Identifier, .Number, .StartOfScope:
            return true
        default:
            return false
        }
    }

    func isUnwrapOperatorSequence(token: Token) -> Bool {
        for c in token.string.characters {
            if c != "?" && c != "!" {
                return false
            }
        }
        return true
    }

    func spaceAfter(identifier: String) -> Bool {
        switch identifier {
        case "case",
            "guard",
            "if",
            "in",
            "let",
            "return",
            "switch",
            "where",
            "while",
            "as",
            "is":
            return true
        default:
            return false
        }
    }

    var scopeStack: [Token] = []
    formatter.forEachToken { i, token in
        switch token.type {
        case .Operator:
            if [":", ",", ";"].contains(token.string) {
                if let nextToken = formatter.tokenAtIndex(i + 1) {
                    switch nextToken.type {
                    case .Whitespace, .Linebreak, .EndOfScope:
                        break
                    case .Identifier:
                        if token.string == ":" {
                            if formatter.tokenAtIndex(i + 2)?.string == ":" {
                                // It's a selector
                                break
                            }
                        }
                        fallthrough
                    default:
                        // Ensure there is a space after the token
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
                    }
                }
                if token.string == ":" && scopeStack.last?.string == "?" {
                    // Treat the next : after a ? as closing the ternary scope
                    scopeStack.popLast()
                    // Ensure there is a space before the :
                    if let previousToken = formatter.tokenAtIndex(i - 1) {
                        if previousToken.type != .Whitespace && previousToken.type != .Linebreak {
                            formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
                        }
                    }
                } else if formatter.tokenAtIndex(i - 1)?.type == .Whitespace &&
                    formatter.tokenAtIndex(i - 2)?.type != .Linebreak {
                    // Remove space before the token
                    formatter.removeTokenAtIndex(i - 1)
                }
            } else if token.string == "?" {
                if let previousToken = formatter.tokenAtIndex(i - 1), nextToken = formatter.tokenAtIndex(i + 1) {
                    if nextToken.type == .Whitespace || nextToken.type == .Linebreak {
                        if previousToken.type == .Whitespace || previousToken.type == .Linebreak {
                            // ? is a ternary operator, treat it as the start of a scope
                            scopeStack.append(token)
                        }
                    } else if previousToken.type == .Identifier && ["as", "try"].contains(previousToken.string) {
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
                    }
                }
            } else if token.string == "!" {
                if let previousToken = formatter.tokenAtIndex(i - 1), nextToken = formatter.tokenAtIndex(i + 1) {
                    if nextToken.type != .Whitespace && nextToken.type != .Linebreak &&
                        previousToken.type == .Identifier && ["as", "try"].contains(previousToken.string) {
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
                    }
                }
            } else if token.string == "." {
                if formatter.tokenAtIndex(i + 1)?.type == .Whitespace {
                    formatter.removeTokenAtIndex(i + 1)
                }
                if let previousToken = formatter.tokenAtIndex(i - 1) {
                    let previousTokenWasWhitespace = (previousToken.type == .Whitespace)
                    let previousNonWhitespaceTokenIndex = i - (previousTokenWasWhitespace ? 2 : 1)
                    if let previousNonWhitespaceToken = formatter.tokenAtIndex(previousNonWhitespaceTokenIndex) {
                        if previousNonWhitespaceToken.type != .Linebreak &&
                            previousNonWhitespaceToken.string != "{" &&
                            (previousNonWhitespaceToken.type != .Operator ||
                            (previousNonWhitespaceToken.string == "?" && scopeStack.last?.string != "?") ||
                            (previousNonWhitespaceToken.string != "?" &&
                            formatter.tokenAtIndex(previousNonWhitespaceTokenIndex - 1)?.type != .Whitespace &&
                            isUnwrapOperatorSequence(previousNonWhitespaceToken))) &&
                            !spaceAfter(previousNonWhitespaceToken.string) {
                            if previousTokenWasWhitespace {
                                formatter.removeTokenAtIndex(i - 1)
                            }
                        } else if !previousTokenWasWhitespace {
                            formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
                        }
                    }
                }
            } else if token.string == "->" {
                if let nextToken = formatter.tokenAtIndex(i + 1) {
                    if nextToken.type != .Whitespace && nextToken.type != .Linebreak {
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
                    }
                }
                if let previousToken = formatter.tokenAtIndex(i - 1) {
                    if previousToken.type != .Whitespace && previousToken.type != .Linebreak {
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
                    }
                }
            } else if token.string != "..." && token.string != "..<" {
                if let previousToken = formatter.tokenAtIndex(i - 1) where isLvalue(previousToken) {
                    if let nextToken = formatter.tokenAtIndex(i + 1) where isRvalue(nextToken) {
                        // Insert space before and after the infix token
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
                    }
                }
            }
        case .StartOfScope:
            scopeStack.append(token)
        case .EndOfScope:
            scopeStack.popLast()
        default: break
        }
    }
}

/// Add space around comments, except at the start or end of a line
public func spaceAroundComments(formatter: Formatter) {
    formatter.forEachToken(ofType: .StartOfScope) { i, token in
        guard let previousToken = formatter.tokenAtIndex(i - 1) where
            (token.string == "/*" || token.string == "//") else { return }
        if !previousToken.isWhitespaceOrLinebreak {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
        }
    }
    formatter.forEachToken("*/") { i, token in
        guard let nextToken = formatter.tokenAtIndex(i + 1) else { return }
        if !nextToken.isWhitespaceOrLinebreak {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
        }
    }
}

/// Add space inside comments, taking care not to mangle headerdoc or
/// carefully preformatted comments, such as star boxes, etc.
public func spaceInsideComments(formatter: Formatter) {
    formatter.forEachToken("/*") { i, token in
        guard let nextToken = formatter.tokenAtIndex(i + 1) else { return }
        if !nextToken.isWhitespaceOrLinebreak {
            let string = nextToken.string
            if string.hasPrefix("*") || string.hasPrefix("!") || string.hasPrefix(":") {
                if !string.hasPrefix("**") && !string.hasPrefix("* ") &&
                    !string.hasPrefix("*\t") && !string.hasPrefix("*/") {
                    let string = String(string.characters.first!) + " " +
                        string.substringFromIndex(string.startIndex.advancedBy(1))
                    formatter.replaceTokenAtIndex(i + 1, with: Token(.CommentBody, string))
                }
            } else {
                formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
            }
        }
    }
    formatter.forEachToken("//") { i, token in
        guard let nextToken = formatter.tokenAtIndex(i + 1) else { return }
        if !nextToken.isWhitespaceOrLinebreak {
            let string = nextToken.string
            if string.hasPrefix("/") || string.hasPrefix("!") || string.hasPrefix(":") {
                if !string.hasPrefix("/ ") && !string.hasPrefix("/\t") {
                    let string = String(string.characters.first!) + " " +
                        string.substringFromIndex(string.startIndex.advancedBy(1))
                    formatter.replaceTokenAtIndex(i + 1, with: Token(.CommentBody, string))
                }
            } else {
                formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
            }
        }
    }
    formatter.forEachToken("*/") { i, token in
        guard let previousToken = formatter.tokenAtIndex(i - 1) else { return }
        if !previousToken.isWhitespaceOrLinebreak && !previousToken.string.hasSuffix("*") {
            formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
        }
    }
}

/// Add or removes the space around range operators
public func ranges(formatter: Formatter) {
    func nextNonWhitespaceToken(fromIndex index: Int) -> Token? {
        var index = index + 1
        while let token = formatter.tokenAtIndex(index) {
            if !token.isWhitespaceOrCommentOrLinebreak {
                return token
            }
            index += 1
        }
        return nil
    }

    formatter.forEachToken(ofType: .Operator) { i, token in
        if token.string == "..." || token.string == "..<" {
            if !formatter.options.spaceAroundRangeOperators {
                if formatter.tokenAtIndex(i + 1)?.type == .Whitespace {
                    formatter.removeTokenAtIndex(i + 1)
                }
                if formatter.tokenAtIndex(i - 1)?.type == .Whitespace {
                    formatter.removeTokenAtIndex(i - 1)
                }
            } else if let nextToken = nextNonWhitespaceToken(fromIndex: i) {
                if nextToken.string != ")" && nextToken.string != "," {
                    if formatter.tokenAtIndex(i + 1)?.isWhitespaceOrLinebreak == false {
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i + 1)
                    }
                    if formatter.tokenAtIndex(i - 1)?.isWhitespaceOrLinebreak == false {
                        formatter.insertToken(Token(.Whitespace, " "), atIndex: i)
                    }
                }
            }
        }
    }
}

/// Collapse all consecutive whitespace characters to a single space, except at
/// the start of a line or inside a comment or string, as these have no semantic
/// meaning and lead to noise in commits.
public func consecutiveSpaces(formatter: Formatter) {
    func currentScopeAtIndex(index: Int) -> Token? {
        var i = index
        var linebreakEncountered = false
        var scopeStack: [Token] = []
        while let token = formatter.tokenAtIndex(i) {
            if token.type == .StartOfScope {
                if let scope = scopeStack.last where scope.closesScopeForToken(token) {
                    scopeStack.popLast()
                } else if token.string == "//" && linebreakEncountered {
                    linebreakEncountered = false
                } else {
                    return token
                }
            } else if token.type == .EndOfScope {
                scopeStack.append(token)
            } else if token.type == .Linebreak {
                linebreakEncountered = true
            }
            i -= 1
        }
        return nil
    }

    formatter.forEachToken(ofType: .Whitespace) { i, token in
        if let previousToken = formatter.tokenAtIndex(i - 1) where previousToken.type != .Linebreak {
            if token.string == "" {
                formatter.removeTokenAtIndex(i)
            } else if token.string != " " {
                let scope = currentScopeAtIndex(i)
                if scope?.string != "/*" && scope?.string != "//" {
                    formatter.replaceTokenAtIndex(i, with: Token(.Whitespace, " "))
                }
            }
        }
    }
}

/// Remove trailing whitespace from the end of lines, as it has no semantic
/// meaning and leads to noise in commits.
public func trailingWhitespace(formatter: Formatter) {
    formatter.forEachToken(ofType: .Linebreak) { i, token in
        if formatter.tokenAtIndex(i - 1)?.type == .Whitespace {
            formatter.removeTokenAtIndex(i - 1)
        }
    }
    if formatter.tokens.last?.type == .Whitespace {
        formatter.removeLastToken()
    }
}

/// Collapse all consecutive blank lines into a single blank line
public func consecutiveBlankLines(formatter: Formatter) {
    var blankLineCount = 0
    var lastTokenType = TokenType.Whitespace
    formatter.forEachToken { i, token in
        if token.type == .Linebreak {
            blankLineCount += 1
            if blankLineCount > 2 {
                formatter.removeTokenAtIndex(i)
                if lastTokenType == .Whitespace {
                    formatter.removeTokenAtIndex(i - 1)
                    lastTokenType = .Linebreak
                }
                blankLineCount -= 1
                return // continue
            }
        } else if token.type != .Whitespace {
            blankLineCount = 0
        }
        lastTokenType = token.type
    }
    if blankLineCount > 1 {
        if lastTokenType == .Whitespace {
            formatter.removeLastToken()
        }
        formatter.removeLastToken()
    }
}

/// Remove blank lines immediately before a closing brace, bracket, paren or chevron
public func blankLinesAtEndOfScope(formatter: Formatter) {
    formatter.forEachToken(ofType: .EndOfScope) { i, token in
        guard ["}", ")", "]", ">"].contains(token.string) else { return }
        // Find previous non-whitespace token
        var index = i - 1
        var indexOfFirstLineBreak: Int?
        var indexOfLastLineBreak: Int?
        loop: while let token = formatter.tokenAtIndex(index) {
            switch token.type {
            case .Linebreak:
                indexOfFirstLineBreak = index
                if indexOfLastLineBreak == nil {
                    indexOfLastLineBreak = index
                }
            case .Whitespace:
                break
            default:
                break loop
            }
            index -= 1
        }
        if let indexOfFirstLineBreak = indexOfFirstLineBreak, indexOfLastLineBreak = indexOfLastLineBreak {
            formatter.removeTokensInRange(indexOfFirstLineBreak ..< indexOfLastLineBreak)
            return
        }
    }
}

/// Always end file with a linebreak, to avoid incompatibility with certain unix tools:
/// http://stackoverflow.com/questions/2287967/why-is-it-recommended-to-have-empty-line-in-the-end-of-file
public func linebreakAtEndOfFile(formatter: Formatter) {
    var token = formatter.tokens.last
    if token?.type == .Whitespace {
        token = formatter.tokenAtIndex(formatter.tokens.count - 2)
    }
    if token?.type != .Linebreak {
        formatter.insertToken(Token(.Linebreak, formatter.options.linebreak), atIndex: formatter.tokens.count)
    }
}

/// Indent code according to standard scope indenting rules.
/// The type (tab or space) and level (2 spaces, 4 spaces, etc.) of the
/// indenting can be configured with the `options` parameter of the formatter.
public func indent(formatter: Formatter) {
    func startOfLine(atIndex index: Int) -> Int {
        var index = index
        while let token = formatter.tokenAtIndex(index - 1) {
            if token.type == .Linebreak {
                break
            }
            index -= 1
        }
        return index
    }

    func nextNonWhitespaceToken(fromIndex index: Int) -> Token? {
        var index = index
        while let token = formatter.tokenAtIndex(index) {
            if token.type != .Whitespace && token.type != .Linebreak {
                return token
            }
            index += 1
        }
        return nil
    }

    func setIndent(indent: String, atIndex index: Int) -> Bool {
        if formatter.tokenAtIndex(index)?.type == .Whitespace {
            formatter.replaceTokenAtIndex(index, with: Token(.Whitespace, indent))
            return false
        } else {
            formatter.insertToken(Token(.Whitespace, indent), atIndex: index)
            return true
        }
    }

    var scopeIndexStack: [Int] = []
    var scopeStartLineIndexes: [Int] = []
    var lastNonWhitespaceOrLinebreakIndex = -1
    var lastNonWhitespaceIndex = -1
    var indentStack = [""]
    var indentCounts = [1]
    var lineIndex = 0
    var linewrapped = false

    func currentScope() -> Token? {
        if let scopeIndex = scopeIndexStack.last {
            return formatter.tokens[scopeIndex]
        }
        return nil
    }

    func tokenIsEndOfStatement(i: Int) -> Bool {
        if let token = formatter.tokenAtIndex(i) {
            switch token.type {
            case .Identifier, .EndOfScope:
                // TODO: handle in
                // TODO: handle context-specific keywords
                // associativity, convenience, dynamic, didSet, final, get, infix, indirect,
                // lazy, left, mutating, none, nonmutating, optional, override, postfix, precedence,
                // prefix, Protocol, required, right, set, Type, unowned, weak, willSet
                switch token.string {
                case "associatedtype",
                    "class",
                    "deinit",
                    "enum",
                    "extension",
                    "fileprivate",
                    "func",
                    "import",
                    "init",
                    "inout",
                    "internal",
                    "let",
                    "open",
                    "operator",
                    "private",
                    "protocol",
                    "public",
                    "static",
                    "struct",
                    "subscript",
                    "typealias",
                    "var",
                    "case",
                    "default",
                    "defer",
                    "else",
                    "for",
                    "guard",
                    "if",
                    "switch",
                    "where",
                    "while",
                    "as",
                    "catch",
                    "is",
                    "super",
                    "throw",
                    "try":
                    return false
                default:
                    return true
                }
            case .Operator:
                if token.string == "." {
                    return false
                }
                if token.string == "," {
                    // For arrays or argument lists, we already indent
                    return ["[", "("].contains(currentScope()?.string ?? "")
                }
                if let previousToken = formatter.tokenAtIndex(i - 1) where
                    previousToken.isWhitespaceOrCommentOrLinebreak ||
                    previousToken.string == "as" || previousToken.string == "try" {
                    return false
                }
            default:
                return true
            }
        }
        return true
    }

    func tokenIsStartOfStatement(i: Int) -> Bool {
        if let token = formatter.tokenAtIndex(i) {
            switch token.type {
            case .Identifier:
                // TODO: handle "in"
                switch token.string {
                case "as",
                    "dynamicType",
                    "false",
                    "is",
                    "nil",
                    "rethrows",
                    "throws",
                    "true":
                    return false
                case "else":
                    if let token = formatter.tokenAtIndex(lastNonWhitespaceOrLinebreakIndex) {
                        return token.string == "}"
                    }
                    return false
                default:
                    return true
                }
            case .Operator:
                if token.string == "." {
                    return false
                }
                if token.string == "," {
                    // For arrays or argument lists, we already indent
                    return ["[", "("].contains(currentScope()?.string ?? "")
                }
                if let nextToken = formatter.tokenAtIndex(i + 1) where
                    nextToken.isWhitespaceOrCommentOrLinebreak {
                    // Is an infix operator
                    return false
                }
            default:
                return true
            }
        }
        return true
    }

    setIndent("", atIndex: 0)
    formatter.forEachToken { i, token in
        var i = i
        if token.type == .StartOfScope {
            // Handle start of scope
            scopeIndexStack.append(i)
            var indent = indentStack.last ?? ""
            if lineIndex > scopeStartLineIndexes.last ?? -1 {
                switch token.string {
                case "/*":
                    // Comments only indent one space
                    indent += " "
                default:
                    indent += formatter.options.indent
                }
                indentStack.append(indent)
                indentCounts.append(1)
            } else {
                indentCounts[indentCounts.count - 1] += 1
            }
            scopeStartLineIndexes.append(lineIndex)
        } else if token.type != .Whitespace {
            if let scopeIndex = scopeIndexStack.last, scope = formatter.tokenAtIndex(scopeIndex) {
                // Handle end of scope
                if token.closesScopeForToken(scope) {
                    scopeStartLineIndexes.popLast()
                    scopeIndexStack.popLast()
                    let indentCount = indentCounts.last! - 1
                    if indentCount == 0 {
                        indentStack.popLast()
                        indentCounts.popLast()
                    } else {
                        indentCounts[indentCounts.count - 1] = indentCount
                    }
                    if lineIndex > scopeStartLineIndexes.last ?? -1 {
                        // If indentCount > 0, drop back to previous indent level
                        if indentCount > 0 {
                            indentStack.popLast()
                            indentStack.append(indentStack.last ?? "")
                        }
                        // Check if line on which scope ends should be unindented
                        let start = startOfLine(atIndex: i)
                        if let nextToken = nextNonWhitespaceToken(fromIndex: start) where
                            nextToken.type == .EndOfScope && nextToken.string != "*/" {
                            // Only reduce indent if line begins with a closing scope token
                            let indent = indentStack.last ?? ""
                            if setIndent(indent, atIndex: start) {
                                i += 1
                            }
                        }
                    }
                } else if token.type == .Identifier {
                    // Handle #elseif/#else
                    if token.string == "#else" || token.string == "#elseif" {
                        let indent = indentStack[indentStack.count - 2]
                        if setIndent(indent, atIndex: startOfLine(atIndex: i)) {
                            i += 1
                        }
                    }
                }
            }
            // Indent each new line
            if token.type == .Linebreak {
                var indent = indentStack.last ?? ""
                linewrapped = !tokenIsEndOfStatement(lastNonWhitespaceOrLinebreakIndex)
                if linewrapped && lineIndex == scopeStartLineIndexes.last {
                    indent = indentStack.count > 1 ? indentStack[indentStack.count - 2] : ""
                    scopeStartLineIndexes[scopeStartLineIndexes.count - 1] += 1
                }
                lineIndex += 1
                setIndent("", atIndex: i + 1)
                // Only indent if line isn't blank
                if let nextToken = formatter.tokenAtIndex(i + 2) where nextToken.type != .Linebreak {
                    indent += (linewrapped ? formatter.options.indent : "")
                    setIndent(indent, atIndex: i + 1)
                }
            }
        }
        // Track token for line wraps
        if !token.isWhitespaceOrComment {
            if !linewrapped && formatter.tokenAtIndex(lastNonWhitespaceIndex)?.type == .Linebreak &&
                !tokenIsStartOfStatement(i) {
                linewrapped = true
                var indent = indentStack.last ?? ""
                if lineIndex - 1 == scopeStartLineIndexes.last {
                    indent = indentStack.count > 1 ? indentStack[indentStack.count - 2] : ""
                    scopeStartLineIndexes[scopeStartLineIndexes.count - 1] += 1
                }
                indent += (linewrapped ? formatter.options.indent : "")
                if setIndent(indent, atIndex: startOfLine(atIndex: i)) {
                    i += 1
                }
            }
            lastNonWhitespaceIndex = i
            if token.type != .Linebreak {
                lastNonWhitespaceOrLinebreakIndex = i
            }
        }
    }
}

/// Implement K&R-style braces, where opening brace appears on the same line as
/// the related function or keyword, and the closing brace is on its own line,
/// except for inline closures where opening and closing brace are on same line.
public func knrBraces(formatter: Formatter) {
    formatter.forEachToken("{") { i, token in
        var index = i - 1
        var linebreakIndex: Int?
        while let token = formatter.tokenAtIndex(index) {
            switch token.type {
            case .Linebreak:
                linebreakIndex = index
            case .Whitespace, .CommentBody:
                break
            case .StartOfScope:
                if token.string != "/*" && token.string != "//" {
                    fallthrough
                }
            case .EndOfScope:
                if token.string != "*/" {
                    fallthrough
                }
            default:
                if let linebreakIndex = linebreakIndex {
                    formatter.removeTokensInRange(linebreakIndex ... i)
                    formatter.insertToken(Token(.Whitespace, " "), atIndex: index + 1)
                    formatter.insertToken(Token(.StartOfScope, "{"), atIndex: index + 2)
                }
                return
            }
            index -= 1
        }
    }
}

/// Ensure that an `else` statement following `if { ... }` appears on the same line
/// as the closing brace. This has no effect on the `else` part of a `guard` statement
public func elseOnSameLine(formatter: Formatter) {
    formatter.forEachToken("else") { i, token in
        var index = i - 1
        var containsLinebreak = false
        while let token = formatter.tokenAtIndex(index) {
            switch token.type {
            case .Linebreak:
                containsLinebreak = true
            case .Whitespace:
                break
            case .EndOfScope:
                if token.string == "}" && containsLinebreak {
                    formatter.replaceTokensInRange(index + 1 ..< i, with: Token(.Whitespace, " "))
                }
                return
            default:
                return
            }
            index -= 1
        }
    }
}

/// Ensure that the last item in a multi-line array literal is followed by a comma.
/// This is useful for preventing noise in commits when items are added to end of array.
public func trailingCommas(formatter: Formatter) {
    // TODO: we don't currently check if [] is a subscript rather than a literal.
    // This should't matter in practice, as nobody splits subscripts onto multiple
    // lines, but ideally we'd check for this just in case
    formatter.forEachToken("]") { i, token in
        var index = i - 1
        var newLine = false
        while let token = formatter.tokenAtIndex(index) {
            if token.type == .Linebreak {
                newLine = true
            } else if token.type != .Whitespace {
                if newLine && token.type != .Operator {
                    formatter.insertToken(Token(.Operator, ","), atIndex: index + 1)
                }
                break
            }
            index -= 1
        }
    }
}

/// Ensure that TODO, MARK and FIXME comments are followed by a : as required
public func todos(formatter: Formatter) {
    formatter.forEachToken(ofType: .CommentBody) { i, token in
        let string = token.string
        for tag in ["TODO", "MARK", "FIXME"] {
            if string.hasPrefix(tag) {
                var suffix = string.substringFromIndex(tag.endIndex)
                while suffix.characters.first == " " || suffix.characters.first == ":" {
                    suffix = suffix.substringFromIndex(suffix.startIndex.advancedBy(1))
                }
                formatter.replaceTokenAtIndex(i, with: Token(.CommentBody, tag + ": " + suffix))
            }
        }
    }
}

/// Remove semicolons, except where doing so would change the meaning of the code
public func semicolons(formatter: Formatter) {
    func firstNonWhitespaceOrComment(fromIndex index: Int) -> Token? {
        var i = index
        var scopeStack: [Token] = []
        while let token = formatter.tokenAtIndex(i) {
            if let scope = scopeStack.last {
                if token.closesScopeForToken(scope) {
                    scopeStack.popLast()
                    if token.type == .Linebreak {
                        return token
                    }
                }
            } else {
                switch token.type {
                case .Whitespace:
                    break
                case .StartOfScope:
                    if token.string == "/*" || token.string == "//" {
                        scopeStack.append(token)
                    } else {
                        return token
                    }
                default:
                    return token
                }
            }
            i += 1
        }
        return nil
    }

    func firstNonWhitespaceOrCommentOrLinebreak(fromIndex index: Int) -> Token? {
        var i = index
        var scopeStack: [Token] = []
        while let token = formatter.tokenAtIndex(i) {
            if let scope = scopeStack.last {
                if token.closesScopeForToken(scope) {
                    scopeStack.popLast()
                }
            } else {
                switch token.type {
                case .Whitespace, .Linebreak:
                    break
                case .StartOfScope:
                    if token.string == "/*" || token.string == "//" {
                        scopeStack.append(token)
                    } else {
                        return token
                    }
                default:
                    return token
                }
            }
            i += 1
        }
        return nil
    }

    func lastNonWhitespaceOrCommentOrLinebreak(fromIndex index: Int) -> Token? {
        var i = index
        var scopeStack: [Token] = []
        while let token = formatter.tokenAtIndex(i) {
            if let scope = scopeStack.last {
                if token.type == .StartOfScope && scope.closesScopeForToken(token) {
                    scopeStack.popLast()
                } else {
                    return token
                }
            } else {
                switch token.type {
                case .Whitespace, .Linebreak:
                    break
                case .EndOfScope:
                    if token.string == "*/" {
                        scopeStack.append(token)
                    } else {
                        return token
                    }
                default:
                    return token
                }
            }
            i -= 1
        }
        return nil
    }

    func currentScopeAtIndex(index: Int) -> Token? {
        var i = index
        var linebreakEncountered = false
        var scopeStack: [Token] = []
        while let token = formatter.tokenAtIndex(i) {
            if token.type == .StartOfScope {
                if let scope = scopeStack.last where scope.closesScopeForToken(token) {
                    scopeStack.popLast()
                } else if token.string == "//" && linebreakEncountered {
                    linebreakEncountered = false
                } else {
                    return token
                }
            } else if token.type == .EndOfScope {
                scopeStack.append(token)
            } else if token.type == .Linebreak {
                linebreakEncountered = true
            }
            i -= 1
        }
        return nil
    }

    func indentAtIndex(index: Int) -> Token? {
        var i = index
        while let token = formatter.tokenAtIndex(i) {
            if token.type == .Linebreak {
                break
            }
            i -= 1
        }
        if let token = formatter.tokenAtIndex(i + 1) {
            if token.type == .Whitespace {
                return token
            }
        }
        return nil
    }

    formatter.forEachToken(";") { i, token in
        if let nextToken = firstNonWhitespaceOrCommentOrLinebreak(fromIndex: i + 1) {
            let lastToken = lastNonWhitespaceOrCommentOrLinebreak(fromIndex: i - 1)
            if lastToken == nil || nextToken.string == "}" {
                // Safe to remove
                formatter.removeTokenAtIndex(i)
            } else if lastToken?.string == "return" || currentScopeAtIndex(i)?.string == "(" {
                // Not safe to remove or replace
            } else if firstNonWhitespaceOrComment(fromIndex: i + 1)?.type == .Linebreak {
                // Safe to remove
                formatter.removeTokenAtIndex(i)
            } else if !formatter.options.allowInlineSemicolons {
                // Replace with a linebreak
                if formatter.tokenAtIndex(i + 1)?.type == .Whitespace {
                    formatter.removeTokenAtIndex(i + 1)
                }
                if let indent = indentAtIndex(i) {
                    formatter.insertToken(indent, atIndex: i + 1)
                }
                formatter.replaceTokenAtIndex(i, with: Token(.Linebreak, formatter.options.linebreak))
            }
        } else {
            // Safe to remove
            formatter.removeTokenAtIndex(i)
        }
    }
}

/// Standardise linebreak characters as whatever is specified in the options (\n by default)
public func linebreaks(formatter: Formatter) {
    formatter.forEachToken(ofType: .Linebreak) { i, token in
        formatter.replaceTokenAtIndex(i, with: Token(.Linebreak, formatter.options.linebreak))
    }
}

public let defaultRules: [FormatRule] = [
    linebreaks,
    semicolons,
    knrBraces,
    elseOnSameLine,
    indent,
    spaceAroundParens,
    spaceInsideParens,
    spaceAroundBrackets,
    spaceInsideBrackets,
    spaceAroundBraces,
    spaceInsideBraces,
    spaceAroundGenerics,
    spaceInsideGenerics,
    spaceAroundOperators,
    spaceAroundComments,
    spaceInsideComments,
    consecutiveSpaces,
    trailingWhitespace,
    consecutiveBlankLines,
    blankLinesAtEndOfScope,
    linebreakAtEndOfFile,
    trailingCommas,
    todos,
    ranges,
]
