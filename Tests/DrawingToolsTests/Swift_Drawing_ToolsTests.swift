import XCTest

import CrossKitTypes
import DrawingTools
import RectangleTools
import SwiftImage



final class Swift_Drawing_ToolsTests: XCTestCase {
    func testDrawRedSwatch() throws {
        let nativeImage = try NativeImage.swatch(
            color: NativeColor(red: 0x42/0xFF, green: 0x69/0xFF, blue: 0xAD/0xFF, alpha: 1),
            size: CGSize(width: 2, height: 2))
        
        guard let pngData = nativeImage.pngData() else {
            XCTFail("Not PNG data")
            return
        }
        
        guard let image = Image<RGB<UInt8>>(data: pngData) else {
            XCTFail("PNG data not PNG data?")
            return
        }
        
        image.forEach { pixel in
            XCTAssertEqual(pixel, RGB(red: 0x42, green: 0x69, blue: 0xAD))
        }
    }
    
    
    static let allTests = [
        ("testDrawRedSwatch", testDrawRedSwatch),
    ]
}



extension NativeImage {
    static func swatch(color: NativeColor, size: CGSize = .one) throws -> NativeImage {
        try drawNew(size: size, context: .goodForSwatch(size: size)) { context in
            guard let context = context else {
                XCTFail("No context?")
                return
            }
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
