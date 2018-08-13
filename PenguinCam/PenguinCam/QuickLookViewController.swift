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

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
