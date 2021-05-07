//
//  GraphicsContext.swift
//  Swift Drawing Tools
//
//  Created by Ben Leggiero on 2020-07-26.
//  Copyright © 2020 Ben Leggiero BH-1-PS
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



/// Abstracts a graphics context. This is useful for lazy evaluation and cross-platform context management.
public enum GraphicsContext {
    
    /// The current graphics context
    case current
    
    /// A new graphics context
    ///
    /// - Parameters:
    ///   - size:   The size of the new graphics context
    ///   - opaque: _optional_ - `true` if the context should be opaque, `false` if it should have an alpha channel.
    ///             Defaults to `false`, meaning it will have an alpha channel.
    ///   - scale:  _optional_ - The scale (PPI) of the graphics context. Defaults to `.currentDisplay`
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
#elseif canImport(AppKit)
public extension GraphicsContext.Scale {
    /// The value to use when considering the scale of a `CGContext` is AppKit
    var forAppKit: CGSize {
        switch self {
        case .currentDisplay:
            guard let currentScreen = NSScreen.main ?? NSScreen.deepest ?? NSScreen.screens.first else {
                print("Attempted to scale CGContext for AppKit, but there doesn't seem to be a screen attached")
                return .one
            }
            
            let scaleFactor = currentScreen.backingScaleFactor
            return .init(width: scaleFactor, height: scaleFactor)
            
        case .oneToOne:                             return .one
        case .multiple(multiplier: let multiplier): return .init(width: multiplier, height: multiplier)
        }
    }
    
    
    /// Multiply your image's size by this to make sure that it is the current size in the current CGContext's true display scale
    var appKitScaleMultiplier: CGSize {
        let displayScale = Self.currentDisplay.forAppKit
        let desiredScale = self.forAppKit
        
        return CGSize(width:  (desiredScale.width  / displayScale.width),
                      height: (desiredScale.height / displayScale.height))
    }
}
#endif



public extension GraphicsContext {
    var scale: Scale {
        switch self {
        case .current:
            return .currentDisplay // FIXME: Maybe not the best approach
        
        case .new(size: _, opaque: _, scale: let scale):
            return scale
        }
    }
}



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
    
    /// Performs the given operation in a `CGContext`
    ///
    /// This takes care of all platform differences automatically.
    ///
    /// - Parameter operation: The operation to perform in a `CGContext`
    /// - Throws: Anything `operation` throws
    /// - Returns: Anything `operation` returns
    func inCgContext<Return>(do operation: NativeImage.OperationInGraphicsContext<Return>)
        rethrows -> Return
    {
        switch self {
        case .current:
            return try operation(.current)
            
        case .new(size: let size, opaque: let opaque, scale: let scale):
            
            let context: CGContext?
            
            #if canImport(UIKit)
            UIGraphicsBeginImageContextWithOptions(.init(size), opaque, scale.forUiGraphics)
            defer { UIGraphicsEndImageContext() }
            context = .current
            #else
            context = .current
            let newScale = self.scale.appKitScaleMultiplier
            context?.scaleBy(x: newScale.width, y: newScale.height)
            #endif
            
            return try operation(context)
        }
    }
}



public extension CGContext {
    typealias Scale = GraphicsContext.Scale
}



#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit



public extension NSGraphicsContext {
    typealias Scale = GraphicsContext.Scale
}
#endif
