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
    func showError(error: String)
}

class PhotoPickerManager: NSObject {
    
    static var shared: PhotoPickerManager = PhotoPickerManager()
    weak var delegate: PhotoPickerProtocol?
    
    init(delegate: PhotoPickerProtocol? = nil) {
        self.delegate = delegate
    }
    
    public func fetchVideoFromDeviceLibary(completion: @escaping ([VideoModel]) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .limited || status == .authorized else {
                self.delegate?.showError(error: "Status: Restricted or Denied")
                return
            }
            self.fetchVideos(completion: completion)
        }
    }
    
    public func cameraAction(view: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        view.present(imagePickerController, animated: true)
    }
    
    public func galleryAction(view: UIViewController) {
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
    
    private func requestAuthorrizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Access is granted to use the photo gallery")
        } else {
            print("We do not have access to your photos")
        }
    }
    
    private func fetchVideos(completion: ([VideoModel]) -> ()) {
        var listVideo: [VideoModel] = []
        let imageManager = PHImageManager.default()
        let imageRequestOptions = PHImageRequestOptions()
        let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
        
        fetchResults.enumerateObjects { phAsset, _, _ in
            var video = VideoModel()
            imageManager.requestImage(for: phAsset,
                                      targetSize: CGSize(width: 400, height: 400),
                                      contentMode: .default,
                                      options: imageRequestOptions) { (uiImage, _) in
                video.thumbnailImage = uiImage!
                video.asset = phAsset
            }
            listVideo.append(video)
        }
        completion(listVideo)
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

class VideoModel {
    var thumbnailImage: UIImage?
    var asset: PHAsset?
    var isSelected: Bool? = false
    }

