//
//  StopCastViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 22/11/2023.
//

import UIKit

class StopCastViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    @IBAction func backButton(_ sender: Any) {
        let vc = VideoLibraryViewController()
//        CATransaction.begin()
//        CATransaction.setCompletionBlock {
//            self.dismiss(animated: true, completion: nil)
//        }
        self.navigationController?.popToViewController(vc, animated: true)
//        CATransaction.commit()
  }
    
    @IBAction func dissmisButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
