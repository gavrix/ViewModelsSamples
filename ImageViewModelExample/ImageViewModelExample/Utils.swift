//
//  Utils.swift
//  ImageViewModelExample
//
//  Created by Sergii Gavryliuk on 2016-04-07.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

extension SignalProducer {
    func ignoreErrors() -> SignalProducer<Value, NoError> {
        return self.flatMapError() {
            _ in return SignalProducer<Value, NoError>.empty
        }
    }
}


extension UIImage {
    func resizedImage(size: CGSize) -> UIImage {
        
        
        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height
        let ratio = min(horizontalRatio, verticalRatio)
        
        let newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio)
        if CGSizeEqualToSize(newSize, CGSizeZero) { return self }
        
        UIGraphicsBeginImageContext(newSize)
        defer { UIGraphicsEndImageContext() }
        
        self.drawInRect(CGRect(origin: /*CGPoint(x: (self.size.width - newSize.width) * 0.5, y: (self.size.height - newSize.height) * 0.5)*/CGPointZero,
            size: newSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    func circleMaskedImage() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(context, CGRect(origin: CGPoint.zero, size: self.size))
        CGContextClip(context)
        self.drawAtPoint(CGPoint.zero)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func roundedCorners(radius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: self.size),
            byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: radius, height: radius)).CGPath)
        CGContextClip(context)
        self.drawAtPoint(CGPoint.zero)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


