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


//
import RxSwift
import RxCocoa

// 看照片的 
class QuickLookViewController: UIViewController {

    
    @IBOutlet weak var quickLookImage: UIImageView!
    
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    
    var photoImage: UIImage!
    var isLivePhoto = false
    
    
    let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        quickLookImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        quickLookImage.addGestureRecognizer(tapGesture)
        
        livePhotoView.isUserInteractionEnabled = true
        let dissGesture = UITapGestureRecognizer()
        livePhotoView.addGestureRecognizer(dissGesture)
        
        tapGesture.rx.event.bind(onNext: {[weak self] (gestureRecognizer: UITapGestureRecognizer) in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposedBag )
        
        
        dissGesture.rx.event.bind(onNext: {[weak self] (gestureRecognizer: UITapGestureRecognizer) in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposedBag )
        
        let playLiveGesture = UITapGestureRecognizer()
        playLiveGesture.numberOfTouchesRequired = 2
        livePhotoView.addGestureRecognizer(playLiveGesture)
        
        playLiveGesture.rx.event.bind {[weak self] _ in
            self?.livePhotoView.startPlayback(with: .full)
        }.disposed(by: disposedBag )
        
        if photoImage != nil {
            quickLookImage.image = photoImage
            livePhotoView.isHidden = true
        }
        
        presentLivePhoto()
 
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
    
    
    
    func presentLivePhoto(){
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
}
