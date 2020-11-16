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
    func penguinPhotoBomb(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        image.draw(at: CGPoint(x: 0.0, y: 0.0))

        // Composite Penguin
     //   let number = Int.randomInt(4)
    //     let penguinName = "Penguin_\(number)"
  //      let penguinImage = UIImage(named: penguinName)
        // 莫不是 其他进程，合成不了图片
        
        
     //   let penguinImage = UIImage(named: "Penguin_3")
        var xFactor: CGFloat
        if CGFloat.randomFloat(from: 0.0, to: 1.0) >= 0.5 {
            xFactor = CGFloat.randomFloat(from: 0.0, to: 0.25)
        }
        else{
            xFactor = CGFloat.randomFloat(from: 0.75, to: 1.0)
        }
        
        var yFactor: CGFloat
        if image.size.width < image.size.height {
            yFactor = 0.0
        }
        else{
            yFactor = 0.35
        }
        
        let penguinX = image.size.width * xFactor - (penguinImage!.size.width / 2)
        let penguinY = image.size.height * 0.5 - (penguinImage!.size.height * yFactor)
        let penguinOrigin = CGPoint(x: penguinX, y: penguinY)
        penguinImage?.draw(at: penguinOrigin)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }
}



extension CGFloat{
    static func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let randomValue = CGFloat.random(in: 0...0xFFFFFFFF)
        return randomValue * (to - from ) + from
    } // 相当于 一个系数
}





extension Int{
    func randomInt(num: Int) -> Int {
        return Int(arc4random_uniform(UInt32(num) + 0))
    }
    
}
