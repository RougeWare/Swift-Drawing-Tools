//
//  NativeImage Extensions.swift
//  Swift Drawing Tools
//
//  Created by Ben Leggiero on 2020-02-17.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#else
#error("Either UIKit or AppKit required")
#endif

import CrossKitTypes
import OptionalTools
import RectangleTools



public extension NativeImage {
    #if canImport(UIKit) || canImport(WatchKit)
        /// The default "flipped" drawing context of the current target OS. That is, whether to flip the Y axis of the
        /// graphics context so that positive is downward. This is `false` in macOS with AppKit, and `true` in the newer
        /// Apple platforms UIKit and WatchKit (Mac Catalyst, iOS, iPadOS, tvOS, and watchOS).
        static let defaultFlipped = true
    #elseif canImport(AppKit)
        /// The default "flipped" drawing context of the current target OS. That is, whether to flip the Y axis of the
        /// graphics context so that positive is downward. This is `false` in macOS with AppKit, and `true` in the newer
        /// Apple platforms UIKit and WatchKit (Mac Catalyst, iOS, iPadOS, tvOS, and watchOS).
        static let defaultFlipped = false
    #else
        #error("Could not infer default 'flipped' drawing context for the target platform")
    #endif
    
    
    
    /// The type of function which can perform an operation when given a graphics context and image
    ///
    /// - Parameters:
    ///   - image:   The image which this function is operating upon
    ///   - context: The graphics context in which this function is operating. This can be `nil`, signifying that the
    ///              context could not be fetched.
    typealias OperationInGraphicsContextWithImage<Return> = (_ image: NativeImage, _ context: CGContext?) throws -> Return
    
    
    
    /// The type of function which can perform an operation when given a graphics context
    ///
    /// - Parameter context: The graphics context in which this function is operating. This can be `nil`, signifying
    ///                      that the context could not be fetched.
    typealias OperationInGraphicsContext<Return> = (_ context: CGContext?) throws -> Return
    
    
    
    /// The type of function which can perform an operation when given an image
    ///
    /// - Parameter image: The image which this function is operating upon
    typealias OperationOnImage<Return> = (_ image: NativeImage) throws -> Return
}



public extension NativeImage {
    
    /// Executes the given function while this image has draw context focus, and automatically unlocks that focus after
    /// the given function returns
    ///
    /// - Parameters:
    ///   - flipped:   _optional_ -`true` if the drawing context should be flipped, otherwise `false`.
    ///                Defaults to the platform's default.
    ///   - operation: The operation to perform while this image has context focus
    ///
    /// - Returns: Anything the given function returns
    ///
    /// - Throws: Anything the given function throws
    func withFocus<Return>(do operation: OperationOnImage<Return>) rethrows -> Return
    {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            self.lockFocus()
            defer { self.unlockFocus() }
        #endif
        
        return try operation(self)
    }
    
    
    /// Executes the given function while this image has draw context focus, and automatically unlocks that focus after
    /// the given function returns
    ///
    /// - Parameters:
    ///   - flipped:   _optional_ -`true` if the drawing context should be flipped, otherwise `false`.
    ///                Defaults to the platform's default.
    ///   - operation: The operation to perform while this image has context focus
    ///
    /// - Returns: Anything the given function returns
    ///
    /// - Throws: Anything the given function throws
    func withFocus<Return>(
        flipped: Bool,
        do operation: OperationOnImage<Return>)
        rethrows -> Return
    {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            self.lockFocusFlipped(flipped)
            defer { self.unlockFocus() }
        #endif
        
        return try operation(self)
    }
    
    
    /// Allows you to perform a contextualized draw operation with the current context on this image.
    ///
    /// - Parameters:
    ///   - flipped:   _optional_ - Whether to flip the Y axis of the graphics context. Defaults to `defaultFlipped`.
    ///   - withFocus: _optional_ - Whether to lock focus on the current image before entering the given function.
    ///                Focus is guaranteed to be unlocked after `operation` exits.
    ///                Defaults to `true`.
    ///   - operation: The contextualized operation to perform while this image has focus lock
    ///
    /// - Returns: Anything the given function returns
    ///
    /// - Throws: Anything the given function throws
    func inCurrentGraphicsContext<Return>(
        flipped: Bool = defaultFlipped,
        withFocus: Bool = true,
        do operation: OperationInGraphicsContextWithImage<Return>)
        rethrows -> Return
    {
        try inGraphicsContext(
            .current,
            flipped: flipped,
            withFocus: withFocus,
            do: operation)
    }
    
    
    /// Allows you to perform a contextualized draw operation with the current context on this image.
    ///
    /// - Parameters:
    ///   - flipped:   _optional_ - Whether to flip the Y axis of the graphics context. Defaults to `defaultFlipped`.
    ///   - withFocus: _optional_ - Whether to lock focus on the current image before entering the given function.
    ///                Focus is guaranteed to be unlocked after `operation` exits.
    ///                Defaults to `true`.
    ///   - operation: The contextualized operation to perform while this image has focus lock
    ///
    /// - Returns: Anything the given function returns
    ///
    /// - Throws: Anything the given function throws
    func inCurrentGraphicsContext<Return>(
        flipped: Bool = defaultFlipped,
        withFocus: Bool = true,
        do operation: OperationInGraphicsContext<Return>)
        rethrows -> Return
    {
        try inGraphicsContext(
            .current,
            flipped: flipped,
            withFocus: withFocus) { _, context in
            try operation(context)
        }
    }
    
    
    /// Allows you to perform a contextualized draw operation on this image with a the given context.
    ///
    /// - Parameters:
    ///   - context:   The graphics context in which to run the given function
    ///   - flipped:   _optional_ - Whether to flip the Y axis of the graphics context. Defaults to `defaultFlipped`.
    ///   - withFocus: _optional_ - Whether to lock focus on the current image before entering the given function.
    ///                Focus is guaranteed to be unlocked after `operation` exits.
    ///                Defaults to `true`.
    ///   - operation: The contextualized operation to perform while this image has focus lock
    ///
    /// - Returns: Anything the given function returns
    ///
    /// - Throws: Anything the given function throws
    func inGraphicsContext<Return>(
        _ context: GraphicsContext,
        flipped: Bool = defaultFlipped,
        withFocus: Bool = true,
        do operation: OperationInGraphicsContextWithImage<Return>)
        rethrows -> Return
    {
        func handleContextSwitch(_ image: NativeImage) throws -> Return {
            try context.inCgContext { context in
                try operation(image, context)
            }
        }
        
        if withFocus {
            return try self.withFocus(flipped: flipped, do: handleContextSwitch)
        }
        else {
            return try handleContextSwitch(self)
        }
    }
    
    
    /// Allows you to perform a contextualized draw operation on this image with a the given context.
    ///
    /// - Parameters:
    ///   - context:   The graphics context in which to run the given function
    ///   - flipped:   _optional_ - Whether to flip the Y axis of the graphics context. Defaults to `defaultFlipped`.
    ///   - withFocus: _optional_ - Whether to lock focus on the current image before entering the given function.
    ///                Focus is guaranteed to be unlocked after `operation` exits.
    ///                Defaults to `true`.
    ///   - operation: The contextualized operation to perform while this image has focus lock
    ///
    /// - Returns: Anything the given function returns
    ///
    /// - Throws: Anything the given function throws
    func inGraphicsContext<Return>(
        _ context: GraphicsContext,
        flipped: Bool = defaultFlipped,
        withFocus: Bool = true,
        do operation: OperationInGraphicsContext<Return>)
        rethrows -> Return
    {
        try inGraphicsContext(
            context,
            flipped: flipped,
            withFocus: withFocus) { _, context in
            try operation(context)
        }
    }
}



public extension NativeImage {
    
    /// Creates a new image and immediately starts drawing on it
    ///
    /// - Note: There are two forms of this function: one that passes the `artist` an image and a context, and one that
    ///         just passes it a context. This is the one which passes both.
    ///
    /// - Parameters:
    ///   - size:    The size of the new image
    ///   - context: _optional_ - The context in which to draw the new image. Defaults to the current context.
    ///   - artist:  The function which will draw the new image
    ///
    /// - Throws: Any error that `artist` throws
    static func drawNew(
        size: CGSize,
        context: GraphicsContext = .current,
        artist: ArtistWithImage)
        rethrows -> NativeImage
    {
        let image: NativeImage
        
        #if canImport(UIKit)
        image = NativeImage(size: size)
        #elseif canImport(AppKit)
        let displayScale = GraphicsContext.Scale.currentDisplay.forNsGraphics
        let desiredScale = context.scale.forNsGraphics
        image = NativeImage(size: CGSize(width:  (size.width  / displayScale.width)  * desiredScale.width,
                                         height: (size.height / displayScale.height) * desiredScale.height))
        #endif
        
        return try image.inGraphicsContext(context, withFocus: true) { image, context in
            try artist(image, context)
            #if canImport(UIKit)
            return try UIGraphicsGetImageFromCurrentImageContext().unwrappedOrThrow()
            #elseif canImport(AppKit)
            return image
            #endif
        }
    }
    
    
    /// Creates a new image and immediately starts drawing on it
    ///
    /// - Note: There are two forms of this function: one that passes the `artist` an image and a context, and one that
    ///         just passes it a context. This is the one which just passes the context.
    ///
    /// - Parameters:
    ///   - size:    The size of the new image
    ///   - context: _optional_ - The context in which to draw the new image. Defaults to the current context.
    ///   - artist:  The function which will draw the new image
    ///
    /// - Throws: Any error that `artist` throws
    @inline(__always)
    static func drawNew(
        size: CGSize,
        context: GraphicsContext = .current,
        artist: Artist)
        rethrows -> NativeImage
    {
        try drawNew(size: size, context: context) { _, context in
            try artist(context)
        }
    }
    
    
    
    /// The type of function which can draw in a graphics context
    ///
    /// - Parameter context: The graphics context in which this function is operating. This can be nil, signifying that
    ///                      the context could not be fetched.
    typealias Artist = OperationInGraphicsContext<Void>
    
    
    
    /// The type of function which can draw in a graphics context, and which needs an image reference to do so
    ///
    /// - Parameters:
    ///   - image:   The image which this function is operating upon
    ///   - context: The graphics context in which this function is operating. This can be nil, signifying that the
    ///              context could not be fetched.
    typealias ArtistWithImage = OperationInGraphicsContextWithImage<Void>
}



/// An error which might happen when trying to draw an image
public enum ImageDrawingError {
    
    /// The image couldn't be retrieved out of the current graphics context
    case couldNotGetImageFromGraphicsContext
}



#if canImport(UIKit)
public extension UIImage {
    
    /// Creates a new `UIImage` of the given size, with no content. It is expected that you will immediately draw onto
    /// it. Using this image without drawing it first is undefined behavior.
    ///
    /// This approximates a similar `NSImage` initializer:
    /// https://developer.apple.com/documentation/appkit/nsimage/1520033-init
    ///
    /// - Parameter size: The size of the image, measured in points
    convenience init(size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(
            /*size:*/ rect.size,
            /*opaque:*/ false,
            /*scale:*/ 0 // This means "Use the current screen's scale"
        )
        
        defer { UIGraphicsEndImageContext() }
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        
        self.init(cgImage: cgImage)
    }
}
#endif



#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public extension NSImage {
    func pngData() -> Data? {
        // https://stackoverflow.com/a/17510651/3939277
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = self.size
        return newRep.representation(using: .png, properties: [:])

    }
}
#endif



public extension CGContext {
    
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
