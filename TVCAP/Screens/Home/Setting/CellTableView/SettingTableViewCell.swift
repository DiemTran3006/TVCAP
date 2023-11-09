//
//  SettingTableViewCell.swift
//  TVCAP
//
//  Created by Diem Tran on 07/11/2023.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var setImageRightButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var setImageLeftButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Function
    
    func configCell(model: SettingModel ) {
        setImageLeftButton.setImage(UIImage(named: model.buttonleft), for: .normal)
        contentLabel.text = model.contentlabel
        setImageRightButton.setImage(UIImage(named: model.buttonright), for: .normal)
    }
    
}
