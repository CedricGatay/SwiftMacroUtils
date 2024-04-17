import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SwiftMacroUtilsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        VisibleForTestingMacro.self,
    ]
}
