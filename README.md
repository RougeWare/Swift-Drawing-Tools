# Swift Drawing Tools #

Some tools to help with drawing in Swift



## Context Sugar ##

The first tool in this package is some syntactic sugar around `CGContext`. This lets you discard the boilerplate and get down to what really matters. For example:

### With Drawing Tools: ###
```swift
import DrawingTools
import CrossKitTypes
import RectangleTools

extension NativeImage {
    static func swatch(color: NativeColor, size: CGSize = .one) throws -> NativeImage {
        try drawNew(size: size, context: .goodForSwatch(size: size)) { context in
            guard let context = context else { return }
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
```

### Without Drawing Tools: ###
```swift
#if canImport(UIKit)
import UIKit



extension UIImage {
    static func swatch(color: NativeColor, size: CGSize = CGSize(width: 1, height: 1)) throws -> NativeImage {
        let image = NativeImage(size: size)
        
        UIGraphicsBeginImageContextWithOptions(.init(size), opaque, scale.forUiGraphics)
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
    static func swatch(color: NSColor, size: CGSize = CGSize(width: 1, height: 1)) throws -> NSImage {
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
#error("This library requires either UIKit or AppKit")
#endif
```
