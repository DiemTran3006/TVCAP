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
    let viewController = AVPlayerViewController()

    var listMedia: [VideoModel] = []
    private var selectedIndexPath: IndexPath?
    private var isProgress: Bool = false
    private var player: AVPlayer? = nil
    private var timeObserver: Any? = nil
    
    let stackView = UIStackView()
    let btn15SecBack = UIButton()
    let playPauseButton = UIButton()
    let btn15SecNext = UIButton()
    let progressView = UIProgressView()
    let timeLabelLeft = UILabel()
    let timelabelRight = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.isHidden = true
        setUpPlatVideo()
        setUpColectionView()
        setCountVideo()
        CustomPlayVideo()
        updatePlayerTime()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        boderConnerRadius()

    }
    
    // MARK: - Action
    @IBAction func actionBack(_ sender: Any) {
        let vc = StopCastViewController(nibName: "StopCastViewController", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionVolumSlider(_ sender: Any) {
        player?.volume = volumSlider.value
    }
    
    // MARK: - Function
    private func setUpPlatVideo() {
        guard let asset = videoAsset else { return }
        self.buildMediaView(asset: asset)
    }
    
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
        viewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        viewController.showsPlaybackControls = false
        
        viewController.view.clipsToBounds = true
        viewController.view.layer.cornerRadius = 22
        viewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        mediaView.backgroundColor = UIColor(named: "TextColor")
        viewController.view.addTapGesture(action: onPlayVideo)
        self.addChild(viewController)
        mediaView.addSubview(viewController.view)
        
        viewController.view.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
            make.bottom.trailing.equalToSuperview().offset(-5)
        }
        self.settingPlayer(asset: asset)
    }
    
    private func settingPlayer(asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        viewController.player = player
        player?.play()
        self.setObserverToPlayer()
    }
    
    private func CustomPlayVideo() {
        
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.spacing = 41
        mediaView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(mediaView)
            make.centerY.equalTo(mediaView)
            make.height.equalTo(64)
        }
        
        btn15SecBack.setImage(UIImage(named: "icon.back.playvideo"), for: .normal)
        btn15SecBack.isUserInteractionEnabled = true
        btn15SecBack.addTarget(self, action: #selector(onTap15SecBack),
                               for: .touchUpInside)
        stackView.addArrangedSubview(btn15SecBack)
        
        btn15SecBack.snp.makeConstraints { make in
            make.width.equalTo(44)
        }
        
        playPauseButton.setImage(UIImage(named: "icon.playvideo"), for: .normal)
        playPauseButton.isUserInteractionEnabled = true
        playPauseButton.addTarget(self, action: #selector(onTapPlayPause),
                                  for: .touchUpInside)
        stackView.addArrangedSubview(playPauseButton)
        
        playPauseButton.snp.makeConstraints { make in
            make.width.equalTo(64)
        }
        
        btn15SecNext.setImage(UIImage(named: "icon.next.playvideo"), for: .normal)
        btn15SecNext.isUserInteractionEnabled = true
        btn15SecNext.addTarget(self, action: #selector(onTap15SecNext),
                               for: .touchUpInside)
        stackView.addArrangedSubview(btn15SecNext)
        
        btn15SecNext.snp.makeConstraints { make in
            make.width.equalTo(44)
        }
        
        progressView.progressTintColor = UIColor(hexString: "#1C7CFA")
        progressView.setProgress(0.2, animated: true)
        progressView.addGestureRecognizer(UIGestureRecognizer(target: self,
                                                              action: #selector(isProgressAction)))
        mediaView.addSubview(progressView)
        
        progressView.snp.makeConstraints { make in
            make.left.equalTo(mediaView).offset(0)
            make.right.equalTo(mediaView).offset(0)
            make.bottom.equalTo(mediaView).offset(-5)
        }
        
        timeLabelLeft.textColor = .white
        timeLabelLeft.font = .boldSystemFont(ofSize: 10)
        mediaView.addSubview(timeLabelLeft)
        
        timeLabelLeft.snp.makeConstraints { make in
            make.left.equalTo(mediaView).offset(15)
            make.bottom.equalTo(progressView).offset(-10)
        }
        
        timelabelRight.textColor = .white
        timelabelRight.font = .boldSystemFont(ofSize: 10)
        mediaView.addSubview(timelabelRight)
        
        timelabelRight.snp.makeConstraints { make in
            make.right.equalTo(mediaView).offset(-15)
            make.bottom.equalTo(progressView).offset(-10)
        }
    }
    
    private func boderConnerRadius() {
        viewVolum.clipsToBounds = true
        viewVolum.layer.cornerRadius = 24
        viewVolum.layer.maskedCorners = [.layerMinXMaxYCorner,
                                         .layerMaxXMaxYCorner]
        mediaView.clipsToBounds = true
        mediaView.layer.cornerRadius = 24
        mediaView.layer.maskedCorners = [.layerMaxXMinYCorner,
                                         .layerMinXMinYCorner]
    }
    
    private func setObserverToPlayer() {
        let interval = CMTime(seconds: 0.3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval,
                                                       queue: DispatchQueue.main,
                                                       using: { elapsed in
            self.updatePlayerTime()
        })
    }
    
    private func updatePlayerTime() {
        guard let currentTime = self.player?.currentTime() else { return }
        guard let duration = self.player?.currentItem?.duration else { return }
        let currentTimeInSecond = CMTimeGetSeconds(currentTime)
        let durationTimeInSecond = CMTimeGetSeconds(duration)
        if self.isProgress == false {
            self.progressView.progress = Float(currentTimeInSecond/durationTimeInSecond)
        }
        let value = Float64(self.progressView.progress) * CMTimeGetSeconds(duration)
        var mins =  (value / 60).truncatingRemainder(dividingBy: 60)
        var secs = value.truncatingRemainder(dividingBy: 60)
        var timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard  let minsStr = timeformatter.string(from: NSNumber(value: mins)),
               let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return
        }
        self.timeLabelLeft.text = "\(minsStr):\(secsStr)"
        mins = (durationTimeInSecond / 60).truncatingRemainder(dividingBy: 60)
        secs = durationTimeInSecond.truncatingRemainder(dividingBy: 60)
        timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard  let minsStr = timeformatter.string(from: NSNumber(value: mins)),
               let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return
        }
        self.timelabelRight.text = "\(minsStr):\(secsStr)"
    }
    
    @objc private func onTap15SecNext() {
        guard let currentTime = self.player?.currentTime() else { return }
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: 15)
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        self.player?.seek(to: seekTime, completionHandler: { completed in
        })
    }
    
    @objc private func onTap15SecBack() {
        guard let currentTime = self.player?.currentTime() else { return }
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: -15)
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        self.player?.seek(to: seekTime, completionHandler: { completed in
            
        })
    }
    
    @objc private func onTapPlayPause() {
        if self.player?.timeControlStatus == .playing {
            self.player?.pause()
            playPauseButton.setImage(UIImage(named: "icon.stopvideo"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(named: "icon.playvideo"), for: .normal)
            self.player?.play()
        }
    }

    @objc private func onPlayVideo() {
        if self.stackView.isHidden {
            self.stackView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.stackView.isHidden = true
            }
        }
    }
    
    @objc private func isProgressAction() {
        self.isProgress = true
        guard let duration = self.player?.currentItem?.duration else { return }
        let progrees = Float64(progressView.progress) * CMTimeGetSeconds(duration)
        
        if progrees.isNaN == false {
            let seekTime = CMTime(value: CMTimeValue(progrees), timescale: 1)
            self.player?.seek(to: seekTime, completionHandler: { completed in
                if completed {
                    self.isProgress = false
                }
            })
        }
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
        self.showCustomeIndicator()
        let currrentItem = listMedia[indexPath.row]
        listMedia.forEach { $0.isSelected = false }
        listMedia[indexPath.row].isSelected = true
        
        listMedia.remove(at: indexPath.row)
        listMedia.insert(currrentItem, at: 0)
        myCollectionView.reloadData()
        guard let cellVideo = currrentItem.asset else { return }
        navigateToDetailVideo(cellVideo: cellVideo)
    }
    
    func navigateToDetailVideo(cellVideo: PHAsset) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestAVAsset(forVideo: cellVideo,
                                                       options: options) { [weak self] asset, _, _ in
            guard let self, let videoAsset = asset else { return }
            self.videoAsset = videoAsset
            self.settingPlayer(asset: videoAsset)
            self.hideCustomeIndicator()
        }
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
