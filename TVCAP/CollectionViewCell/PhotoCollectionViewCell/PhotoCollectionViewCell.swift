//
//  PhotoCollectionViewCell.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.masksToBounds = true
    }
    
    func setupBorder(_ bool: Bool) {
        if bool {
            self.layer.borderWidth = 2.0
        } else {
            self.layer.borderWidth = 0
        }
    }
    
    func removeCornerRadius() {
        self.layer.cornerRadius = 0
    }
}
