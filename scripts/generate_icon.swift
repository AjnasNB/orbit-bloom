import AppKit
import ImageIO
import UniformTypeIdentifiers
let size = NSSize(width: 1024, height: 1024)
let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
let rect = NSRect(origin: .zero, size: size)
NSGradient(starting: NSColor(calibratedRed: 0.08, green: 0.24, blue: 0.27, alpha: 1), ending: NSColor(calibratedRed: 0.025, green: 0.10, blue: 0.15, alpha: 1))!.draw(in: rect, angle: -70)
let planet = NSBezierPath(ovalIn: NSRect(x: 185, y: 165, width: 654, height: 654))
NSColor(calibratedRed: 0.12, green: 0.34, blue: 0.35, alpha: 1).setFill(); planet.fill()
let ring = NSBezierPath(ovalIn: NSRect(x: 90, y: 365, width: 845, height: 260))
let tr = AffineTransform(rotationByDegrees: 27); ring.transform(using: tr)
// A clean original botanical emblem, with an orbital accent.
let leaf = NSBezierPath()
leaf.move(to: NSPoint(x: 337, y: 300))
leaf.curve(to: NSPoint(x: 720, y: 760), controlPoint1: NSPoint(x: 280, y: 630), controlPoint2: NSPoint(x: 500, y: 760))
leaf.curve(to: NSPoint(x: 337, y: 300), controlPoint1: NSPoint(x: 800, y: 460), controlPoint2: NSPoint(x: 560, y: 270))
leaf.close()
NSGradient(starting: NSColor(calibratedRed: 0.83, green: 0.95, blue: 0.74, alpha: 1), ending: NSColor(calibratedRed: 0.37, green: 0.69, blue: 0.52, alpha: 1))!.draw(in: leaf, angle: -45)
let vein = NSBezierPath(); vein.move(to: NSPoint(x: 331, y: 270)); vein.curve(to: NSPoint(x: 650, y: 660), controlPoint1: NSPoint(x: 450, y: 410), controlPoint2: NSPoint(x: 580, y: 570)); vein.lineWidth = 20; vein.lineCapStyle = .round
NSColor(calibratedRed: 0.97, green: 0.93, blue: 0.77, alpha: 1).setStroke(); vein.stroke()
let orbit = NSBezierPath(); orbit.move(to: NSPoint(x: 175,y: 425)); orbit.curve(to: NSPoint(x: 850,y: 610), controlPoint1: NSPoint(x: 240,y: 170), controlPoint2: NSPoint(x: 900,y: 350)); orbit.lineWidth=13; orbit.lineCapStyle = .round
NSColor(calibratedRed: 0.96, green: 0.70, blue: 0.50, alpha: 1).setStroke(); orbit.stroke()
NSColor(calibratedRed: 1, green: 0.78, blue: 0.54, alpha: 1).setFill(); NSBezierPath(ovalIn: NSRect(x: 790,y: 565,width: 91,height: 91)).fill()
for (x,y,s) in [(210.0,730.0,13.0),(810.0,775.0,10.0),(735.0,230.0,9.0),(135.0,280.0,6.0),(450.0,875.0,8.0)] {
    NSColor(calibratedRed: 1, green: 0.91, blue: 0.70, alpha: 0.8).setFill(); NSBezierPath(ovalIn: NSRect(x:x,y:y,width:s,height:s)).fill()
}
NSGraphicsContext.current?.flushGraphics()
NSGraphicsContext.restoreGraphicsState()
let output = URL(fileURLWithPath: CommandLine.arguments[1])
let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, context.makeImage()!, nil)
assert(CGImageDestinationFinalize(destination))
