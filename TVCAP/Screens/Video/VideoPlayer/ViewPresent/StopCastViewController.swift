//
//  StopCastViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 22/11/2023.
//

import UIKit

protocol StopCastDelegate: AnyObject {
    func backButton()
}

class StopCastViewController: UIViewController {
    
    weak var stopCastDelegate: StopCastDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.stopCastDelegate?.backButton()
        }
    }
    
    @IBAction func dissmisButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
