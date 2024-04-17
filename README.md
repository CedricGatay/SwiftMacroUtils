# SwiftMacroUtils

SPM package to expose some useful macros to be used on Swift projects

## Available macros

### @VisibleForTesting

This macro allows exposing variable with a public modifier so that test can access them properly without broadly exposing them.

Usage is the following:

 ```swift
 @VisibleForTesting
   private func myAccessibleFunc() {
   print(myAccessibleVar)
 }
 ```

This will generate a function named `test_myAccessibleFunc()` with a `public` visibility.

The same applies on variables

 ```swift
 @VisibleForTesting
 private var myAccessibleVar: String
 ```
