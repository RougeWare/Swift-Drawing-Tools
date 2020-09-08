//
//  GraphicsContext Tests.swift
//  
//
//  Created by Ben Leggiero on 2020-09-07.
//

import XCTest

import DrawingTools
import RectangleTools



class GraphicsContext_Tests: XCTestCase {
    
    func test_Scale_forUiGraphics() throws {
        #if canImport(UIKit)
        XCTAssertEqual(GraphicsContext.Scale.currentDisplay.forUiGraphics, 0)
        
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 1).forUiGraphics, 1)
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 1.5).forUiGraphics, 1.5)
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 2).forUiGraphics, 2)
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 2.5).forUiGraphics, 2.5)
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 3).forUiGraphics, 3)
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 3.5).forUiGraphics, 3.5)
        
        XCTAssertEqual(GraphicsContext.Scale.oneToOne.forUiGraphics, 1)
        
        #elseif canImport(AppKit)
        throw XCTSkip("AppKit has a different version of this test")
        #endif
    }
    
    
    func test_Scale_forAppKit() throws {
        #if canImport(UIKit)
        throw XCTSkip("UIKit has a different version of this test")
        #elseif canImport(AppKit)
        
        let currentDisplayScaleForUiGraphics = GraphicsContext.Scale.currentDisplay.forAppKit
        XCTAssertTrue([.one, CGSize(width: 2, height: 2)].contains(currentDisplayScaleForUiGraphics),
                      "Current display scale should be 1x or 2x")
        
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 1).forAppKit, .one)
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 1.5).forAppKit, CGSize(width: 1.5, height: 1.5))
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 2).forAppKit, CGSize(width: 2, height: 2))
        XCTAssertEqual(GraphicsContext.Scale.multiple(multiplier: 2.5).forAppKit, CGSize(width: 2.5, height: 2.5))
        
        XCTAssertEqual(GraphicsContext.Scale.oneToOne.forAppKit, .one)
        
        #endif
    }
    
    
    func test_goodForSwatch() {
        switch GraphicsContext.goodForSwatch {
        case .new(size: .one, opaque: true, scale: .oneToOne):
            // Expected! Nothing to do
            break
            
        default:
            XCTFail("Plain `goodForSwatch` context should be 1×1, opaque and 1:1")
        }
        
        
        switch GraphicsContext.goodForSwatch(size: UIntSize(width: 2, height: 2)) {
        case .new(size: UIntSize(width: 2, height: 2), opaque: true, scale: .oneToOne):
            // Expected! Nothing to do
            break
            
        default:
            XCTFail("2×2 `goodForSwatch` context should be 2×2, opaque and 1:1")
        }
        
        
        switch GraphicsContext.goodForSwatch(size: CGSize(width: 2.0, height: 2.0)) {
        case .new(size: UIntSize(width: 2, height: 2), opaque: true, scale: .oneToOne):
            // Expected! Nothing to do
            break
            
        default:
            XCTFail("2.0×2.0 `goodForSwatch` context should be 2×2, opaque and 1:1")
        }
        
    }
    
    
    static let allTests = [
        ("test_Scale_forUiGraphics", test_Scale_forUiGraphics),
        ("test_Scale_forAppKit", test_Scale_forAppKit),
    ]
}
