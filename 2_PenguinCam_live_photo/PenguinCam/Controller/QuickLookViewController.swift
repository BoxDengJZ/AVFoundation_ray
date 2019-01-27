//
//  QuickLookViewController.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/6/20.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

// 看照片的 
class QuickLookViewController: UIViewController {

    
    @IBOutlet weak var quickLookImage: UIImageView!
    
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    
    var photoImage: UIImage!
    var isLivePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        quickLookImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backTo) )
        quickLookImage.addGestureRecognizer(tapGesture)
        
        
        livePhotoView.isUserInteractionEnabled = true
        let dissLiveGesture = UITapGestureRecognizer(target: self, action: #selector(backTo) )
        livePhotoView.addGestureRecognizer(dissLiveGesture)
        
        let playLiveGesture = UITapGestureRecognizer(target: self, action: #selector(playAlive) )
        playLiveGesture.numberOfTouchesRequired = 2
        livePhotoView.addGestureRecognizer(playLiveGesture)
        
        
        
        if photoImage != nil {
            quickLookImage.image = photoImage
            livePhotoView.isHidden = true
        }
        
        
        guard isLivePhoto else{
            return
        }
        let asset = fetchLatestPhotos()
        
        
        
        // Request the live photo for the asset from the default PHImageManager.
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: livePhotoView.bounds.size, contentMode: .aspectFit, options: nil, resultHandler: { livePhoto, info in
            // If successful, show the live photo view and display the live photo.
            guard let livePhoto = livePhoto else { return }
            
            // Now that we have the Live Photo, show it.
            self.quickLookImage.isHidden = true
            self.livePhotoView.isHidden = false
            self.livePhotoView.livePhoto = livePhoto

            self.livePhotoView.startPlayback(with: .hint)
            
        })
 
    }

    
    @objc
    func backTo(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func playAlive(){
        
        self.livePhotoView.startPlayback(with: .full)
    }
    
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    
    
    
    
    
    func fetchLatestPhotos() -> PHAsset {
        
        // Create fetch options.
        let options = PHFetchOptions()
        
        // If count limit is specified.
        options.fetchLimit = 1
        
        // Add sortDescriptor so the lastest photos will be returned.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        
        // Fetch the photos.
        return PHAsset.fetchAssets(with: .image, options: options).lastObject!
        
    }
    
}
