//
//  NativeImage Extensions.swift
//  Swift Drawing Tools
//
//  Created by Ben Leggiero on 2020-02-17.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import Foundation
import CrossKitTypes
import RectangleTools

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#else
#error("Either UIKit or AppKit required")
#endif



public extension NativeImage {
    #if canImport(UIKit) || canImport(WatchKit)
        /// The default "flipped" drawing context of the current target OS. That is, whether to flip the Y axis of the
        /// graphics context so that positive is downward. This is `false` in macOS with AppKit, and `true` in the newer
        /// Apple platforms UIKit and WatchKit.
        static let defaultFlipped = true
    #elseif canImport(AppKit)
        /// The default "flipped" drawing context of the current target OS. That is, whether to flip the Y axis of the
        /// graphics context so that positive is downward. This is `false` in macOS with AppKit, and `true` in the newer
        /// Apple platforms UIKit and WatchKit.
        static let defaultFlipped = false
    #else
        #error("Could not infer default 'flipped' drawing context for the target OS")
    #endif
}



public extension NativeImage {
    
    /// Executes the given function while this image has draw context focus,
    /// and automatically unlocks that focus after the block is done
    ///
    /// - Parameters:
    ///   - flipped:   _optional_ -`true` if the drawing context should be flipped, otherwise `false`.
    ///                Defaults to the platform's default.
    ///   - opaque:    **UIKit Only** _optional_ - `true` if the bitmap is opaque. If you know the bitmap is fully
    ///                opaque, specify `true` to ignore the alpha channel and optimize the bitmap’s storage. Specifying
    ///                `false` means that the bitmap must include an alpha channel to handle any partially transparent
    ///                pixels.
    ///                Defaults to `false`.
    ///   - operation: The operation to perform while this image has context focus
    ///
    /// - Returns: Anything the given function throws
    ///
    /// - Throws: Anything the given function throws
    func withFocus<Return>(opaque: Bool = false,
                           do operation: (_ image: NativeImage) throws -> Return)
        rethrows -> Return
    {
        #if canImport(UIKit)
            UIGraphicsBeginImageContextWithOptions(/*size:*/ self.size, /*opaque:*/ true, /*scale:*/ 0)
            defer { UIGraphicsEndImageContext() }
        #elseif canImport(AppKit)
            self.lockFocus()
            defer { self.unlockFocus() }
        #else
            #error("Only UIKit and AppKit are supported at this time")
        #endif
        
        return try operation(self)
    }
    
    
    /// Executes the given function while this image has draw context focus,
    /// and automatically unlocks that focus after the block is done
    ///
    /// - Parameters:
    ///   - flipped:   _optional_ -`true` if the drawing context should be flipped, otherwise `false`.
    ///                Defaults to the platform's default.
    ///   - opaque:    **UIKit Only** _optional_ - `true` if the bitmap is opaque. If you know the bitmap is fully
    ///                opaque, specify `true` to ignore the alpha channel and optimize the bitmap’s storage. Specifying
    ///                `false` means that the bitmap must include an alpha channel to handle any partially transparent
    ///                pixels.
    ///                Defaults to `false`.
    ///   - operation: The operation to perform while this image has context focus
    ///
    /// - Returns: Anything the given function throws
    ///
    /// - Throws: Anything the given function throws
    func withFocus<Return>(flipped: Bool,
                           opaque: Bool = false,
                           do operation: (_ image: NativeImage) throws -> Return)
        rethrows -> Return
    {
        #if canImport(UIKit)
            UIGraphicsBeginImageContextWithOptions(/*size:*/ self.size, /*opaque:*/ opaque, /*scale:*/ 0)
            defer { UIGraphicsEndImageContext() }
        #elseif canImport(AppKit)
            self.lockFocusFlipped(flipped)
            defer { self.unlockFocus() }
        #else
            #error("Only UIKit and AppKit are supported at this time")
        #endif
        
        return try operation(self)
    }
    
    
    /// Allows you to perform a contextualized draw operation with the current context on this image. The image will
    /// have focus lock while in the given function.
    ///
    /// - Parameters:
    ///   - flipped:   _optional_ - Whether to flip the Y axis of the graphics context. Defaults to `defaultFlipped`.
    ///   - withFocus: _optional_ - Whether to lock focus on the current image before entering the given function.
    ///                Defaults to `true`.
    ///   - operation: The contextualized operation to perform while this image has focus lock
    ///
    /// - Returns: Anything the given function throws
    ///
    /// - Throws: Anything the given function throws
    func inCurrentGraphicsContext<Return>(flipped: Bool = defaultFlipped,
                                          withFocus: Bool = true,
                                          do operation: OperationInCurrentGraphicsContext<Return>)
        rethrows -> Return
    {
        func handleContextSwitch(_ image: NativeImage) throws -> Return {
            guard let context = CGContext.current else {
                return try operation(image, nil)
            }
            
            #if canImport(UIKit)
                UIGraphicsPushContext(context)
                defer { UIGraphicsPopContext() }
            #elseif canImport(AppKit)
                let priorContext = NSGraphicsContext.current
                defer { NSGraphicsContext.current = priorContext }
                
                NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
            #else
                #error("This library currently only supports UIKit and AppKit")
            #endif
            
            return try operation(image, context)
        }
        
        if withFocus {
            return try self.withFocus(do: handleContextSwitch)
        }
        else {
            return try handleContextSwitch(self)
        }
    }
    
    
    
    typealias OperationInCurrentGraphicsContext<Return> = (_ image: NativeImage, _ context: CGContext?) throws -> Return
}



#if canImport(UIKit)
public extension UIImage {
    
    /// Approximates a similar `NSImage` initializer:
    /// https://developer.apple.com/documentation/appkit/nsimage/1520033-init
    ///
    /// To quote the documentation of the `NSImage` initializer:
    ///
    /// > This method does not add any image representations to the image object. It is permissible to initialize the
    /// > image object by passing a size of `(0.0, 0.0)`; however, you must set the size to a non-zero value before
    /// > using it or an exception will be raised.
    /// >
    /// > After using this method to initialize an image object, you are expected to provide the image contents before
    /// > trying to draw the image. You might lock focus on the image and draw to the image or you might explicitly
    /// > add an image representation that you created.
    ///
    /// - Parameter size: The size of the image, measured in points
    convenience init(size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        
        self.init(cgImage: cgImage)
    }
}
#endif



private extension CGContext {
    
    /// Returns the current `CGContext`
    ///
    /// The current graphics context is `nil` by default. Prior to calling its `drawRect` method, view objects push a
    /// valid context onto the stack, making it current.
    ///
    ///
    /// # UIKit Only:
    /// If you are not using a `UIView` object to do your drawing, you must push a valid context onto the stack
    /// manually using the `UIGraphicsPushContext(_:)` function.
    ///
    /// This function may be called from any thread of your app.
    static var current: CGContext? {
        #if canImport(UIKit)
            return UIGraphicsGetCurrentContext()
        #elseif canImport(AppKit)
            return NSGraphicsContext.current?.cgContext
        #endif
    }
}
