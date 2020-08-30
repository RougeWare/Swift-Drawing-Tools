import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwatchTests.allTests),
        testCase(FocusTests.allTests),
    ]
}
#endif
