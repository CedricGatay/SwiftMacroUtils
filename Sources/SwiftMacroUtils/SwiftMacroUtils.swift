@attached(peer, names: arbitrary)
public macro VisibleForTesting() = #externalMacro(
    module: "SwiftMacroUtilsMacros",
    type: "VisibleForTestingMacro"
)


