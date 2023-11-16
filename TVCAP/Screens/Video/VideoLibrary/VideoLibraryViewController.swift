//
//  VideoLibraryViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 08/11/2023.
//

import UIKit
import Photos
import AVKit

class VideoLibraryViewController: UIViewController {
    
    @IBOutlet weak var myCollection: UICollectionView!
    
    var videos: [VideoModel] = []
    let photoPickerManager = PhotoPickerManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollection()
        fetchVideoFromDeviceLibary()
    }
    
    // MARK: - Action
    @IBAction func actionPopHomeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Funcsion
    private func setUpCollection() {
        myCollection.dataSource = self
        myCollection.delegate = self
        myCollection.register(cellType: VideoLibraryCollectionViewCell.self)
    }
    
    public func fetchVideoFromDeviceLibary() {
        showCustomeIndicator()
        photoPickerManager.fetchVideoFromDeviceLibary { [weak self] videos in
            guard let self = self else { return }
            self.videos = videos
            self.hideCustomeIndicator()
            DispatchQueue.main.async {
                self.myCollection.reloadData()
                
            }
        }
    }
}

// MARK: - Extension
extension VideoLibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(with: VideoLibraryCollectionViewCell.self,
                                                            for: indexPath) else {
            return UICollectionViewCell()
        }
        cell.configCell(modol: videos[indexPath.row])
        return cell
    }
}

extension VideoLibraryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        showCustomeIndicator()
        videos.forEach { item in
            item.isSelected = false
        }
        let currentVideo = videos[indexPath.row]
        currentVideo.isSelected = true
        guard let videoAsset = videos[indexPath.row].asset else { return }
        navigateToDetailVideo(videoAsset: videoAsset)
    }
    
    private func navigateToDetailVideo(videoAsset: PHAsset) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestAVAsset(forVideo: videoAsset,
                                                       options: options) { [weak self] (asset, _, error) in
            guard let self = self, let asset = asset else { return }
            DispatchQueue.main.async {
                self.hideCustomeIndicator()
                let vc = VideoPlayerViewController()
                vc.videoAsset = asset
                vc.listMedia = self.videos
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension VideoLibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 56) / 3
        return CGSize(width: width, height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

