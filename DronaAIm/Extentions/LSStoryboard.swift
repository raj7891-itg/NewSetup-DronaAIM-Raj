//
//  LSStoryboard.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/06/24.
//

import Foundation
import UIKit

enum FTStoryboard : String {
    case launchScreen = "LaunchScreen"
    case main = "Main"
    case driver = "Driver"

    var instance: UIStoryboard {
        
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type, function: String = #function, line: Int = #line, file: String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
         
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID: String {
        
        return "\(self)"
    }
    
    static func instantiate(fromStoryboard storyboard: FTStoryboard) -> Self {
        
        return storyboard.viewController(viewControllerClass: self)
    }
}
