//
//  Utility.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/7/31.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit


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

        var xFactor: CGFloat = CGFloat.randomFloat(from: 0.75, to: 1.0)
        if CGFloat.randomFloat(from: 0.0, to: 1.0) >= 0.5 {
            xFactor = CGFloat.randomFloat(from: 0.0, to: 0.25)
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
}



extension CGFloat{
    static func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let randomValue: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return randomValue * (to - from ) + from
    } 
}





extension Int{
    func randomInt(num: Int) -> Int {
        return Int(arc4random_uniform(UInt32(num) + 0))
    }
    
}
