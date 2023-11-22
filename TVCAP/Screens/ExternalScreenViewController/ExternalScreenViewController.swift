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
    
    var currentImage: UIImage? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentImage else { return }
        photoImage.image = currentImage
    }
}
