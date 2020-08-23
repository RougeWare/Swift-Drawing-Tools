import XCTest

import CrossKitTypes
import DrawingTools
import RectangleTools
import SwiftImage



final class Swift_Drawing_ToolsTests: XCTestCase {
    let testColor = NativeColor(            red: 0x42/0xFF, green: 0x69/0xFF, blue: 0xAD/0xFF, alpha: 1)
    let testColorForSwiftImage = RGB<UInt8>(red: 0x42,      green: 0x69,      blue: 0xAD)
    let size = CGSize(width: 2, height: 2)
    
    func testDrawSwatch() throws {
        let nativeImage = NativeImage.swatch(color: testColor, size: size)
        
        guard let pngData = nativeImage.pngData() else {
            XCTFail("Not PNG data")
            return
        }
        
        guard let pngImage = Image<RGB<UInt8>>(data: pngData) else {
            XCTFail("PNG data not PNG data?")
            return
        }
        
        var pixelCount = 0
        
        pngImage.forEach { pixel in
            pixelCount += 1
            XCTAssertEqual(pixel, testColorForSwiftImage)
        }
        
        XCTAssertEqual(pixelCount, .init(size.area))
    }
    
    
    func testDrawSwatchWithoutThisPackage() throws {
        let nativeImageWithoutThisPackage = NativeImage.swatch_withoutThisPackage(color: testColor, size: size)
        
        guard let pngData = nativeImageWithoutThisPackage.pngData() else {
            XCTFail("Not PNG data")
            return
        }
        
        guard let pngImage = Image<RGB<UInt8>>(data: pngData) else {
            XCTFail("PNG data not PNG data?")
            return
        }
        
        var pixelCount = 0
        
        pngImage.forEach { pixel in
            pixelCount += 1
            XCTAssertEqual(pixel, testColorForSwiftImage)
        }
        
        XCTAssertEqual(pixelCount, .init(size.area))
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
                assertionFailure("No context?")
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
    static func swatch_withoutThisPackage(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        else {
            assertionFailure("No context?")
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
            ?? UIImage(size: size)
    }
}

#elseif canImport(AppKit)

import AppKit



extension NSImage {
    static func swatch_withoutThisPackage(color: NSColor, size: CGSize = CGSize(width: 1, height: 1)) -> NSImage {
        let displayScale: CGSize
        
        if let currentScreen = NSScreen.main ?? NSScreen.deepest ?? NSScreen.screens.first {
            let scaleFactor = currentScreen.backingScaleFactor
            displayScale = CGSize(width: scaleFactor, height: scaleFactor)
        }
        else {
            print("Attempted to scale CGContext for AppKit, but there doesn't seem to be a screen attached")
            displayScale = CGSize(width: 1, height: 1)
        }
        
        let image = NSImage(size: CGSize(width:  (size.width  / displayScale.width)  * 1,
                                         height: (size.height / displayScale.height) * 1))
        
        image.lockFocusFlipped(false)
        defer { image.unlockFocus() }
        if let context = NSGraphicsContext.current?.cgContext {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        else {
            assertionFailure("No context?")
        }
        
        return image
    }
}

#else
#error("This library requires either UIKit or AppKit")
#endif
