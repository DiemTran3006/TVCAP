//
//  VideoPlayerViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 15/11/2023.
//

import UIKit
import AVKit
import SnapKit
import Photos

class VideoPlayerViewController: BaseViewController {
    
    @IBOutlet weak var viewVolum: UIView!
    @IBOutlet weak var volumSlider: UISlider!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var countVideo: UILabel!
    
    var videoAsset: AVAsset?
    var listMedia: [VideoModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaView.backgroundColor = .clear
        guard let asset = videoAsset else { return }
        self.buildMediaView(asset: asset)
        setUpColectionView()
        setCountVideo()
        //        viewVolum.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 24)
        viewVolum.clipsToBounds = true
        viewVolum.layer.cornerRadius = 24
        viewVolum.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        mediaView.clipsToBounds = true
        mediaView.layer.cornerRadius = 24
        mediaView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        //        let arrray = listMedia.sort { $0.isSelected && !$1.isSelected }
        //        print(listMedia)
    }
    
    // MARK: - Action
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Function
    private func setUpColectionView() {
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.register(cellType: VideoLibraryCollectionViewCell.self)
    }
    
    private func setCountVideo() {
        let count =  listMedia.count
        countVideo.text = "\(count) Video"
    }
    
    private func buildMediaView(asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        let viewController = AVPlayerViewController()
        viewController.player = player
        viewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        viewController.view.layer.masksToBounds = true
        //        viewController.view.clipsToBounds = true
        viewController.view.layer.cornerRadius = 24
        //        viewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        viewController.view.layer.borderWidth = 5
        viewController.view.layer.borderColor = UIColor(named: "TextColor")?.cgColor
        self.addChild(viewController)
        mediaView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        player.play()
    }
}

// MARK: - Extension
extension VideoPlayerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return listMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(with: VideoLibraryCollectionViewCell.self,
                                                            for: indexPath) else {
            return UICollectionViewCell()
        }
        cell.configCell(modol: listMedia[indexPath.row])
        return cell
    }
}

extension VideoPlayerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
    }
}

extension VideoPlayerViewController: UICollectionViewDelegateFlowLayout {
    
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
