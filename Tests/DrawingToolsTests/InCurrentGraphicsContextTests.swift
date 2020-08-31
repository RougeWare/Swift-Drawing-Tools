//
//  InCurrentGraphicsContextTests.swift
//  Swift Drawing Tools
//
//  Created by Ben Leggiero on 2020-08-29.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import XCTest

import CrossKitTypes
import DrawingTools



final class InCurrentGraphicsContextTests: XCTestCase {
    
    func testInCurrentGraphicsContext() {
        NativeImage(size: .one).inCurrentGraphicsContext { image, context in
            
            guard let context = context else {
                XCTFail("No context in current context")
                return
            }
            
            let ppiMultiplier = NSScreen.deepest!.backingScaleFactor
            XCTAssertEqual(ppiMultiplier, .init(context.width))
            XCTAssertEqual(ppiMultiplier, .init(context.height))
            
            XCTAssertEqual(1, image.size.width)
            XCTAssertEqual(1, image.size.height)
        }
    }
    
    
    static let allTests = [
        ("testInCurrentGraphicsContext", testInCurrentGraphicsContext),
    ]
}
