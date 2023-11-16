//
//  SettingViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 07/11/2023.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var bannerImage: UIView!
    @IBOutlet weak var btnSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
   // MARK: - Action
    @IBAction func actionSwitch(_ sender: Any) {
        if btnSwitch.isOn {
            bannerImage.isHidden = true
        } else {
            bannerImage.isHidden = false
        }
    }
    
    @IBAction func actionPushTutorial(_ sender: Any) {
        let vc = TutorialViewController(nibName: "TutorialViewController", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionPopHomeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

