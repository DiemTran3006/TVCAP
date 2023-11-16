//
//  SuccesViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 07/11/2023.
//

import UIKit

class MirroringTutorialViewController: UIViewController {
    
    @IBOutlet weak var viewPresent: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    
    let textContentLabel: String = "Access control center and tap Screen Mirroring. Choose your device to mirroring."
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cornerRadiusTopView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleContentLabel()
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    // MARK: - Action
    
    @IBAction func actionDissmisButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionNextButton(_ sender: Any) {
        let vc = MirroringStopViewController(nibName: "MirroringStopViewController", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Function
    private func styleContentLabel() {
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: textContentLabel)
        attributedText.apply(color: R.color.textColor.callAsFunction()!, subString: textContentLabel)
        attributedText.apply(font: .primary(), subString: textContentLabel)
        attributedText.apply(font: .important(), subString: "control center")
        attributedText.apply(font:.important(), subString: "Screen Mirroring.")
        contentLabel.attributedText = attributedText
    }
    
    private func cornerRadiusTopView() {
        viewPresent.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
}

