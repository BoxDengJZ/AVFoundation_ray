//
//  PhotoCaptureDelegate.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2019/1/23.
//  Copyright © 2019 dengjiangzhou. All rights reserved.
//

import UIKit
import Photos


class PhotoCaptureDelegate: NSObject {
    
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    private var photoData: Data?
    private var livePhotoCompanionMovieURL: URL?
    private let completionHandler: (UIImage) -> Void
    
    init(with requestedPhotoSettings: AVCapturePhotoSettings, completionHandler: @escaping (UIImage) -> Void){
        self.requestedPhotoSettings = requestedPhotoSettings
        self.completionHandler = completionHandler
    }
    
    private func didFinish() {
        if let livePhotoCompanionMoviePath = livePhotoCompanionMovieURL?.path {
            if FileManager.default.fileExists(atPath: livePhotoCompanionMoviePath) {
                do {
                    try FileManager.default.removeItem(atPath: livePhotoCompanionMoviePath)
                } catch {
                    print("Could not remove file at url: \(livePhotoCompanionMoviePath)")
                }
            }
        }
    }
    
    
}



extension PhotoCaptureDelegate: AVCapturePhotoCaptureDelegate{
    /// - Tag: DidFinishProcessingPhoto
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        //  CMSampleBuffer: Core Media
        //  CVImageBuffer: Core Video
        
        if let imageData = photo.fileDataRepresentation(){
            
            // 这里是 Live Photo , 实况照片用的，
            photoData = photo.fileDataRepresentation()
            
            // 下面是 still image, 静态照片
            
            // 不同的逻辑
            
            
            // If the sample buffer contains data , it is then converted into a JPEG representaiton.
            
            let image = UIImage(data: imageData)
            // Then an UIImage is created , using the JPEG data
            
            // and it compiles it with the `penguinPhotoBomb`
            
            let photoBomb = image?.penguinPhotoBomb(image: image!)
            self.savePhotoToLibrary(image: photoBomb!)
            // Lastly , the composited photo is saved to the shared photo library.
        }
        else{
            print("Error capturing photo: \(String(describing: error?.localizedDescription))")
        }
    }
    
    
    // https://stackoverflow.com/questions/46478262/taking-photo-with-custom-camera-ios-11-0-swift-4-update-error
    
    
    
    // https://stackoverflow.com/questions/43059282/using-avcapturephotooutput-in-ios10-nsgenericexception
    

    
    
    /// - Tag: DidFinishProcessingLive
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if error != nil {
            print("Error processing Live Photo companion movie: \(String(describing: error))")
            return
        }
        livePhotoCompanionMovieURL = outputFileURL
    }
    
    /// - Tag: DidFinishCapture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            didFinish()
            return
        }
        
        guard let photoData = photoData else {
            print("No photo data resource")
            didFinish()
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    
                    //  在这里， 把实况照片的 photo 与 video , 写进去
                    
                    // 先写 photo
                    
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                    
                    
                    // 再写，成对的 video
                    
                    if let livePhotoCompanionMovieURL = self.livePhotoCompanionMovieURL {
                        
                        // 把这里的代码去掉，就是普通照片了，
                        
                        //  官方相册里， 不带实况两个字的
                        
                        let livePhotoCompanionMovieFileOptions = PHAssetResourceCreationOptions()
                        livePhotoCompanionMovieFileOptions.shouldMoveFile = true
                        creationRequest.addResource(with: .pairedVideo,
                                                    fileURL: livePhotoCompanionMovieURL,
                                                    options: livePhotoCompanionMovieFileOptions)
                    }
                    
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                    
                    self.didFinish()
                }
                )
            } else {
                self.didFinish()
            }
        }
    }
    
}




extension PhotoCaptureDelegate{

    // MARK: - Helpers
    func savePhotoToLibrary(image: UIImage) {
        let photoLibrary = PHPhotoLibrary.shared()
        
        let name = "DNG"
        var customAlbum = PHAssetCollection.findAlbum()
        if customAlbum == nil {
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                
            }, completionHandler: { (isV: Bool, error: Error?) in
                customAlbum = PHAssetCollection.findAlbum()
                
                print("Result: \(isV)")
                self.savePhotoToLibrary(image: image)
                
                return
            })
        }
        else{
            photoLibrary.performChanges({
                let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetImage = result.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: customAlbum!)
                albumChangeRequest!.addAssets([assetImage!] as NSArray)
                
            }, completionHandler: { isSuccess, error in
                if isSuccess {
                    // Set thumbnail
                    self.completionHandler(image)
                }
                else{
                    print("Error writing to photo library:  \(error!.localizedDescription)")
                }
            })// photoLibrary.performChanges
        }
    }


}
