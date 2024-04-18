import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum VisibleForTestingMacro {}

extension VisibleForTestingMacro: PeerMacro {
    public static func expansion(of _: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        // generate var test accessor
        if let varDecl = declaration.as(VariableDeclSyntax.self),
           let binding = varDecl.bindings.first,
           let typeAnnotation = binding.typeAnnotation,
           let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed {
            if varDecl.bindingSpecifier.text == "var" {
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
            } else {
                return [
                    """
                    public var __test_\(raw: identifier)\(raw: typeAnnotation.description) {
                    get {
                        self.\(raw: identifier)
                    }
                    }
                    """,
                ]
            }
            
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
        if let initDecl = declaration.as(InitializerDeclSyntax.self) {
            let signature = initDecl.signature
            
            let modifiers = initDecl.modifiers
            if !modifiers.map(\.name.text).contains("required") {
                context.addDiagnostics(from: VisibleForTestingError.canOnlyBeAppliedOnRequiredInit, node: initDecl)
                return []
            }
            return [
                """
                public static func _test_init(\(raw: extractParameters(signature.parameterClause.parameters))) -> Self {
                    Self.init(\(raw: buildArguments(signature.parameterClause.parameters)))
                }
                """
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

enum VisibleForTestingError: Error, DiagnosticMessage {
    var message: String {
        switch self {
        case .canOnlyBeAppliedOnRequiredInit:
            "@VisibleForTesting can only be applied to a required init"
        }
    }
    
    var diagnosticID: MessageID {
        .init(domain: "VisibleForTestingMacroExpansion", id: String(describing: self))
    }
    
    var severity: DiagnosticSeverity {
        .error
    }
    
    case canOnlyBeAppliedOnRequiredInit
}
