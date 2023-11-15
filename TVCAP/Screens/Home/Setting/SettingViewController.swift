//
//  SettingViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 07/11/2023.
//

import UIKit

class SettingViewController: UIViewController {
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
// MARK: - Action
    @IBAction func actionPopHomeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

