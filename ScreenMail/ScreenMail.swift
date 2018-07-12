//
//  TapAction.swift
//  Vehicles
//
//  Created by Jake B on 7/12/18.
//  Copyright © 2018 Jake B. All rights reserved.
//

import UIKit
import MessageUI

public class ScreenMail: NSObject, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate {
    
    static private let sharedInstance = ScreenMail()
    
    static private var windowView: UIWindow?
    static private var recepients: [String]?
    static private var didLongPress: Bool = false
    static private var tapGesture = UITapGestureRecognizer()
    static private var holdGesture = UILongPressGestureRecognizer()
    
    static func addGestureOnWindow(_ window: UIWindow?, taps: Int, touches: Int, toRecepients: [String]?) {
        
        holdGesture.minimumPressDuration = 1.0
        holdGesture.allowableMovement = 50
        holdGesture.numberOfTouchesRequired = touches
        
        tapGesture.numberOfTapsRequired = taps
        tapGesture.numberOfTouchesRequired = touches
        
        tapGesture.addTarget(self, action: #selector(ScreenMail.tapAction(_:)))
        holdGesture.addTarget(self, action: #selector(ScreenMail.holdAction(_:)))
        
        if let w = window {
            windowView = w
            w.addGestureRecognizer(tapGesture)
            w.addGestureRecognizer(holdGesture)
        }
        if let r = toRecepients {
            recepients = r
        }
    }
    
    @objc static private func holdAction(_ sender: UILongPressGestureRecognizer) {
        print("long press")
        if sender.state == .began {
            if didLongPress == false {
                didLongPress = true
                windowView?.rootViewController?.showToast(message: "2 finger dubtap for ScreenMail now")
            } else {
                didLongPress = false
                windowView?.rootViewController?.showToast(message: "ScreenMail disabled")
            }
        }
    }
    
    @objc static private func tapAction(_ sender: UITapGestureRecognizer) {
        print("tapped")
        if didLongPress {
            showOptions()
            didLongPress = false
        }
    }
    
    static private func showOptions() {
        let addAlert = UIAlertController(title: "Feedback Menu", message: "Select Option", preferredStyle: .actionSheet)
        addAlert.addAction(UIAlertAction(title: "Screenshot & Report", style: .default, handler: { (action) in
            ScreenMail.sendMail(imageData: getScreenshotData())
        }))
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let window = windowView {
            window.rootViewController?.present(addAlert, animated: true, completion: nil)
        }
    }
    
    static private func getScreenshotData() -> Data? {
        var screenshotImage: UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in: context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var imageData: Data?
        if let image = screenshotImage {
            imageData = UIImagePNGRepresentation(image)
        }
        return imageData
    }
    
    static private func sendMail(imageData: Data?) {
        if MFMailComposeViewController.canSendMail() {
            print("sendMail")
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = sharedInstance
            if !(recepients?.isEmpty)! {
                mail.setToRecipients(recepients)
            } else {
                mail.setToRecipients(["bova.montana@gmail.com"])
            }
            mail.setSubject("App Feedback")
            mail.setMessageBody("(description of feedback here)", isHTML: false)
            if let data = imageData {
                mail.addAttachmentData(data, mimeType: "image/png", fileName: "screenshot.png")
            }
            if let window = windowView {
                window.rootViewController?.present(mail, animated: true, completion: nil)
            } else {
                print("error: no window")
            }
        } else {
            print("cannot send mail")
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 8, y: self.view.frame.size.height-100, width: self.view.frame.size.width * 0.95, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
