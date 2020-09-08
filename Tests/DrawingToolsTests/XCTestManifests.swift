import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwatchTests.allTests),
        testCase(FocusTests.allTests),
        testCase(InCurrentGraphicsContextTests.allTests),
        testCase(InGraphicsContextTests.allTests),
        testCase(GraphicsContext_Tests.allTests),
    ]
}
#endif
