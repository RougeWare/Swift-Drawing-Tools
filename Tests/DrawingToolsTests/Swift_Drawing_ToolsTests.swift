import XCTest

import CrossKitTypes
import DrawingTools
import RectangleTools
import SwiftImage



final class Swift_Drawing_ToolsTests: XCTestCase {
    let testColor = NativeColor(     red: 0x42/0xFF, green: 0x69/0xFF, blue: 0xAD/0xFF, alpha: 1)
    let testColorForSwiftImage = RGB<UInt8>(red: 0x42,      green: 0x69,      blue: 0xAD)
    let size = CGSize(width: 2, height: 2)
    
    func testDrawSwatch() throws {
        let nativeImage = try NativeImage.swatch(color: testColor, size: size)
        
        guard let pngData = nativeImage.pngData() else {
            XCTFail("Not PNG data")
            return
        }
        
        guard let image = Image<RGB<UInt8>>(data: pngData) else {
            XCTFail("PNG data not PNG data?")
            return
        }
        
        image.forEach { pixel in
            XCTAssertEqual(pixel, testColorForSwiftImage)
        }
    }
    
    
    func testDrawSwatchWithoutThisPackage() throws {
        let nativeImageWithoutThisPackage = try NativeImage.swatch_withoutThisPackage(color: testColor, size: size)
        
        guard let pngData = nativeImageWithoutThisPackage.pngData() else {
            XCTFail("Not PNG data")
            return
        }
        
        guard let image = Image<RGB<UInt8>>(data: pngData) else {
            XCTFail("PNG data not PNG data?")
            return
        }
        
        image.forEach { pixel in
            XCTAssertEqual(pixel, testColorForSwiftImage)
        }
    }
    
    
    static let allTests = [
        ("testDrawSwatch", testDrawSwatch),
        ("testDrawSwatchWithoutThisPackage", testDrawSwatchWithoutThisPackage),
    ]
}



extension NativeImage {
    static func swatch(color: NativeColor, size: CGSize = .one) -> NativeImage {
        drawNew(size: size, context: .goodForSwatch(size: size)) { context in
            guard let context = context else {
                XCTFail("No context?")
                return
            }
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

#if canImport(UIKit)
import UIKit



extension UIImage {
    static func swatch_withoutThisPackage(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        defer { UIGraphicsEndImageContext() }
        
        if let context = CGContext.current {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        
        return try UIGraphicsGetImageFromCurrentImageContext().unwrappedOrThrow()
    }
}

#elseif canImport(AppKit)

import AppKit



extension NSImage {
    static func swatch_withoutThisPackage(color: NSColor, size: CGSize = CGSize(width: 1, height: 1)) -> NSImage {
        let image = NSImage(size: size)
        
        image.lockFocusFlipped(NSImage.defaultFlipped)
        defer { image.unlockFocus() }
        
        if let context = CGContext.current {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        
        return image
    }
}
#else
#error("This library requires either UIKit or AppKit")
#endif
