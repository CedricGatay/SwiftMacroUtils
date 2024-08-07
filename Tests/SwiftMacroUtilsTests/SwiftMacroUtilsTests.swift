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
    
    func testMacroOnVariable_withAttributes() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @FakeAttribute
            @VisibleForTesting
            @MainActor
            var myVar: Int
            """,
            expandedSource: """
            @FakeAttribute
            @MainActor
            var myVar: Int
            
            @FakeAttribute
            @MainActor
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
    
    
    func testMacroOnReadOnlyVariable() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @VisibleForTesting
            let myVar: Int
            """,
            expandedSource: """
            let myVar: Int
            
            public var __test_myVar: Int {
                get {
                    self.myVar
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroOnReadOnlyVariable_withAttributes() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @MainActor
            @VisibleForTesting
            let myVar: Int
            """,
            expandedSource: """
            @MainActor
            let myVar: Int
            
            @MainActor
            public var __test_myVar: Int {
                get {
                    self.myVar
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
    
    func testMacroOnFunctionWithArgs_WithAttributes() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @MainActor
            @VisibleForTesting
            private func myOtherAccessibleFunc(_: String, arg _: Int) -> Int {
                0
            }
            """,
            expandedSource: """
            @MainActor
            private func myOtherAccessibleFunc(_: String, arg _: Int) -> Int {
                0
            }
            
            @MainActor
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
    
    func testMacroOnFunctionWithoutArgs_WithAttributes() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @MainActor
            @VisibleForTesting
            private func myAccessibleFunc() {
                print(myAccessibleVar)
            }
            """,
            expandedSource: """
            @MainActor
            private func myAccessibleFunc() {
                print(myAccessibleVar)
            }
            
            @MainActor
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
   
    
    func testMacroOnInit() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @VisibleForTesting
            required init(_ value: String) {
                myAccessibleVar = value
            }
            """,
            expandedSource: """
            required init(_ value: String) {
                myAccessibleVar = value
            }
            
            public static func _test_init(_ arg0: String) -> Self {
                // need to delegate to a `required init` if used in a Class
                // make the annotated `init` `required` to fix this build issue
                Self.init(arg0)
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    
    func testMacroOnInit_WithAttributes() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @VisibleForTesting
            @MainActor
            required init(_ value: String) {
                myAccessibleVar = value
            }
            """,
            expandedSource: """
            @MainActor
            required init(_ value: String) {
                myAccessibleVar = value
            }
            
            @MainActor
            public static func _test_init(_ arg0: String) -> Self {
                // need to delegate to a `required init` if used in a Class
                // make the annotated `init` `required` to fix this build issue
                Self.init(arg0)
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroOnInitWithDefaultArgument() throws {
        #if canImport(SwiftMacroUtilsMacros)
        assertMacroExpansion(
            """
            @VisibleForTesting
            required init(_ value: String = "default") {
                myAccessibleVar = value
            }
            """,
            expandedSource: """
            required init(_ value: String = "default") {
                myAccessibleVar = value
            }
            
            public static func _test_init(_ arg0: String = "default") -> Self {
                // need to delegate to a `required init` if used in a Class
                // make the annotated `init` `required` to fix this build issue
                Self.init(arg0)
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
}
