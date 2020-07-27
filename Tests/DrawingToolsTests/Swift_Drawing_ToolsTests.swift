import XCTest
import DrawingTools
import CrossKitTypes

final class Swift_Drawing_ToolsTests: XCTestCase {
    func testNothing() {
        let image = NativeImage.swatch(color: .systemRed, size: .init(width: 2, height: 2))
        try! image.pngData()!.write(to: URL(fileURLWithPath: "/Users/benleggiero/Desktop/red.png"))
        print(image)
    }

    static var allTests = [
        ("testNothing", testNothing),
    ]
}



private extension UIImage {
    
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
