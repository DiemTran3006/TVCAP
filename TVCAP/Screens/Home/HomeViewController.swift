//
//  HomeViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 06/11/2023.
//

import UIKit
import Photos

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mirrorView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customColorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
    }

    // MARK: - Action
    @IBAction func actionPushVideoLibrary(_ sender: Any)  {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
            DispatchQueue.main.async {
                let vc = VideoLibraryViewController()
                self?.navigationController?.pushViewController(vc , animated: true)
            }
        }
    }
    
    @IBAction func actionPushPhotoLibrary(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
            DispatchQueue.main.async {
                let vc = PhotoViewController()
                self?.navigationController?.pushViewController(vc , animated: true)
            }
        }
    }
    
    @IBAction func actionPushBrowser(_ sender: Any) {
        let vc = BrowserViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionStartMirroring(_ sender: Any) {
        let vc = ErrorMirroringViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionPushAriplay(_ sender: Any) {
        let vc = ConnectViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionInstructButton(_ sender: Any) {
        let vc = TutorialViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionPushSettingButton(_ sender: Any) {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc , animated: true)
    }
    
    @IBAction func actionMirroringTutorialButton(_ sender: Any) {
        let vc = MirroringTutorialViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Funtion
    private func customColorView() {
        let fistColor = UIColor(red: 0.11, green: 0.353, blue: 0.98, alpha: 1)
        let lastColor = UIColor(red: 0.11, green: 0.98, blue: 0.771, alpha: 1)
        let gradient = CAGradientLayer(start: .topRight,
                                       end: .bottomLeft,
                                       colors: [fistColor.cgColor, lastColor.cgColor],
                                       type: .radial)
        gradient.frame = headerView.bounds
        headerView.layer.insertSublayer(gradient, at: 0)
    }
}


