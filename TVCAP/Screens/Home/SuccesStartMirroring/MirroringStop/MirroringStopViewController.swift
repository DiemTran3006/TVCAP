//
//  MirroringStopViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 08/11/2023.
//

import UIKit

final class MirroringStopViewController: UIViewController {
    
    @IBOutlet weak var presentView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    let textContenLabel: String = "Access control center again and tap Screen Mirroring. Then press “Stop Mirroring”."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleContentLabel()
        view.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cornerRadiusTopView()
    }
    
    // MARK: - Action
    @IBAction func actionNextButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Function
    
    private func cornerRadiusTopView() {
        presentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    private func styleContentLabel() {
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: textContenLabel)
        attributedText.apply(color: R.color.textColor.callAsFunction()!, subString: textContenLabel)
        attributedText.apply(font: .primary(), subString: textContenLabel)
        attributedText.apply(font: .important(), subString: "control center")
        attributedText.apply(font:.important(), subString: "Screen Mirroring.")
        attributedText.apply(font:.important(), subString: "“Stop Mirroring”.")
        contentLabel.attributedText = attributedText
    }
}
