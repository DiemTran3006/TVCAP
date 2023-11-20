//
//  ExternalScreenViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 20/11/2023.
//

import UIKit
import Photos

class ExternalScreenViewController: UIViewController {
    @IBOutlet weak var photoImage: UIImageView!
    
    var currentAsset: PHAsset? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentAsset else { return }
        photoImage.fetchImage(asset: currentAsset, contentMode: .aspectFit, targetSize: self.view.frame.size)
    }
}
