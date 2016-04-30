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

//MARK:- NSDate

extension NSDate {
    func toString(format: String) -> String {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = NSTimeZone.localTimeZone()
        return formatter.stringFromDate(self)
    }
}

//MARK:- AlertViewController

extension UIViewController {
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showLoader() -> UIView {
        let activityLoader: UIActivityIndicatorView = UIActivityIndicatorView()
        let container: UIView = UIView()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let origin = CGPoint(x: (self.view.frame.size.width / 2) - 50, y: (self.view.frame.size.height / 2) - 50)
        let size = CGSize(width: 100, height: 100)
        
        container.frame = CGRect(origin: origin, size: size)
        container.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        container.layer.cornerRadius = 10
        self.view.addSubview(container)
        
        activityLoader.hidesWhenStopped = true
        activityLoader.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityLoader.frame = CGRectMake(0.0, 0.0, 60.0, 60.0);
        activityLoader.center = CGPointMake(container.frame.size.width / 2, container.frame.size.height / 2);
        activityLoader.transform = CGAffineTransformMakeScale(1.3, 1.3);
        activityLoader.startAnimating()
        container.addSubview(activityLoader)
        return container
    }
}

//MARK:- Image Orientation fix

extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.Up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        if ( self.imageOrientation == UIImageOrientation.Down || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Left || self.imageOrientation == UIImageOrientation.LeftMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Right || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if ( self.imageOrientation == UIImageOrientation.UpMirrored || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if ( self.imageOrientation == UIImageOrientation.LeftMirrored || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
                                                      CGImageGetBitsPerComponent(self.CGImage), 0,
                                                      CGImageGetColorSpace(self.CGImage),
                                                      CGImageGetBitmapInfo(self.CGImage).rawValue)!;
        
        CGContextConcatCTM(ctx, transform)
        
        if ( self.imageOrientation == UIImageOrientation.Left ||
            self.imageOrientation == UIImageOrientation.LeftMirrored ||
            self.imageOrientation == UIImageOrientation.Right ||
            self.imageOrientation == UIImageOrientation.RightMirrored ) {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(CGImage: CGBitmapContextCreateImage(ctx)!)
    }
}