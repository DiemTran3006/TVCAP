//
//  TutorialView.swift
//  TVCAP
//
//  Created by Diem Tran on 07/11/2023.
//

import UIKit

class TutorialView: BaseView {
    
    private let model: TutorialModel
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    
    init(model: TutorialModel) {
        self.model = model
        super.init(frame: .zero)
        titleLabel.text = model.title
        bannerImage.image = model.image
        styleContentLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Function
    func styleContentLabel() {
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: model.content)
        attributedText.apply(color: R.color.textColor.callAsFunction()!, subString: model.content)
        attributedText.apply(font: .primary(), subString: model.content)
        model.titleBold.forEach { string in
            attributedText.apply(font: .important(), subString: string)
        }
        contentLabel.attributedText = attributedText
    }
}

// MARK: - Model
struct TutorialModel {
    let title: String
    let content: String
    let image: UIImage?
    let titleBold: [String]
}

