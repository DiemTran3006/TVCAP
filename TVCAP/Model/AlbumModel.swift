//
//  AlbumModel.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import Foundation
import Photos

class AlbumModel {
    let name:String
    let count:Int
    let photoAssets: PHFetchResult<PHAsset>
    
    init(name:String, count:Int, photoAssets:PHFetchResult<PHAsset>) {
        self.name = name
        self.count = count
        self.photoAssets = photoAssets
    }
}
