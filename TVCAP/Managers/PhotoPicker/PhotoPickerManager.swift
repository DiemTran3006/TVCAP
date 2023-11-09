//
//  PhotoPickerManager.swift
//  Document
//
//  Created by Diem Tran on 31/10/2023.
//

import UIKit
import Photos

protocol PhotoPickerProtocol: AnyObject {
    func choosePhotoSuccess(image: UIImage)
}

class PhotoPickerManager: NSObject {
    
    static var shared: PhotoPickerManager = PhotoPickerManager()
    weak var delegate: PhotoPickerProtocol?
    
    init(delegate: PhotoPickerProtocol? = nil) {
        self.delegate = delegate
    }
    
     func cameraAction(view: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        view.present(imagePickerController, animated: true)
    }
    
     func galleryAction(view: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        view.present(imagePickerController, animated: true)
    }
    // MARK: - Kiểm tra quyền truy cập ảnh
    func checkPermissions(view: UIViewController) {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in () })
        }
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorrizationHandler)
        }
    }
    func requestAuthorrizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Access is granted to use the photo gallery")
        } else {
            print("We do not have access to your photos")
        }
    }
}
// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension PhotoPickerManager: UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate {
    // Chọn hình ảnh xong
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        delegate?.choosePhotoSuccess(image: image)
        picker.dismiss(animated: true , completion: nil)
    }
}
