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
    
    public var currentAsset: PHAsset? = nil
    public var currentImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentImage {
            photoImage.image = currentImage
            self.currentImage = nil
        } else if let currentAsset {
            photoImage.fetchImage(asset: currentAsset, contentMode: .aspectFit, targetSize: self.view.frame.size)
            self.currentAsset = nil
        }
    }
}
