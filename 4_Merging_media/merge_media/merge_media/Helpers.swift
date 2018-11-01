//
//  Helpers.swift
//  merge_media
//
//  Created by dengjiangzhou on 2018/8/20.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit
import AVFoundation

//  https://developer.apple.com/documentation/coregraphics/cgaffinetransform

extension CGAffineTransform{
    
    func orientationFromTransform() -> (orientation: UIImageOrientation, isPortrait: Bool){
        var assetOrientation: UIImageOrientation = .up
        var isPortrait = false
        let tranformTuple = (self.a, self.b, self.c , self.d)
        switch tranformTuple {
        case (0, 1.0, -1.0, 0):
            assetOrientation = .right
            isPortrait = true
        case (0, -1.0, 1.0, 0):
            assetOrientation = .left
            isPortrait = true
        case (1.0, 0, 0, 1.0):
            assetOrientation = .up
        case (-1.0, 0, 0, -1.0):
            assetOrientation = .down
        default:
            break
        }
        return (assetOrientation, isPortrait)
    }

}





extension URL{
    func previewImageFromVideo() -> UIImage?{
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do{
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }catch let error{
            print("Error, previewImageFromVideo: \(String(describing: error.localizedDescription))")
            return nil
        }
        
    }
    
}



var theURL: URL {
    return { () -> URL in
        let directory = NSTemporaryDirectory()
        let dataFormatter = DateFormatter()
        dataFormatter.dateStyle = DateFormatter.Style.long
        dataFormatter.timeStyle = DateFormatter.Style.long
        let date = dataFormatter.string(from: Date())
        let path = directory.appending("merge-\(date).mov")
        return URL(fileURLWithPath: path)
        }()
}


extension CGFloat{
    func degreesToRadians()->CGFloat{
        return (CGFloat(Double.pi) * self) / 180.0
    }
    
    
}




