//
//  LSSupportViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/16/24.
//

import UIKit
import MessageUI

class LSSupportViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Support"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func supportAction(_ sender: Any) {
        let emailVC = LSMailComposerViewController.instantiate(fromStoryboard: .driver)
        self.present(emailVC, animated: true)
    }
    
    @IBAction func mailAction(_ sender: Any) {
        //+1(817)-865-5261
        let busPhone = "+18178655261"
        if let url = URL(string: "tel://\(busPhone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func webAction(_ sender: Any) {
        let urlString = "https://dronaaim.ai/"
        if var url = URL(string: urlString) {
                   
                   // Ensure URL has a scheme
                   if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
                       url = URL(string: "https://\(urlString)")!
                   }
                   
                   // Open in browser
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
               }
    }
    
    func sendEmail() {
           guard MFMailComposeViewController.canSendMail() else {
               // Show an alert to the user if mail is not set up
               UIAlertController.showError(on: self, message: "Your device is not currently configured to send mail.")
               return
           }

           let mailComposeVC = MFMailComposeViewController()
           mailComposeVC.mailComposeDelegate = self

           // Set email fields
           mailComposeVC.setToRecipients(["telematics@dronaaim.ai"])
           mailComposeVC.setCcRecipients(["sivat443@gmail.com"])
           mailComposeVC.setSubject("Subject Here")
           mailComposeVC.setMessageBody("Email body here", isHTML: false)

           present(mailComposeVC, animated: true, completion: nil)
       }
}

// MARK: - MFMailComposeViewControllerDelegate
extension LSSupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
