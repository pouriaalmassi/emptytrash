import AppKit

let destination = CommandLine.arguments[1]
let sizes = [16, 32, 128, 256, 512]
for size in sizes {
    for scale in [1, 2] {
        let pixels = size * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        let context = NSGraphicsContext.current!.cgContext
        context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
        NSColor(calibratedRed: 0.12, green: 0.35, blue: 0.31, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: 32, y: 32, width: 960, height: 960), xRadius: 210, yRadius: 210).fill()
        NSColor(calibratedWhite: 0.96, alpha: 1).setFill()
        let bin = NSBezierPath()
        bin.move(to: NSPoint(x: 290, y: 680))
        bin.line(to: NSPoint(x: 734, y: 680))
        bin.line(to: NSPoint(x: 687, y: 252))
        bin.curve(to: NSPoint(x: 637, y: 210), controlPoint1: NSPoint(x: 684, y: 225), controlPoint2: NSPoint(x: 664, y: 210))
        bin.line(to: NSPoint(x: 387, y: 210))
        bin.curve(to: NSPoint(x: 337, y: 252), controlPoint1: NSPoint(x: 360, y: 210), controlPoint2: NSPoint(x: 340, y: 225))
        bin.close(); bin.fill()
        NSBezierPath(roundedRect: NSRect(x: 260, y: 715, width: 504, height: 60), xRadius: 25, yRadius: 25).fill()
        NSBezierPath(roundedRect: NSRect(x: 414, y: 795, width: 196, height: 48), xRadius: 20, yRadius: 20).fill()
        NSColor(calibratedRed: 0.12, green: 0.35, blue: 0.31, alpha: 1).setFill()
        for x in [420, 500, 580] {
            NSBezierPath(roundedRect: NSRect(x: x, y: 300, width: 24, height: 310), xRadius: 12, yRadius: 12).fill()
        }
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        try bitmap.representation(using: .png, properties: [:])!.write(to:
            URL(fileURLWithPath: destination).appendingPathComponent("icon_\(size)x\(size)\(suffix).png"))
    }
}
