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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollection.dataSource = self
        myCollection.delegate = self
        myCollection.register(cellType: VideoLibraryCollectionViewCell.self)
        
        fetchVideoFromDeviceLibary()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    // MARK: - Function
    private func playVideo(_ video: AVAsset) {
        let playerItem = AVPlayerItem(asset: video)
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func fetchVideoFromDeviceLibary() {
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
    
    // MARK: - Action
    @IBAction func actionPopHomeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
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

// MARK: - UICollectionViewDelegate
extension VideoLibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        showCustomeIndicator()
        guard let videoAsset = videos[indexPath.row].asset else { return }
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestAVAsset(forVideo: videoAsset,
                                                       options: options) { [weak self] (video, _, error) in
            if let video = video {
                DispatchQueue.main.async {
                    self?.playVideo(video)
                    print(videoAsset)
                    self?.hideCustomeIndicator()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
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

