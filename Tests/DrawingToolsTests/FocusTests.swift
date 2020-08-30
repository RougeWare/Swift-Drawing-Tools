//
//  FocusTests.swift
//  
//
//  Created by Ben Leggiero on 2020-08-29.
//

import XCTest
import DrawingTools



final class FocusTests: XCTestCase {
    func testWithFocus() {
        #if canImport(UIKit)
        
        print("Test skipped on-purpose: UIKit has no concept of image focus")
        
        #elseif canImport(AppKit)
        
        XCTAssertNil(currentContextDataSize)
        
        let image = NSImage(data: testImagePngData)!
        
        XCTAssertNil(currentContextDataSize)

        image.withFocus { _ in
            XCTAssertNotEqual(0, currentContextDataSize)
        }
        
        XCTAssertNil(currentContextDataSize)

        #else
        #error("Unsupported platform")
        #endif
    }
    
    
    func testWithFocusFlipped() {
        #if canImport(UIKit)
        
        print("Test skipped on-purpose: UIKit has no concept of image focus")
        
        #elseif canImport(AppKit)
        
        XCTAssertNil(currentContextDataSize)
        
        let image = NSImage(data: testImagePngData)!
        
        XCTAssertNil(currentContextDataSize)
        
        image.withFocus(flipped: true) { _ in
            XCTAssertNotEqual(0, currentContextDataSize)
        }
        
        XCTAssertNil(currentContextDataSize)
        
        image.withFocus(flipped: false) { _ in
            XCTAssertNotEqual(0, currentContextDataSize)
        }
        
        XCTAssertNil(currentContextDataSize)
        
        #else
        #error("Unsupported platform")
        #endif
    }
    
    
    static let allTests = [
        ("testWithFocus", testWithFocus),
        ("testWithFocusFlipped", testWithFocusFlipped),
    ]
}
