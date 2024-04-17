import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftMacroUtilsMacros)
import SwiftMacroUtilsMacros

let testMacros: [String: Macro.Type] = [
    "VisibleForTesting": VisibleForTestingMacro.self,
]
#endif

final class SwiftMacroUtilsTests: XCTestCase {
    func testMacroOnVariable() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @VisibleForTesting
            var myVar: Int
            """,
            expandedSource: """
            var myVar: Int
            
            public var __test_myVar: Int {
                get {
                    self.myVar
                }
                set {
                    self.myVar = newValue
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOnFunctionWithArgs() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @VisibleForTesting
            private func myOtherAccessibleFunc(_: String, arg _: Int) -> Int {
                0
            }
            """,
            expandedSource: """
            private func myOtherAccessibleFunc(_: String, arg _: Int) -> Int {
                0
            }
            
            public func _test_myOtherAccessibleFunc(_ arg0: String, arg arg1: Int) -> Int  {
                myOtherAccessibleFunc(arg0, arg: arg1)
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    func testMacroOnFunctionWithoutArgs() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @VisibleForTesting
            private func myAccessibleFunc() {
                print(myAccessibleVar)
            }
            """,
            expandedSource: """
            private func myAccessibleFunc() {
                print(myAccessibleVar)
            }
            
            public func _test_myAccessibleFunc()  {
                myAccessibleFunc()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
