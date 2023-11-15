//
//  IntroCollectionViewCell.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 06/11/2023.
//

import UIKit

class IntroCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageIntro: UIImageView!
    @IBOutlet weak var titleIntro: UILabel!
    @IBOutlet weak var subtitleIntro: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(image:UIImage?,title: String, subtitle: String,currentIndex: Int) {
        imageIntro.image = image
        titleIntro.text = title
        subtitleIntro.text = subtitle
    }
}
