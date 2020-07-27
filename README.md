# Swift Drawing Tools #

Some tools to help with drawing in Swift



## Context Sugar ##

The first tool in this package is some syntactic sugar around `CGContext`. This lets you discard the boilerplate and get down to what really matters. For example:

**With Drawing Tools:**
```swift
extension NativeImage {
    static func swatch(color: NativeColor, size: CGSize = CGSize(width: 1, height: 1)) -> NativeImage {
        NativeImage(size: size) { swatch, context in
            guard let context = context else { return swatch }
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: swatch.size))
        }
    }
}
```

**Without Drawing Tools:**
```swift
#if canImport(UIKit)
extension UIImage {
    
    static func swatch(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(/*size:*/ .init(size), /*opaque:*/ true, /*scale:*/ 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return .init()
        }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return UIImage()
        }
        
        let swatch = UIImage(cgImage: cgImage)
        
        return swatch
    }
}
#elseif canImport(AppKit)
extension NSImage {
    
    static func swatch(color: NSColor, size: CGSize = CGSize(width: 1, height: 1)) -> NSImage {
        self.lockFocus()
        defer { self.unlockFocus() }
        
        guard let context = NSGraphicsContext.current?.cgContext else {
            return NSImage()
        }
        
        let swatch = NSImage(size: size)
        
        let priorContext = NSGraphicsContext.current
        defer { NSGraphicsContext.current = priorContext }
        
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: swatch.size))
        
        return swatch
    }
}
#else
#error("This library currently only supports UIKit and AppKit")
#endif
```
