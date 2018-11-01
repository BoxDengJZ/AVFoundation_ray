//
//  Album.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/7/31.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import Foundation

import Photos

// http://www.hangge.com/blog/cache/detail_1132.html
extension PHAssetCollection{
    static func findAlbum() -> PHAssetCollection?{
        let name = "DNG"
        // 两个地方， 要保持同步， 烦
        var customAlbum: PHAssetCollection?
        let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        albumList.enumerateObjects({ (album: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if name == album.localizedTitle{
                customAlbum = album
                stop.initialize(to: true)
            }
        })
        return customAlbum
    }


}

