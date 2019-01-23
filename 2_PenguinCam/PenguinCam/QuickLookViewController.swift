//
//  QuickLookViewController.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/6/20.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit


// 看照片的 
class QuickLookViewController: UIViewController {

    
    @IBOutlet weak var quickLookImage: UIImageView!
    
    var photoImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        quickLookImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backTo) )
        quickLookImage.addGestureRecognizer(tapGesture)
        
        if photoImage != nil {
            quickLookImage.image = photoImage
        }
        
    }

    @objc
    func backTo(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    
}
