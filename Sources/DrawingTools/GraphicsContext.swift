//
//  GraphicsContext.swift
//  
//
//  Created by Ben Leggiero on 2020-07-26.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#else
#error("Platform not supported")
#endif

import CrossKitTypes
import RectangleTools



/// Represents a graphics context
public enum GraphicsContext {
    
    /// The current graphics context
    case current
    
    /// A new graphics context
    ///
    /// - Parameters:
    ///   - size:   The size of the new graphics context
    ///   - opaque: _optional_ - `true` if the context should be opaque, `false` if it should have an alpha channel.
    ///             Defaults to `false`, meaning it will have an alpha channel.
    ///   - scale:  The scale (PPI) of the graphics context
    case new(size: UIntSize, opaque: Bool = false, scale: Scale = .currentDisplay)
}



public extension GraphicsContext {
    
    /// The scale (PPI) of a graphics context
    enum Scale {
        
        /// Use the same scale (PPI) as the current display
        case currentDisplay
        
        /// Use a 1-to-1 scale (PPI) - 1 pixel on the display is 1 point in the image
        case oneToOne
        
        /// Use a custom scale (PPI)
        ///  - Parameter multiplier: The scale (PPI) multiplier.
        ///                          `1` is the same as `.oneToOne`, greater means higher density
        case multiple(multiplier: CGFloat)
    }
}



#if canImport(UIKit)
public extension GraphicsContext.Scale {
    /// The value to pass to UIGraphics calls like `UIGraphicsBeginImageContextWithOptions`
    var forUiGraphics: CGFloat {
        switch self {
        case .currentDisplay:                       return 0
        case .oneToOne:                             return 1
        case .multiple(multiplier: let multiplier): return multiplier
        }
    }
}
#endif



public extension GraphicsContext {
    
    /// A graphics context which is good for drawing solid-color swatches.
    /// See also `goodForSwatch` (variable form).
    ///
    /// - Parameter size: The size you plan to make the swatch
    /// - Returns: A context good for drawing a swatch of the given size
    static func goodForSwatch<Size>(size: Size) -> Self
    where Size: Size2D,
          Size.Length: BinaryInteger
    {
        .new(size: .init(size), opaque: true, scale: .oneToOne)
    }
    
    
    /// A graphics context which is good for drawing solid-color swatches.
    /// See also `goodForSwatch` (variable form).
    ///
    /// - Parameter size: The size you plan to make the swatch
    /// - Returns: A context good for drawing a swatch of the given size
    static func goodForSwatch<Size>(size: Size) -> Self
    where Size: Size2D,
          Size.Length: BinaryFloatingPoint
    {
        .new(size: .init(size), opaque: true, scale: .oneToOne)
    }
    
    
    /// A graphics context which is good for drawing `1×1` solid-color swatches
    /// See also `goodForSwatch(size:)` (function form). 
    ///
    /// - Returns: A context good for drawing a swatch of the given size
    static var goodForSwatch: Self {
        goodForSwatch(size: CGSize.one)
    }
}



// MARK: - Platform stuff

public extension GraphicsContext {
    func inCgContext<Return>(do operation: NativeImage.OperationInGraphicsContext<Return>)
        rethrows -> Return
    {
        switch self {
        case .current:
            return try operation(.current)
            
        case .new(size: let size, opaque: let opaque, scale: let scale):
            #if canImport(UIKit)
            UIGraphicsBeginImageContextWithOptions(.init(size), opaque, scale.forUiGraphics)
            defer { UIGraphicsEndImageContext() }
            #endif
            return try operation(.current)
        }
    }
}



public extension CGContext {
    typealias Scale = GraphicsContext.Scale
}



#if canImport(AppKit)
import AppKit



public extension NSGraphicsContext {
    typealias Scale = GraphicsContext.Scale
}
#endif
