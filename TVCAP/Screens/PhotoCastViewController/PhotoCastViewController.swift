//
//  PhotoCastViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import UIKit
import Photos

class PhotoCastViewController: UIViewController {

    @IBOutlet weak var stopCastView: StopCastView! {
        didSet {
            stopCastView.layer.cornerRadius = 24
            stopCastView.layer.masksToBounds = true
            stopCastView.delegate = self
        }
    }
    @IBOutlet weak var photoCollectionView: UICollectionView! {
        didSet {
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
            photoCollectionView.register(cellType: PhotoCollectionViewCell.self)
        }
    }
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var overlayBackground: UIView!
    
    private var currentAsset: PHAsset? = nil
    private var allPhotos: PHFetchResult<PHAsset>? = nil {
        didSet {
            guard let photoCollectionView = photoCollectionView else { return }
            photoCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var constraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(backTapped))
        
        let buttonRotate = UIBarButtonItem(image: UIImage(named: "rotateIcon"), style: .plain, target: self, action: #selector(rotateTapped))
        
        let buttonFlip = UIBarButtonItem(image: UIImage(named: "flipIcon"), style: .plain, target: self, action: #selector(flipTapped))
        
        self.navigationItem.rightBarButtonItems = [buttonFlip, buttonRotate]
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#384161")
        
        guard let asset = self.currentAsset else { return }
        self.currentImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: self.currentImage.frame.size)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    @objc func backTapped() {
        
//        self.navigationController?.popViewController(animated: true)
        UIView.animate(withDuration: 0.5) {
            self.constraint.priority = .init(250)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.overlayBackground.layer.opacity = 0.5
        }
    }
    
    @objc func rotateTapped() {
        self.currentImage.image = self.currentImage.image?.rotate(radians: .pi/2)
    }
    
    @objc func flipTapped() {
        self.currentImage.image = self.currentImage.image?.flipHorizontally()
    }
    
    func getAllPhotos(_ list: PHFetchResult<PHAsset>) {
        self.allPhotos = list
    }
    
    func getCurrentImage(asset: PHAsset) {
        self.currentAsset = asset
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
        self.currentImage.fetchImage(asset: asset!, contentMode: .aspectFit, targetSize: self.currentImage.frame.size)
    }
}

extension PhotoCastViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = allPhotos?.object(at: indexPath.row)
        let cell = collectionView.dequeueReusableCell(with: PhotoCollectionViewCell.self, for: indexPath)!
        cell.photo.fetchImage(asset: asset!, contentMode: .aspectFill, targetSize: .init(width: 40, height: 48))
        return cell
    }
}

extension PhotoCastViewController: StopCastDelegate {
    func handleStopCast() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleCancel() {
        UIView.animate(withDuration: 0.5) {
            self.constraint.priority = .init(1000)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.overlayBackground.layer.opacity = 0
        }
    }
}