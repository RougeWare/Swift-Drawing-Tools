//
//  InGraphicsContextTests.swift
//  Swift Drawing Tools
//
//  Created by Ben Leggiero on 2020-09-02.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import XCTest

import CrossKitTypes
import DrawingTools



final class InGraphicsContextTests: XCTestCase {
    
    func testInGraphicsContext() throws {
        NativeImage(size: .one, scale: .oneToOne).inGraphicsContext(.goodForSwatch) { image, context in
            
            XCTAssertEqual(1, image.size.width)
            XCTAssertEqual(1, image.size.height)
            
            
            #if canImport(UIKit)
            
            // UIKit doesn't think of context in this way
            
            #elseif canImport(AppKit)
            guard let context = context else {
                XCTFail("No context in current context")
                return
            }
            
            XCTAssertEqual(1, context.width)
            XCTAssertEqual(1, context.height)
            #endif
        }
    }
    
    
    static let allTests = [
        ("testInGraphicsContext", testInGraphicsContext),
    ]
}
