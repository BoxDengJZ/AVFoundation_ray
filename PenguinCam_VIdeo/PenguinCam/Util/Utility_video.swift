//
//  Utility_video.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/8/1.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import Foundation

enum CaptureMode: Int{
    case photo = 0, movie
    
}


extension URL{
    static var tempURL: URL?{
        get{
            let directory = NSTemporaryDirectory()
            if directory != ""{
                let path = directory.appending("penCam.mov")
                return URL(fileURLWithPath: path)
            }
            return nil
        }
        
    }
    
    
}




extension UInt{
    func formattedCurrentTime() -> String{
        let hours = self/3600
        print("hours : \(hours)")
        let minutes = (self/60)%60
        let seconds = self % 60
        return String(format: "\(hours.formatTwo()): \(minutes.formatTwo()): \(seconds.formatTwo())")
    }
    
    
    func formatTwo() -> String{
        return String(format: "%02d", self)
    }
    // http://swifter.tips/output-format/
    
}




