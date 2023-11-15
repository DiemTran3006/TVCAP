//
//  SelectDeviceViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import UIKit

class SelectDeviceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func setDetentHeight(to height: CGFloat) {
        let detent: UISheetPresentationController.Detent = .custom { context in
            return height
        }
        
        if let presentationController = self.presentationController as? UISheetPresentationController {
            presentationController.detents = [detent]
            presentationController.preferredCornerRadius = 24
        }
    }
    
    @IBAction func handleSelect(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
