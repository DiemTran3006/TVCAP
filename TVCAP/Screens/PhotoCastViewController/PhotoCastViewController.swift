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
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    var externalWindow: UIWindow?
    var externalVC: ExternalScreenViewController?
    private var currentAsset: PHAsset? = nil
    private var allPhotos: PHFetchResult<PHAsset>? = nil {
        didSet {
            guard let photoCollectionView = photoCollectionView else { return }
            photoCollectionView.reloadData()
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
        guard let asset = self.currentAsset else { return }
        self.currentImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: self.currentImage.frame.size)
        registerForScreenNotifications()
        setupScreen()
    }
    
    @objc private func backTapped() {
        UIView.animate(withDuration: 0.5) {
            self.constraint.priority = .init(250)
            self.overlayBackground.layer.opacity = 0.5
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func rotateTapped() {
        self.currentImage.image = self.currentImage.image?.rotate(radians: .pi/2)
        self.externalVC?.photoImage.image = self.externalVC?.photoImage.image?.rotate(radians: .pi/2)
    }
    
    @objc private func flipTapped() {
        self.currentImage.image = self.currentImage.image?.flipHorizontally()
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
    }
    
    private func setupExternalScreen(screen: UIScreen, shouldRecurse: Bool = true) {
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
        vc.currentAsset = self.currentAsset
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
    
    @objc func setupScreen(){
        if UIScreen.screens.count > 1{
            let secondScreen = UIScreen.screens[1]
            setupExternalScreen(screen: secondScreen, shouldRecurse: true)
        }
    }
    
    @objc func screenDisconnected(){
        externalWindow = nil
        externalVC = nil
    }
}

extension PhotoCastViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 40, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = allPhotos?.object(at: indexPath.row)
        guard let asset = asset else { return }
        self.currentImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: self.currentImage.frame.size)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        if let currentAsset,
           let index = allPhotos?.index(of: currentAsset),
           let cellCurrent = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PhotoCollectionViewCell {
            cellCurrent.setupBorder(false)
        }
        
        currentAsset = asset
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            cell.setupBorder(true)
        }
        
        guard let externalVC else { return }
        externalVC.photoImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: externalVC.view.frame.size)
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
        cell.photo.fetchImage(asset: asset, contentMode: .aspectFill, targetSize: .init(width: 40, height: 48))
        cell.setupBorder(self.currentAsset == asset)
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
