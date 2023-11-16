//
//  StartMirroringViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 07/11/2023.
//

import UIKit

class ConnectViewController: UIViewController {
    
    @IBOutlet weak var presentView: UIView!
    
    var airplayManager = AirplayManager.shared
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cornerRadiusTopView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    // MARK: - Action
    @IBAction func actionDismissPresent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSelectSeviceButton(_ sender: Any) {
        airplayManager.showAirplay(view: self.view)
    }
    
    // MARK: - Function
    private func cornerRadiusTopView() {
        presentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
}
