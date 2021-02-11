//
//  SoundVisualizing.swift
//  Figma
//
//  Created by rs on 11/2/20.
//

import Foundation
import AVFoundation
import UIKit
import CoreGraphics

@IBDesignable class SoundWaveView: UIView {
    
    @IBInspectable var lineColor: UIColor = .red
    @IBInspectable var lineWidth: CGFloat = 2
    @IBInspectable var frequency: CGFloat = 20
    @IBInspectable var amplitude: CGFloat = 1
    
    @IBInspectable var soundSamples = [Float](repeating: 1, count: 10) {
        didSet {
            setNeedsDisplay()
            layer.setNeedsDisplay()
        }
    }

    private var drawingLayer: CAShapeLayer?
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        
        let path = UIBezierPath()
            path.move(to: .init(x: 0, y: self.bounds.height/2))

        soundSamplesToPoints().forEach(path.addLine)

        
        let drawingLayer = self.drawingLayer ?? CAShapeLayer()
            drawingLayer.contentsScale = UIScreen.main.scale
            drawingLayer.path = path.cgPath
            drawingLayer.opacity = 1
            drawingLayer.lineWidth = lineWidth
            drawingLayer.lineCap = .round
            drawingLayer.fillColor = UIColor.clear.cgColor
            drawingLayer.strokeColor = lineColor.cgColor
        
            if self.drawingLayer == nil {
                  self.drawingLayer = drawingLayer
                  layer.addSublayer(drawingLayer)
            }
    }
    
    private func soundSamplesToPoints() -> [CGPoint] {
        
        var soundValues = soundSamples.map(normalizeSoundLevel)
        
        soundValues = soundValues.map {
            CGFloat(normalize(num: Float($0), fromMin: Float(soundValues.min()!), fromMax: Float(soundValues.max()!), toMin: 0.0, toMax: Float(amplitude)))
        }
        
        var points = [CGPoint]()
        
        for degree in stride(from: 0, to: 360.0 * frequency, by: 10) {
            
            let amplitude = CGFloat(soundValues[Int(degree * (10 / (360.0 * frequency)))])
            
            let rad = CGFloat(degree) * CGFloat.pi / 180
            
            let x = CGFloat(degree) * self.bounds.width / (360 * frequency)
            let y = sin(rad) * amplitude * self.bounds.height / 2 + self.bounds.height / 2
            
            points.append(.init(x: x, y: y))
        
        }
        
        return points
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let nlevel = normalize(num: level, fromMin: -120, fromMax: 0, toMin: 0, toMax: 1)
        return CGFloat(nlevel)
    }
    
    private func normalize(num: Float, fromMin: Float, fromMax: Float, toMin: Float, toMax: Float) -> Float {
        guard num != 0 else { return 0 }
        return toMin + (num - fromMin)/(fromMax - fromMin) * (toMax - toMin)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }
}
