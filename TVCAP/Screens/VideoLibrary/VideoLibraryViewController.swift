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
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            if status == .restricted || status == .denied {
                print("Status: Restricted or Denied")
            }
            if status == .limited {
                self?.fetchVideos()
                print("Status: Limited")
            }
            if status == .authorized {
                self?.fetchVideos()
                print("Status: Full access")
            }
        }
    }
    
    // MARK: - Function
    private func playVideo(_ video: AVAsset)
    {
        let playerItem = AVPlayerItem(asset: video)
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    func fetchVideos() {
        showCustomeIndicator()
        let imageManager = PHImageManager.default()
        let imageRequestOptions = PHImageRequestOptions()
        let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
        
        fetchResults.enumerateObjects({ [weak self] (phAsset, count, stop) in
            var video = VideoModel()
            imageManager.requestImage(for: phAsset,
                                      targetSize: CGSize(width: 200, height: 200),
                                      contentMode: .default,
                                      options: imageRequestOptions) { (uiImage, _) in
                video.thumbnailImage = uiImage!
                video.asset = phAsset
            }
            self?.videos.append(video)
        })
        
        DispatchQueue.main.async {
            self.myCollection.reloadData()
            self.hideCustomeIndicator()
        }
    }
    
    // MARK: - Action
    @IBAction func actionPopHomeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension VideoLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoAsset = videos[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoLibraryCollectionViewCell",
                                                            for: indexPath) as? VideoLibraryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configCell(modol: videoAsset)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension VideoLibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let videoAsset = videos[indexPath.row].asset else { return }
        
        PHCachingImageManager.default().requestAVAsset(forVideo: videoAsset, options: nil) { [weak self] (video, _, _) in
            if let video = video {
                DispatchQueue.main.async {
                    let vc = VideoCastViewController(nibName: "VideoCastViewController", bundle: nil)
        
                    self?.navigationController?.pushViewController(vc , animated: true)
                    self?.playVideo(video)
                }
            }
        }
    }
}// MARK: - UICollectionViewDelegateFlowLayout
extension VideoLibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (UIScreen.main.bounds.size.width - 56 ) / 3
        return CGSize(width: width, height: width )
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

// MARK: - Model
struct VideoModel {
    var thumbnailImage: UIImage?
    var asset: PHAsset?
}
