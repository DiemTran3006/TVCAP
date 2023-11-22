//
//  PhotoCastViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import UIKit
import Photos

class PhotoCastViewController: UIViewController {
    
    @IBOutlet weak var modalBottomView: ModalBottomView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    @IBOutlet weak var photoAboveCollectionView: UICollectionView!
    
    var externalWindow: UIWindow?
    var externalVC: ExternalScreenViewController?
    private var currentAsset: PHAsset? = nil
    private var allPhotos: PHFetchResult<PHAsset>? = nil {
        didSet {
            guard let photoCollectionView,let photoAboveCollectionView else { return }
            photoCollectionView.reloadData()
            photoAboveCollectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(backTapped))
        
        let buttonRotate = UIBarButtonItem(image: UIImage(named: "rotateIcon"), style: .plain, target: self, action: #selector(rotateTapped))
        
        let buttonFlip = UIBarButtonItem(image: UIImage(named: "flipIcon"), style: .plain, target: self, action: #selector(flipTapped))
        
        self.navigationItem.rightBarButtonItems = [buttonFlip, buttonRotate]
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#384161")
        
        setupCollectionView()
        setupModalBottomView()
        guard let asset = self.currentAsset, let index = allPhotos?.index(of: asset) else { return }
        DispatchQueue.main.async {
            self.photoAboveCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
            self.photoCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: true)
        }
//        self.currentImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: self.currentImage.frame.size)
        registerForScreenNotifications()
        setupScreen(inDidLoad: true)
    }
    
    @objc private func backTapped() {
        UIView.animate(withDuration: 0.5) {
            self.constraint.priority = .init(250)
            self.overlayBackground.layer.opacity = 0.5
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func rotateTapped() {
//        self.currentImage.image = self.currentImage.image?.rotate(radians: .pi/2)
        let cell = photoAboveCollectionView.visibleCells.first
        if let cell = cell as? PhotoCollectionViewCell {
            cell.photo.image =  cell.photo.image?.rotate(radians: .pi/2)
        }
        self.externalVC?.photoImage.image = self.externalVC?.photoImage.image?.rotate(radians: .pi/2)
    }
    
    @objc private func flipTapped() {
        let cell = photoAboveCollectionView.visibleCells.first
        if let cell = cell as? PhotoCollectionViewCell {
            cell.photo.image =  cell.photo.image?.flipHorizontally()
        }
//        self.currentImage.image = self.currentImage.image?.flipHorizontally()
        self.externalVC?.photoImage.image = self.externalVC?.photoImage.image?.flipHorizontally()
    }
    
    public func getAllPhotos(_ list: PHFetchResult<PHAsset>) {
        self.allPhotos = list
    }
    
    public func getCurrentImage(asset: PHAsset) {
        self.currentAsset = asset
    }
    
    private func setupModalBottomView() {
        modalBottomView.layer.cornerRadius = 24
        modalBottomView.layer.masksToBounds = true
        modalBottomView.delegate = self
    }
    
    private func setupCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(cellType: PhotoCollectionViewCell.self)
        
        photoAboveCollectionView.delegate = self
        photoAboveCollectionView.dataSource = self
        photoAboveCollectionView.register(cellType: PhotoCollectionViewCell.self)
    }
    
    private func setupExternalScreen(screen: UIScreen, shouldRecurse: Bool = true, inDidLoad: Bool = false) {
        // For iOS13 find matching UIWindowScene
        var matchingWindowScene: UIWindowScene? = nil
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            for aScene in scenes {
                if let windowScene = aScene as? UIWindowScene {
                    // Look for UIWindowScene that has matching screen
                    if (windowScene.screen == screen) {
                        matchingWindowScene = windowScene
                        break
                    }
                }
            }
            if matchingWindowScene == nil {
                // UIWindowScene has not been created by iOS rendered yet
                // Lets recall self after delay of two seconds
                if true == shouldRecurse {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.setupExternalScreen(screen:screen, shouldRecurse: false)
                    }
                }
                // Dont proceed furthure in iOS13
                return
            }
        }
        
        guard externalWindow == nil else {
            return
        }
        let vc = ExternalScreenViewController()
        if inDidLoad {
            vc.currentAsset = currentAsset
        } else {
            if let cell = photoAboveCollectionView.visibleCells.first as? PhotoCollectionViewCell {
                vc.currentImage = cell.photo.image
            }
        }
        externalVC = vc
        externalWindow = UIWindow(frame: screen.bounds)
        externalWindow!.rootViewController = vc
        if #available(iOS 13.0, *) {
            // Set windowScene here, no need to set screen
            externalWindow!.windowScene = matchingWindowScene
        } else {
            // Set screen the traditional way
            externalWindow!.screen = screen
        }
        externalWindow!.isHidden = false
        
    }
    
    func registerForScreenNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoCastViewController.setupScreen), name: UIScreen.didConnectNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoCastViewController.screenDisconnected), name: UIScreen.didDisconnectNotification, object: nil)
    }
    
    @objc func setupScreen(inDidLoad: Bool = false){
        if UIScreen.screens.count > 1{
            let secondScreen = UIScreen.screens[1]
            setupExternalScreen(screen: secondScreen, shouldRecurse: true, inDidLoad: inDidLoad)
        }
    }
    
    @objc func screenDisconnected(){
        externalWindow = nil
        externalVC = nil
    }
}

extension PhotoCastViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == photoCollectionView {
            return .init(width: 40, height: 48)
        }
        return .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == photoCollectionView {
            return 8
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == photoCollectionView {
            return 8
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == photoCollectionView {
            return .init(top: 16, left: 16, bottom: 16, right: 16)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView {
            let asset = allPhotos?.object(at: indexPath.row)
            guard let asset = asset else { return }
//            self.currentImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: self.currentImage.frame.size)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            photoAboveCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            if let currentAsset,
               let index = allPhotos?.index(of: currentAsset),
               let cellCurrent = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PhotoCollectionViewCell {
                cellCurrent.setupBorder(false)
            }

            currentAsset = asset

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cell.setupBorder(true)
            }
            
            if let cellAbove = photoAboveCollectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cellAbove.photo.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: self.photoAboveCollectionView.frame.size)
            }
            
            guard let externalVC else { return }
            externalVC.photoImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: externalVC.view.frame.size)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == photoAboveCollectionView {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            let currentPage = Int(ceil(x/w))
            
            if let currentAsset,
               let index = allPhotos?.index(of: currentAsset),
               let cellCurrent = photoCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PhotoCollectionViewCell {
                cellCurrent.setupBorder(false)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == photoAboveCollectionView {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            let currentPage = max(min(Int(ceil(x/w)), (allPhotos?.count ?? .max) - 1), 0)
            photoCollectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0), at: .left, animated: true)
            
            if let cell = photoCollectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? PhotoCollectionViewCell {
                cell.setupBorder(true)
            }
            
            if currentPage != 0 {
                if let assetPrev = allPhotos?.object(at: currentPage - 1),
                   let cellPrev = photoAboveCollectionView.cellForItem(at: IndexPath(row: currentPage - 1, section: 0)) as? PhotoCollectionViewCell {
                    cellPrev.photo.fetchImage(asset: assetPrev, contentMode: .aspectFit, targetSize: photoAboveCollectionView.frame.size)
                }
            }
            
            if currentPage != (allPhotos?.count ?? .max) - 1 {
                if let assetNext = allPhotos?.object(at: currentPage + 1),
                   let cellNext = photoAboveCollectionView.cellForItem(at: IndexPath(row: currentPage + 1, section: 0)) as? PhotoCollectionViewCell {
                    cellNext.photo.fetchImage(asset: assetNext, contentMode: .aspectFit, targetSize: photoAboveCollectionView.frame.size)
                }
            }
            
            let asset = allPhotos?.object(at: currentPage)
            currentAsset = asset
            guard let externalVC, let asset else { return }
//            externalVC.currentAsset = asset
            externalVC.photoImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: externalVC.view.frame.size)
        }
        
    }
//
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }
//        cell.setupBorder(false)
//    }
}

extension PhotoCastViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = allPhotos?.object(at: indexPath.row)
        guard let asset = asset, let cell = collectionView.dequeueReusableCell(with: PhotoCollectionViewCell.self, for: indexPath) else { return PhotoCollectionViewCell()}
        if collectionView == photoCollectionView {
            cell.setupBorder(self.currentAsset == asset)
            cell.photo.fetchImage(asset: asset, contentMode: .aspectFill, targetSize: .init(width: 40, height: 48))
        } else {
            cell.removeCornerRadius()
            cell.photo.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: .init(width: collectionView.frame.width, height: collectionView.frame.height))
        }
        return cell
    }
}

extension PhotoCastViewController: ModalBottomDelegate {
    func handleAccept() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleCancel() {
        UIView.animate(withDuration: 0.5) {
            self.constraint.priority = .init(1000)
            self.overlayBackground.layer.opacity = 0
            self.view.layoutIfNeeded()
        }
    }
}
