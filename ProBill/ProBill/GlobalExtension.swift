//
//  GlobalExtension.swift
//  ProBill
//
//  Created by Ysée Monnier on 30/04/16.
//  Copyright © 2016 MONNIER Ysee. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Color

struct PBColor {
    static let yellow = UIColor(red: (255/255), green: (229/255), blue: (51/255), alpha: 1.0)
    static let lightYellow = UIColor(red: (255/255), green: (247/255), blue: (153/255), alpha: 1.0)
    static let blue = UIColor(red: (79/255), green: (172/255), blue: (255/255), alpha: 1.0)
    static let orange = UIColor(red: (222/255), green: (138/255), blue: (0/255), alpha: 1.0)
    static let gray = UIColor(red: (74/255), green: (74/255), blue: (74/255), alpha: 1.0)
}

//MAK: - UIColor

extension UIColor {
    public class func random() -> UIColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
    }
}

//MARK: - NSDate

extension Date {
    func toString(_ format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter.string(from: self)
    }
}

//MARK:- AlertViewController

extension UIViewController {
    func showSimpleAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoader() -> UIView {
        let activityLoader: UIActivityIndicatorView = UIActivityIndicatorView()
        let container: UIView = UIView()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let origin = CGPoint(x: (self.view.frame.size.width / 2) - 50, y: (self.view.frame.size.height / 2) - 50)
        let size = CGSize(width: 100, height: 100)
        
        container.frame = CGRect(origin: origin, size: size)
        container.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        container.layer.cornerRadius = 10
        self.view.addSubview(container)
        
        activityLoader.hidesWhenStopped = true
        activityLoader.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityLoader.frame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0);
        activityLoader.center = CGPoint(x: container.frame.size.width / 2, y: container.frame.size.height / 2);
        activityLoader.transform = CGAffineTransform(scaleX: 1.3, y: 1.3);
        activityLoader.startAnimating()
        container.addSubview(activityLoader)
        return container
    }
}

//MARK:- Image Orientation fix

extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if ( self.imageOrientation == UIImageOrientation.down || self.imageOrientation == UIImageOrientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        }
        
        if ( self.imageOrientation == UIImageOrientation.left || self.imageOrientation == UIImageOrientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }
        
        if ( self.imageOrientation == UIImageOrientation.right || self.imageOrientation == UIImageOrientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
        }
        
        if ( self.imageOrientation == UIImageOrientation.upMirrored || self.imageOrientation == UIImageOrientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if ( self.imageOrientation == UIImageOrientation.leftMirrored || self.imageOrientation == UIImageOrientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                                      bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                                      space: self.cgImage!.colorSpace!,
                                                      bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;
        
        ctx.concatenate(transform)
        
        if ( self.imageOrientation == UIImageOrientation.left ||
            self.imageOrientation == UIImageOrientation.leftMirrored ||
            self.imageOrientation == UIImageOrientation.right ||
            self.imageOrientation == UIImageOrientation.rightMirrored ) {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
}
