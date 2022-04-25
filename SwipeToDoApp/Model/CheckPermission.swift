//
//  CheckPermission.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/22.
//

import Foundation
import Photos

// 写真アクセスのためのクラス
class CheckPermission{
    func checkAlbum(){
        PHPhotoLibrary.requestAuthorization { (status) in
            switch(status){
            case .authorized:
                print("authorized")
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
            case .limited:
                print("limited")
            @unknown default:
                break
            }
        }
    }
}
