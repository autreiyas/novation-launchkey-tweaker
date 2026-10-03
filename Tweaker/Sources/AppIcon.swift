import AppKit
import SwiftUI

// Generates the app icon programmatically at build time
// Called from AppDelegate to set the dock icon

extension AppDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.applicationIconImage = renderAppIcon(size: 512)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func renderAppIcon(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let ctx = NSGraphicsContext.current!.cgContext
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)
        let center = CGPoint(x: size / 2, y: size / 2)

        // Background: rounded rect with gradient
        let bgPath = CGPath(roundedRect: bounds.insetBy(dx: size * 0.04, dy: size * 0.04),
                           cornerWidth: size * 0.18, cornerHeight: size * 0.18,
                           transform: nil)
        ctx.addPath(bgPath)
        ctx.clip()

        // Dark gradient background
        let bgColors = [
            CGColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0),
            CGColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0),
        ]
        let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: bgColors as CFArray,
                                     locations: [0.0, 1.0])!
        ctx.drawLinearGradient(bgGradient,
                              start: CGPoint(x: 0, y: size),
                              end: CGPoint(x: size, y: 0),
                              options: [])

        // Outer encoder ring
        let outerRadius = size * 0.34
        let ringWidth = size * 0.045

        ctx.setStrokeColor(CGColor(red: 0.45, green: 0.45, blue: 0.50, alpha: 0.8))
        ctx.setLineWidth(ringWidth)
        ctx.addArc(center: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        // Inner knob body — metallic circle
        let knobRadius = size * 0.26
        let knobColors = [
            CGColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1.0),
            CGColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0),
        ]
        let knobGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: knobColors as CFArray,
                                       locations: [0.0, 1.0])!

        ctx.saveGState()
        ctx.addArc(center: center, radius: knobRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.clip()
        ctx.drawRadialGradient(knobGradient,
                               startCenter: CGPoint(x: center.x - size * 0.05, y: center.y + size * 0.05),
                               startRadius: 0,
                               endCenter: center,
                               endRadius: knobRadius,
                               options: [])
        ctx.restoreGState()

        // Knob position indicator line
        let indicatorStart = size * 0.10
        let indicatorEnd = size * 0.22
        let angle: CGFloat = -.pi / 4 // ~10 o'clock position

        ctx.setStrokeColor(CGColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0))
        ctx.setLineWidth(size * 0.025)
        ctx.setLineCap(.round)
        ctx.move(to: CGPoint(
            x: center.x + cos(angle) * indicatorStart,
            y: center.y + sin(angle) * indicatorStart
        ))
        ctx.addLine(to: CGPoint(
            x: center.x + cos(angle) * indicatorEnd,
            y: center.y + sin(angle) * indicatorEnd
        ))
        ctx.strokePath()

        // Tick marks around the ring
        let tickRadius = size * 0.40
        let tickLength = size * 0.03
        let numTicks = 11
        let startAngle: CGFloat = .pi * 0.75
        let endAngle: CGFloat = .pi * 2.25
        let angleSpan = endAngle - startAngle

        ctx.setStrokeColor(CGColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 0.6))
        ctx.setLineWidth(size * 0.012)
        ctx.setLineCap(.round)

        for i in 0..<numTicks {
            let t = CGFloat(i) / CGFloat(numTicks - 1)
            let a = startAngle + t * angleSpan
            ctx.move(to: CGPoint(
                x: center.x + cos(a) * tickRadius,
                y: center.y + sin(a) * tickRadius
            ))
            ctx.addLine(to: CGPoint(
                x: center.x + cos(a) * (tickRadius + tickLength),
                y: center.y + sin(a) * (tickRadius + tickLength)
            ))
        }
        ctx.strokePath()

        // "T" letter subtly at bottom
        let textRect = CGRect(x: center.x - size * 0.08, y: size * 0.08, width: size * 0.16, height: size * 0.14)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size * 0.09, weight: .bold),
            .foregroundColor: NSColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.7),
        ]
        let str = NSAttributedString(string: "T", attributes: attrs)
        str.draw(in: textRect)

        image.unlockFocus()
        return image
    }
}
