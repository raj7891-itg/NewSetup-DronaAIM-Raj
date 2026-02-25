//
//  LSProgress.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 17/06/24.
//

import UIKit
import MBProgressHUD

class LSProgress {
    static func show(in view: UIView, message: String? = nil) {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.label.text = message
            hud.isUserInteractionEnabled = false
        }
    }

    static func hide(from view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}
