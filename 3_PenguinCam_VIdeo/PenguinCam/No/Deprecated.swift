//
//  Deprecated.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/7/31.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import Foundation


/*
 
 
 
 // MARK: - Helpers ， getter
 func videoQueue() -> DispatchQueue{
     return DispatchQueue.global(qos: .default)
 
 }// https://github.com/apple/swift-evolution/blob/master/proposals/0088-libdispatch-for-swift3.md
 //  https://stackoverflow.com/questions/38502318/dispatch-queue-t-in-swift-3?noredirect=1&lq=1
 
 */





/*
 lazy var assetAlbum: PHAssetCollection = {
         let name = "DNG"
         var customAlbum = PHAssetCollection.findAlbum()
         if customAlbum == nil {
 
         // PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
 
         PHPhotoLibrary.shared().performChanges({
         PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
             // 这个方法， 不能单独调用，
             // 只能这么调用
             }, completionHandler: { (isV: Bool, error: Error?) in
             customAlbum = PHAssetCollection.findAlbum()
             print("Result: \(isV)")
         })
 
         // customAlbum = PHAssetCollection.findAlbum()
         // 放这里也是 崩
         }
         return customAlbum!
     }()
 
 */

// 这种方法破产， 异步调用， 他妈没获取， 就直接返回了
