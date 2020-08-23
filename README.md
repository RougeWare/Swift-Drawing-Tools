# Swift Drawing Tools #

Some tools to help with drawing in Swift



## Context Sugar ##

The first tool in this package is some syntactic sugar around `CGContext`. This lets you discard the boilerplate and get down to what really matters. For example, if you wanted to draw a color swatch:

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
    static func swatch(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
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
    static func swatch(color: NSColor, size: CGSize = CGSize(width: 1, height: 1)) -> NSImage {
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
```
