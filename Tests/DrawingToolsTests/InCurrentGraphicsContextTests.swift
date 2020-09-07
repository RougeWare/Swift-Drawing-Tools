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

#if canImport(UIKit)
import UIKit
#endif



final class InCurrentGraphicsContextTests: XCTestCase {
    
    func testInCurrentGraphicsContext() throws {
        NativeImage(size: .one).inCurrentGraphicsContext { image, context in
            
            let ppiMultiplier: CGFloat
            
            #if canImport(UIKit)
            ppiMultiplier = UIScreen.main.scale
            
            // `UIImage`s expose their scale in their size, whereas AppKit doesn'tß
            
            XCTAssertEqual(ppiMultiplier, image.size.width)
            XCTAssertEqual(ppiMultiplier, image.size.height)
            
            #elseif canImport(AppKit)
            ppiMultiplier = NSScreen.deepest!.backingScaleFactor
            
            XCTAssertEqual(1, image.size.width)
            XCTAssertEqual(1, image.size.height)
            #endif
            
            
            #if canImport(UIKit)
            
            // UIKit doesn't think of context in this way
            
            #elseif canImport(AppKit)
            guard let context = context else {
                XCTFail("No context in current context")
                return
            }
            
            XCTAssertEqual(ppiMultiplier, .init(context.width))
            XCTAssertEqual(ppiMultiplier, .init(context.height))
            #endif
        }
    }
    
    
    static let allTests = [
        ("testInCurrentGraphicsContext", testInCurrentGraphicsContext),
    ]
}
