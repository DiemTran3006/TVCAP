//
//  TutorialWithStepViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 08/11/2023.
//

import UIKit

class TutorialWithStepViewController: UIViewController {
    
    @IBOutlet weak var labelStepOne: UILabel!
    @IBOutlet weak var labelStepTwo: UILabel!
    
    private var attrStringStepOne: NSAttributedString?
    private var attrStringStepTwo: NSAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelStepOne.attributedText = self.attrStringStepOne
        labelStepTwo.attributedText = self.attrStringStepTwo
    }
    
    public func setDetentWithImageHeight(equalTo height: CGFloat) {
        let detent: UISheetPresentationController.Detent = .custom { context in
            return 288+height
        }
        
        if let presentationController = self.presentationController as? UISheetPresentationController {
            presentationController.detents = [detent]
            presentationController.preferredCornerRadius = 24
        }
    }
    
    public func configureLabelStepOne(text: String, textToBold: [NSString]) {
        self.attrStringStepOne = text.withBoldText(boldPartsOfString: textToBold, font: .systemFont(ofSize: 16), boldFont: .systemFont(ofSize: 16,weight: .bold))
    }
    
    public func configureLabelStepTwo(text: String, textToBold: [NSString]) {
        self.attrStringStepTwo = text.withBoldText(boldPartsOfString: textToBold, font: .systemFont(ofSize: 16), boldFont: .systemFont(ofSize: 16,weight: .bold))
    }
    
    @IBAction func handleGotIt(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
