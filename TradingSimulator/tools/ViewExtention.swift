//
//  ViewExtention.swift
//  Trading
//
//  Created by Maroun Achille on 01/05/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

extension NSView {
    var currentContext : CGContext {
        let context = NSGraphicsContext.current
        return context!.cgContext
    }
}

extension NSBezierPath {
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                fatalError("NSBezierPath Extention")
            }
        }
        
        return path
    }
}
