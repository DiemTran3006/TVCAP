//
//  SocialCollectionViewCell.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 09/11/2023.
//

import UIKit

protocol SocialDelegate: AnyObject {
    func tapImageWithURL(_ url: String)
}

class SocialCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameSocial: UILabel!
    @IBOutlet weak var buttonSocial: UIButton!
    
    public weak var socialDelegate: SocialDelegate?
    private var currentSocial: SocialModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    public func configureSocial(_ social: SocialModel) {
        self.currentSocial = social
        self.nameSocial.text = social.nameSocial
        self.buttonSocial.setImage(UIImage(named: social.imageName), for: .normal)
    }
    
    @IBAction func handleSocial(_ sender: Any) {
        self.socialDelegate?.tapImageWithURL(currentSocial?.url ?? "")
    }
}
