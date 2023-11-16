//
//  ErrorMirroringViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 08/11/2023.
//

import UIKit

class ErrorMirroringViewController: UIViewController {
    
    @IBOutlet weak var contenLabel: UILabel!
    @IBOutlet weak var presentView: UIView!
    
    var airplayManager = AirplayManager.shared
    let conten = "Connect device to\nmirroring"
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cornerRadiusTopView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        contenLabel.text = conten
    }

    // MARK: - Action
    @IBAction func actionSelectButton(_ sender: Any) {
        airplayManager.showAirplay(view: self.view)
    }
    
    @IBAction func actionDissmis(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Function
    private func cornerRadiusTopView() {
        presentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
}
