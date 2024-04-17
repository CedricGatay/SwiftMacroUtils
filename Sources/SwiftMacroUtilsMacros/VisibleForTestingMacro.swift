import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum VisibleForTestingMacro {}

extension VisibleForTestingMacro: PeerMacro {
    public static func expansion(of _: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        // generate var test accessor
        if let varDecl = declaration.as(VariableDeclSyntax.self),
           let binding = varDecl.bindings.first,
           let typeAnnotation = binding.typeAnnotation,
           let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed {
            return [
                """
                public var __test_\(raw: identifier)\(raw: typeAnnotation.description) {
                get {
                    self.\(raw: identifier)
                }
                set {
                    self.\(raw: identifier) = newValue
                }
                }
                """,
            ]
        }
        // generate func test accessor
        if let funcDecl = declaration.as(FunctionDeclSyntax.self) {
            let funcName = funcDecl.name
            let signature = funcDecl.signature
            let returnType = if let returnClause = signature.returnClause {
                "-> \(returnClause.type.description)"
            } else {
                ""
            }
            return [
                """
                public func _test_\(raw: funcName)(\(raw: extractParameters(signature.parameterClause.parameters))) \(raw: returnType) {
                \(raw: funcName)(\(raw: buildArguments(signature.parameterClause.parameters)))
                }
                """,
            ]
        }
        return []
    }

    private static func extractParameters(_ parametersList: FunctionParameterListSyntax) -> String {
        parametersList.enumerated().map { offset, param in
            "\(param.firstName.trimmed) arg\(offset): \(param.type)"
        }.joined(separator: ",")
    }

    private static func buildArguments(_ parametersList: FunctionParameterListSyntax) -> String {
        parametersList.enumerated().map { offset, param in
            if param.firstName.trimmed.text == "_" {
                "arg\(offset)"
            } else {
                "\(param.firstName.trimmed): arg\(offset)"
            }
        }.joined(separator: ",")
    }
}
