//
//  UIImage+Extension.swift
//  FitnessSharing
//
//  Created by Krish on 8/21/22.
//

import Foundation
import UIKit

func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint, fontSize: CGFloat) -> UIImage {
    let textColor = UIColor.black
    let textFont = UIFont(name: "Helvetica Bold", size: fontSize)!
    
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
    
    let textFontAttributes = [
        NSAttributedString.Key.font: textFont,
        NSAttributedString.Key.foregroundColor: textColor,
    ] as [NSAttributedString.Key : Any]
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
    
    let rect = CGRect(origin: point, size: image.size)
    text.draw(in: rect, withAttributes: textFontAttributes)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
