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
    var videos: [PHAsset] = []
    let tableViewCellidentifier = "cell"
    let photoPickerManager = PhotoPickerManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCollection.dataSource = self
        myCollection.delegate = self
        myCollection.register(cellType: VideoLibraryCollectionViewCell.self)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            if status == .restricted || status == .denied {
                print("Status: Restricted or Denied")
            }
            if status == .limited {
                self?.fetchVideos()
                print("Status: Limited")
            }
            if status == .authorized
            {
                self?.fetchVideos()
                print("Status: Full access")
            }
        }
    }
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
    func fetchVideos()
    {
        let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
        fetchResults.enumerateObjects({ [weak self] (object, count, stop) in
            
            self?.videos.append(object)
        })
        DispatchQueue.main.async {
            self.myCollection.reloadData()
        }
    }
    @IBAction func actionPopHomeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension VideoLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoAsset = videos[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoLibraryCollectionViewCell", for: indexPath) as? VideoLibraryCollectionViewCell else {
            return UICollectionViewCell()
        }
        PHCachingImageManager.default().requestImage(for: videoAsset,
                                                     targetSize: CGSize(width: 106, height: 106),
                                                     contentMode: .aspectFill,
                                                     options: nil) { (photo, _) in
            cell.imageView?.image = photo
        }
        return cell
    }
    
}
extension VideoLibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoAsset = videos[indexPath.row]
              
              PHCachingImageManager.default().requestAVAsset(forVideo: videoAsset, options: nil) { [weak self] (video, _, _) in
                  if let video = video
                  {
                      DispatchQueue.main.async {
                          self?.playVideo(video)
                      }
                  }
              }
    }
}
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
struct VideoModel {
    let image: UIImage?
}
