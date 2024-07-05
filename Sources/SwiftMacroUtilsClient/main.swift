import SwiftMacroUtils

class Test {
    @VisibleForTesting
    private var myAccessibleVar: String

    init() {
        myAccessibleVar = ""
    }
    
    @VisibleForTesting
    required init(_ value: String) {
        myAccessibleVar = value
    }
    
   

    @VisibleForTesting
    private func myAccessibleFunc() {
        print(myAccessibleVar)
    }

    @VisibleForTesting
    private func myOtherAccessibleFunc(_: String, arg _: Int) -> Int {
        0
    }

    @VisibleForTesting
    private func myThirdAccessibleFunc(_: String, arg _: Int) -> Int {
        0
    }
}

struct Test2{
    @VisibleForTesting
    let myInnerVar: String
    @VisibleForTesting
    init(_ value: String) {
        myInnerVar = value
    }
}

struct Test3 {
    @MainActor @VisibleForTesting var myVar: String = ""
    @MainActor @VisibleForTesting var mySecondVar: String = ""
    
    @MainActor
    @VisibleForTesting
    init(){}
    
    @MainActor
    @VisibleForTesting
    func myMethodOnMainActor() {
        
    }
}

import SwiftMacroUtils

struct Dog {
    @VisibleForTesting
    private var name: String?
}



let test = Test()
test._test_myAccessibleFunc()
print(test._test_myOtherAccessibleFunc("a", arg: 12))
print(test._test_myThirdAccessibleFunc("a", arg: 12))
test.__test_myAccessibleVar = "FourtyTwo"
print("Read through annotation \(test.__test_myAccessibleVar)")
test._test_myAccessibleFunc()
