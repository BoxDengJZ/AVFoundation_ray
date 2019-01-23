//
//  FixedBtn.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2019/1/23.
//  Copyright © 2019 dengjiangzhou. All rights reserved.
//

import UIKit

class FixedBtn: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 50, height: 50))
    }
    
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: 55, y: 0), size: CGSize(width: 100, height: 50))
    }
    
    
 

}
