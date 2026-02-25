//
//  LSHalfCirclularProgress.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/5/24.
//

import Foundation
import UIKit

@IBDesignable
class LSHalfCirclularProgress: UIView {
    
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Set up the track layer
        trackLayer.path = createHalfCirclePath().cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 20
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // Set up the progress layer
        progressLayer.path = createHalfCirclePath().cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.appGreen.cgColor
        progressLayer.lineWidth = 20
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
    }
    
    func showStars() {
        setupStars()
    }
    
    private func createHalfCirclePath() -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                            radius: bounds.width / 2,
                            startAngle: .pi * 3/4,
                            endAngle: .pi / 4,
                            clockwise: true)
    }
    
    private func setupStars() {
        let starLayer1 = createStarLayer()
        let starLayer2 = createStarLayer()
        let starLayer3 = createStarLayer()
        
        let starRadius = bounds.width / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Angles for the stars
        let angle1: CGFloat = .pi / 2 + .pi / 8
        let angle2: CGFloat = .pi / 2
        let angle3: CGFloat = .pi / 2 - .pi / 8
        
        // Positioning the stars along the empty arc at the bottom
        starLayer1.position = CGPoint(x: center.x + starRadius * cos(angle1), y: center.y + starRadius * sin(angle1))
        starLayer2.position = CGPoint(x: center.x + starRadius * cos(angle2), y: center.y + starRadius * sin(angle2))
        starLayer3.position = CGPoint(x: center.x + starRadius * cos(angle3), y: center.y + starRadius * sin(angle3))
        
        layer.addSublayer(starLayer1)
        layer.addSublayer(starLayer2)
        layer.addSublayer(starLayer3)
    }
    
    private func createStarLayer() -> CAShapeLayer {
        let starLayer = CAShapeLayer()
        starLayer.path = createStarPath().cgPath
        starLayer.fillColor = UIColor.appGreen.cgColor
        starLayer.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        return starLayer
    }
    
    private func createStarPath() -> UIBezierPath {
        let path = UIBezierPath()
        let starExtrusion: CGFloat = 10.0
        
        let center = CGPoint(x: 10, y: 10)
        let pointsOnStar = 5
        
        var angle: CGFloat = -CGFloat.pi / 2
        
        let angleIncrement = CGFloat.pi * 2 / CGFloat(pointsOnStar)
        let radius = starExtrusion
        let midRadius = radius / 2.5
        
        var firstPoint = true
        
        for _ in 0..<pointsOnStar {
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            let nextPoint = CGPoint(x: center.x + cos(angle + angleIncrement / 2.0) * midRadius, y: center.y + sin(angle + angleIncrement / 2.0) * midRadius)
            
            if firstPoint {
                firstPoint = false
                path.move(to: point)
            }
            
            path.addLine(to: point)
            path.addLine(to: nextPoint)
            
            angle += angleIncrement
        }
        
        path.close()
        
        return path
    }
    func setProgress(to progress: CGFloat,strokeColor: UIColor? = nil, withAnimation: Bool) {
        let clampedProgress = min(max(progress, 0), 1)
        
        // Update the stroke color if provided
        if let color = strokeColor {
            progressLayer.strokeColor = color.cgColor
        }
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 1.0
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedProgress
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = clampedProgress
            progressLayer.add(animation, forKey: "animateProgress")
        } else {
            progressLayer.strokeEnd = clampedProgress
        }
    }

}


