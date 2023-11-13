//
//  IntroViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 06/11/2023.
//

import UIKit
import PhotosUI

class IntroViewController: BaseViewController {
    
    @IBOutlet weak var pageIndex1: UIView!
    @IBOutlet weak var pageIndex2: UIView!
    @IBOutlet weak var pageIndex3: UIView!
    @IBOutlet weak var introCollectionView: UICollectionView! {
        didSet {
            introCollectionView.dataSource = self
            introCollectionView.delegate = self
            introCollectionView.register(cellType: IntroCollectionViewCell.self)
        }
    }
    
    private var currentPage = 0
    
    @IBAction func handleContinue(_ sender: Any) {
        if currentPage == 2 {
            self.navigationController?.pushViewController(HomeViewController(), animated: true)
            return
        }
        self.introCollectionView.scrollToItem(at: IndexPath(row: currentPage + 1, section: 0), at: .left, animated: true)
        
        pageIndex1.backgroundColor = UIColor(hexString: "#C8CACC")
        pageIndex2.backgroundColor = UIColor(hexString: "#C8CACC")
        pageIndex3.backgroundColor = UIColor(hexString: "#C8CACC")
        
        currentPage += 1
        
        switch currentPage {
            case 0:
                pageIndex1.backgroundColor = UIColor(hexString: "#1797FF")
            case 1:
                pageIndex2.backgroundColor = UIColor(hexString: "#1797FF")
            case 2:
                pageIndex3.backgroundColor = UIColor(hexString: "#1797FF")
            default:
                break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension IntroViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
}

extension IntroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: IntroCollectionViewCell.self, for: indexPath)!
        switch indexPath.row {
            case 0:
                cell.configure(image: UIImage(named: "intro1"), title: "Mirror your screen to TV devices", subtitle: "Let’s share your favorite moments to TV!", currentIndex: indexPath.row)
            case 1:
                cell.configure(image: UIImage(named: "intro2"), title: "Help us improve app experience", subtitle: "Allow us to use your activity to provide special offers for you!", currentIndex: indexPath.row)
            case 2:
                cell.configure(image: UIImage(named: "intro3"), title: "Keep in touch", subtitle: "Allow notification to stay updated on new features and special offers!", currentIndex: indexPath.row)
            default: break
        }
        
//        cell.closureButton = { [weak self] in
//            guard let self = self else { return }
//            if indexPath.row == 2 {
//                PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
//                    DispatchQueue.main.async {
//                        self.navigationController?.pushViewController(PhotoViewController(), animated: true)
//                    }
//                }
//                return
//            }
//            self.introCollectionView.scrollToItem(at: IndexPath(row: indexPath.row + 1, section: indexPath.section), at: .left, animated: true)
//        }
        
        return cell
    }
}