//
//  PhotoViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 06/11/2023.
//

import UIKit
import Photos

protocol PhotoDelegate: AnyObject {
    func selectedAlbums(title:String, photoAssets: PHFetchResult<PHAsset>)
}

enum SelectPhoto {
    case cast
    case selectDevice
    case tutorial
}

class PhotoViewController: BaseViewController, PHPhotoLibraryChangeObserver {
    @IBOutlet weak var emptyLibraryView: EmptyLibraryView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var limitedView: UIView!
    
    private var selectPhoto: SelectPhoto = .cast
    private var allPhotos: PHFetchResult<PHAsset>? = nil {
        didSet {
            if allPhotos?.count == 0 {
                emptyLibraryView.isHidden = false
            } else {
                emptyLibraryView.isHidden = true
            }
            photoCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Recents"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Albums", style: .plain, target: self, action: #selector(albumsTapped))
        let chevronBack = UIImage(named: "chevronLeft")
        self.navigationController?.navigationBar.backIndicatorImage = chevronBack
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = chevronBack
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hexString: "#384161")]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        emptyLibraryView.delegate = self
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch authorizationStatus {
            case .authorized:
                fetchPhoto()
            case .limited:
                fetchPhoto()
                limitedView.isHidden = false
            default:
                break
        }
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(cellType: PhotoCollectionViewCell.self)
    }
    
    private func fetchPhoto() {
        let fetchOptions = PHFetchOptions()
        self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    @objc private func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func albumsTapped() {
        let vc = AlbumsViewController()
        vc.photoDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.fetchPhoto()
        }
    }
    
    private func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func handleLimited(_ sender: Any) {
        handleButtonAdd()
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        var bottomInset: CGFloat = 16
        if authorizationStatus == .limited {
            bottomInset+=50
        }
        
        return .init(top: 16, left: 16, bottom: bottomInset, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = Int((collectionView.frame.width-32-25)/3)
        return .init(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        12.5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectPhoto {
            case .cast:
                let asset = allPhotos?.object(at: indexPath.row)
                let vc = PhotoCastViewController()
                vc.getAllPhotos(self.allPhotos ?? PHFetchResult<PHAsset>())
                vc.getCurrentImage(asset: asset!)
                self.navigationController?.pushViewController(vc, animated: true)
            case .selectDevice:
                let viewController = SelectDeviceViewController()
                viewController.setDetentHeight(to: 210+24)
                
                self.present(viewController, animated: true)
            case .tutorial:
                let viewController = TutorialWithStepViewController()
                viewController.setDetentWithImageHeight(equalTo: 276)
                viewController.configureLabelStepOne(text: "Access Control Center and tap Screen Mirroring. ", textToBold: ["Control Center", "Screen Mirroring"])
                viewController.configureLabelStepTwo(text: "Choose your device then back to app.", textToBold: [])
                
                self.present(viewController, animated: true)
        }
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = allPhotos?.object(at: indexPath.row)
        let size = Int((collectionView.frame.width-32-25)/3)
         
        guard let asset = asset,let cell = collectionView.dequeueReusableCell(with: PhotoCollectionViewCell.self, for: indexPath) else { return PhotoCollectionViewCell()}
        cell.photo.fetchImage(asset: asset, contentMode: .aspectFill, targetSize: .init(width: size, height: size))
        return cell
    }
}

extension PhotoViewController: PhotoDelegate {
    func selectedAlbums(title:String, photoAssets: PHFetchResult<PHAsset>) {
        self.allPhotos = photoAssets
        self.title = title
    }
}

extension PhotoViewController: EmptyLibraryDelegate {
    func handleButtonAdd() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Create your actions - take a look at different style attributes
        let addAction = UIAlertAction(title: "Add Photos", style: .default) {[weak self] (action) in
            // observe it in the buttons block, what button has been pressed
            guard let self = self else { return }
            print("didPress Add")
            let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if authorizationStatus == .denied {
                self.gotoAppPrivacySettings()
            } else if authorizationStatus == .limited {
                DispatchQueue.main.async {
                    // Here I don't know how to display only limited photo library to users (after user has selected some photos through the limited access)
                    PHPhotoLibrary.shared().register(self)
                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                }
            }
        }
        
        let allowAction = UIAlertAction(title: "Allow Access to All Photos", style: .default) { (action) in
            print("didPress Allow")
            
            self.gotoAppPrivacySettings()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("didPress cancel")
        }
        
        // Add the actions to your actionSheet
        actionSheet.addAction(addAction)
        actionSheet.addAction(allowAction)
        actionSheet.addAction(cancelAction)
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    }
}
