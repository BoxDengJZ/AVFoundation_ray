//
//  Utility.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/7/31.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit
import ImageIO

let penguinImage = UIImage(named: "Penguin_3")

extension UIImageView{
    static func imageViewWithImage(name: String) -> UIImageView{
        let imageView = UIImageView()
        let image = UIImage(named: name)
        imageView.image = image
        imageView.sizeToFit()
        imageView.isHidden = true
        return imageView
    }
    
}




extension UIImage {
    func penguinPhotoBomb() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        draw(at: CGPoint(x: 0.0, y: 0.0))

        var xFactor: CGFloat = CGFloat.random(in: 0.75..<1.0)
        if CGFloat.random(in: 0..<1.0) >= 0.5 {
            xFactor = CGFloat.random(in: 0..<0.25)
        }
        var yFactor: CGFloat = 0.35
        if size.width < size.height {
            yFactor = 0.0
        }
        
        let penguinX = size.width * xFactor - (penguinImage!.size.width / 2)
        let penguinY = size.height * 0.5 - (penguinImage!.size.height * yFactor)
        let penguinOrigin = CGPoint(x: penguinX, y: penguinY)
        penguinImage?.draw(at: penguinOrigin)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }
    
    
    
    func penguinPhotoBomb_woqu() -> UIImage {
        //  使用不当
        
        let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
        let finalImage = renderer.image { (context: UIGraphicsImageRendererContext) in
            draw(at: CGPoint(x: 0.0, y: 0.0))
            var xFactor: CGFloat = CGFloat.random(in: 0.75..<1.0)
            if CGFloat.random(in: 0..<1.0) >= 0.5 {
                xFactor = CGFloat.random(in: 0..<0.25)
            }
            var yFactor: CGFloat = 0.35
            if size.width < size.height {
                yFactor = 0.0
            }
            let penguinX = size.width * xFactor - (penguinImage!.size.width / 2)
            let penguinY = size.height * 0.5 - (penguinImage!.size.height * yFactor)
            let penguinOrigin = CGPoint(x: penguinX, y: penguinY)
            penguinImage?.draw(at: penguinOrigin)
        }
        return finalImage
    }
}







extension Int{
    func randomInt(num: Int) -> Int {
        return Int(arc4random_uniform(UInt32(num) + 0))
    }
    
}
