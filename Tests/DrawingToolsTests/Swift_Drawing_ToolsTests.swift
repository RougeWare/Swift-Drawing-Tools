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
        
        guard let pngImage = PNG(data: pngData) else {
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
    
    
    /// Draws a simple image and checks all the bits to make sure it looks like we expect
    ///
    /// ```
    ///   0
    /// 0 🟨🟨🟥🟨🟨
    ///   🟨🟥⬜️🟩🟨
    ///   ⬛️⬜️⬜️⬜️🟩
    ///   🟨⬛️⬜️🟦🟨
    ///   🟨🟨🟦🟨🟨
    /// ```
    func testDrawDiamond() {
        
        let intImageSize = IntSize(width: 5, height: 5)
        let imageSize = CGSize(intImageSize)
        
        let white  = NativeColor.white.cgColor
        let black  = NativeColor.black.cgColor
        let red    = NativeColor.red.cgColor
        let green  = NativeColor.green.cgColor
        let blue   = NativeColor.blue.cgColor
        let yellow = NativeColor.yellow.cgColor
        
        let nativeImage = NativeImage.drawNew(size: imageSize, context: .new(size: .init(intImageSize), opaque: true, scale: .oneToOne), flipped: true) { context in
            guard let context = context else {
                return XCTFail("No context when drawing")
            }
            
            context.setShouldAntialias(false)
            context.setLineWidth(1)
            
            context.setFillColor(white)
            context.fill(.init(origin: .zero, size: imageSize))
            
            // Since CGContext always strokes paths from the center, we have to manually offset these lines so they
            // appear a 0.5px offset from where we expect them.
            // You can check this by drawing a custom view, or using purely native tools to draw this image instead of
            // this package, then saving that image as a PNG.
            // These CGContext setting lines are there to help mitigate this.
            context.setLineJoin(CGLineJoin.miter)
            context.setMiterLimit(.infinity)
            
            context.setStrokeColor(yellow)
            context.stroke(.init(x: 0.5, y: 0.5, width: 4, height: 4))

            context.setStrokeColor(red)
            context.move   (to: .init(x: 1.5, y: 1.5))
            context.addLine(to: .init(x: 2.5, y: 0.5))
            context.strokePath()

            context.setStrokeColor(green)
            context.move   (to: .init(x: 3.5, y: 1.5))
            context.addLine(to: .init(x: 4.5, y: 2.5))
            context.strokePath()

            context.setStrokeColor(blue)
            context.move   (to: .init(x: 3.5, y: 3.5))
            context.addLine(to: .init(x: 2.5, y: 4.5))
            context.strokePath()

            context.setStrokeColor(black)
            context.move   (to: .init(x: 1.5, y: 3.5))
            context.addLine(to: .init(x: 0.5, y: 2.5))
            context.strokePath()
        }
        
        guard let pngData = nativeImage.pngData() else {
            XCTFail("Not PNG data")
            return
        }
        
        guard let pngImage = PNG(data: pngData) else {
            XCTFail("PNG data not PNG data?")
            return
        }
        
        XCTAssertEqual(pngImage.width, .init(intImageSize.width))
        XCTAssertEqual(pngImage.height, .init(intImageSize.height))
        
        
        func pixel(_ x: Int, _ y: Int) -> PNG.Pixel {
            guard let pixel = pngImage.pixelAt(x: x, y: y) else {
                XCTFail("No pixel at (\(x), \(y))")
                fatalError()
            }
            
            return pixel
        }
        
        
        func row(y: Int) -> [PNG.Pixel] {
            (0..<intImageSize.width)
                .map { pixel($0, y) }
        }
        
        
        func hexRow(y: Int) -> [UInt32] {
            row(y: y).map(\.hexRRGGBB)
        }
        
        
        func hexes() -> [[UInt32]] {
            (0..<intImageSize.height).map(hexRow)
        }
        
        
        let expectedHexes: [[UInt32]] = [
            [0xFFFF00, 0xFFFF00, 0xFF0000, 0xFFFF00, 0xFFFF00],
            [0xFFFF00, 0xFF0000, 0xFFFFFF, 0x00FF00, 0xFFFF00],
            [0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x00FF00],
            [0xFFFF00, 0x000000, 0xFFFFFF, 0x0000FF, 0xFFFF00],
            [0xFFFF00, 0xFFFF00, 0x0000FF, 0xFFFF00, 0xFFFF00],
        ]
        
        
        print("\n\nExpected:")
        print(expectedHexes.hexStrings.map { $0.joined(separator: "  ") } .joined(separator: "\n\n"))
        
        
        print("\n\nActual:")
        print(hexes().hexStrings.map { $0.joined(separator: "  ") } .joined(separator: "\n\n"))
        
        
        XCTAssertEqual(hexes().hexStrings, expectedHexes.hexStrings)
    }
    
    
    static let allTests = [
        ("testDrawSwatch", testDrawSwatch),
        ("testDrawSwatchWithoutThisPackage", testDrawSwatchWithoutThisPackage),
        ("testDrawDiamond", testDrawDiamond),
    ]
}



typealias PNG = Image<RGB<UInt8>>



extension RGB where Channel == UInt8 {
    /// The hex encoding of this pixel, as a `UInt32`, in the format `0xRRGGBB`
    var hexRRGGBB: UInt32 {
        UInt32()
        | UInt32(red)   << (Channel.bitWidth * 2)
        | UInt32(green) << (Channel.bitWidth * 1)
        | UInt32(blue)//<< (Channel.bitWidth * 0)
    }
}



extension Array where Element == [UInt32] {
    var hexStrings: [[String]] {
        map(\.hexStrings)
    }
}



extension Array where Element == UInt32 {
    var hexStrings: [String] {
        map(\.hexString)
    }
}



extension UInt32 {
    var hexString: String {
        let unpadded = String(self, radix: 0x10, uppercase: true)
        return String(repeating: "0", count: Swift.max(0, 6 - unpadded.count))
            + unpadded
    }
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
