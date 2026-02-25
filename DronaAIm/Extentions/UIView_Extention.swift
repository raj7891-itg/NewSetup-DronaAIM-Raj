//
//  UIView_Extention.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 14/06/24.
//

import UIKit

extension UIView {

    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue

            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var layerBackgroundColor: UIColor? {
        get {
            return UIColor(cgColor: layer.backgroundColor!)
        }
        set {
            layer.backgroundColor = newValue?.cgColor
        }
    }

    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.1,
                   shadowRadius: CGFloat = 3.0) {
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    func makeRoundedAndShadowed() {
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5.0
    }

}

extension UIView {
    func addDottedBorder(cornerRadius: CGFloat = 0, borderColor: UIColor = .black, lineWidth: CGFloat = 2, dashPattern: [NSNumber] = [4, 4]) {
        let dottedBorderLayer = CAShapeLayer()
        dottedBorderLayer.strokeColor = borderColor.cgColor
        dottedBorderLayer.lineDashPattern = dashPattern
        dottedBorderLayer.fillColor = nil
        dottedBorderLayer.lineWidth = lineWidth
        dottedBorderLayer.frame = self.bounds
        dottedBorderLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        
        self.layer.addSublayer(dottedBorderLayer)
        
        // Make sure the layer resizes correctly
        self.layoutIfNeeded()
        
        if let sublayers = self.layer.sublayers, !sublayers.contains(dottedBorderLayer) {
            self.layer.addSublayer(dottedBorderLayer)
        }
    }
}
