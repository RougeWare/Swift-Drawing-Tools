//
//  SwatchTests.swift
//  Swift Drawing Tools
//
//  Created by Ben Leggiero on 2020-08-29.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import XCTest

import CrossKitTypes
import DrawingTools
import RectangleTools
import SwiftImage



let softBlue = NativeColor(            red: 0x42/0xFF, green: 0x69/0xFF, blue: 0xAD/0xFF, alpha: 1)
let softBlueForSwiftImage = RGB<UInt8>(red: 0x42,      green: 0x69,      blue: 0xAD)
let size = CGSize(width: 2, height: 2)


let 🟥    = NativeColor(red: 0xFF/0xFF, green: 0x13/0xFF, blue: 0x32/0xFF, alpha: 1)
let 🟥Rgb = RGB<UInt8>( red: 0xFF,      green: 0x13,      blue: 0x32)

let 🟩    = NativeColor(red: 0x02/0xFF, green: 0xF3/0xFF, blue: 0x21/0xFF, alpha: 1)
let 🟩Rgb = RGB<UInt8>( red: 0x02,      green: 0xF3,      blue: 0x21)

let 🟦    = NativeColor(red: 0x21/0xFF, green: 0x32/0xFF, blue: 0xFA/0xFF, alpha: 1)
let 🟦Rgb = RGB<UInt8>( red: 0x21,      green: 0x32,      blue: 0xFA)

let 🟧    = NativeColor(red: 0xFA/0xFF, green: 0x8D/0xFF, blue: 0x09/0xFF, alpha: 1)
let 🟧Rgb = RGB<UInt8>( red: 0xFA,      green: 0x8D,      blue: 0x09)

let 🟪    = NativeColor(red: 0xFD/0xFF, green: 0x20/0xFF, blue: 0xFA/0xFF, alpha: 1)
let 🟪Rgb = RGB<UInt8>( red: 0xFD,      green: 0x20,      blue: 0xFA)

let 🟨    = NativeColor(red: 0xFE/0xFF, green: 0xF3/0xFF, blue: 0x01/0xFF, alpha: 1)
let 🟨Rgb = RGB<UInt8>( red: 0xFE,      green: 0xF3,      blue: 0x01)

private let expectedTestSwatchGridColors = [
    [🟥, 🟩, 🟦, 🟧, 🟪, 🟨],
    [🟩, 🟦, 🟧, 🟪, 🟨, 🟥],
    [🟦, 🟧, 🟪, 🟨, 🟥, 🟩],
    [🟧, 🟪, 🟨, 🟥, 🟩, 🟦],
    [🟪, 🟨, 🟥, 🟩, 🟦, 🟧],
    [🟨, 🟥, 🟩, 🟦, 🟧, 🟪],
]

private let expectedTestSwatchGridRgbColors = [
    [🟥Rgb, 🟩Rgb, 🟦Rgb, 🟧Rgb, 🟪Rgb, 🟨Rgb],
    [🟩Rgb, 🟦Rgb, 🟧Rgb, 🟪Rgb, 🟨Rgb, 🟥Rgb],
    [🟦Rgb, 🟧Rgb, 🟪Rgb, 🟨Rgb, 🟥Rgb, 🟩Rgb],
    [🟧Rgb, 🟪Rgb, 🟨Rgb, 🟥Rgb, 🟩Rgb, 🟦Rgb],
    [🟪Rgb, 🟨Rgb, 🟥Rgb, 🟩Rgb, 🟦Rgb, 🟧Rgb],
    [🟨Rgb, 🟥Rgb, 🟩Rgb, 🟦Rgb, 🟧Rgb, 🟪Rgb],
]



final class SwatchTests: XCTestCase {
    
    func testDrawSwatch() {
        let nativeImage = NativeImage.swatch(color: softBlue, size: size)
        
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
            XCTAssertEqual(pixel, softBlueForSwiftImage)
        }
        
        XCTAssertEqual(pixelCount, .init(size.area))
    }
    
    
    func testDrawSwatchWithoutThisPackage() {
        let nativeImageWithoutThisPackage = NativeImage.swatch_withoutThisPackage(color: softBlue, size: size)
        
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
            XCTAssertEqual(pixel, softBlueForSwiftImage)
        }
        
        XCTAssertEqual(pixelCount, .init(size.area))
    }
    
    
    func testDrawSwatchGrid() {
        let colorCount = expectedTestSwatchGridColors.count
        let multiplier = 2
        let uIntSize = UIntSize(width:  .init(colorCount * multiplier),
                                height: .init(colorCount * multiplier))
        let cgSize = CGSize(uIntSize)
        let eachSwatchSize = CGSize(width: multiplier,
                                    height: multiplier)
        
        let swatchGridImage = NativeImage.drawNew(
            size: cgSize,
            flipped: true,
            context: .goodForSwatch(size: uIntSize))
        { context in
            expectedTestSwatchGridColors.enumerated().forEach { rowIndex, row in
                row.enumerated().forEach { columnIndex, color in
                    context!.setFillColor(color.cgColor)
                    context!.fill(CGRect(origin: CGPoint(x: columnIndex * multiplier,
                                                         y: rowIndex    * multiplier),
                                         size: eachSwatchSize))
                }
            }
        }
        
        guard let pngData = swatchGridImage.pngData() else {
            XCTFail("Not PNG data")
            return
        }
        
        guard let pngImage = Image<RGB<UInt8>>(data: pngData) else {
            XCTFail("PNG data not PNG data?")
            return
        }
        
        expectedTestSwatchGridRgbColors.enumerated().forEach { rowIndex, row in
            row.enumerated().forEach { columnIndex, color in
                XCTAssertEqual(pngImage[(columnIndex * 2)    , (rowIndex * 2)    ], color)
                XCTAssertEqual(pngImage[(columnIndex * 2) + 1, (rowIndex * 2)    ], color)
                XCTAssertEqual(pngImage[(columnIndex * 2)    , (rowIndex * 2) + 1], color)
                XCTAssertEqual(pngImage[(columnIndex * 2) + 1, (rowIndex * 2) + 1], color)
            }
        }
    }
    
    
    static let allTests = [
        ("testDrawSwatch", testDrawSwatch),
        ("testDrawSwatchWithoutThisPackage", testDrawSwatchWithoutThisPackage),
        ("drawSwatchGrid", testDrawSwatchGrid),
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
