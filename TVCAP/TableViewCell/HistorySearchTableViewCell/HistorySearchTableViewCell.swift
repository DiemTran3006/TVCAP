//
//  HistorySearchTableViewCell.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 09/11/2023.
//

import UIKit

class HistorySearchTableViewCell: UITableViewCell {
    @IBOutlet weak var labelSearch: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureLabel(_ string: String, textSearch: String) {
//        labelSearch.text = string
        var arrayString: [NSString] = []
        arrayString.append(textSearch as NSString)
        labelSearch.attributedText = string.withBoldText(boldPartsOfString: arrayString, font: .systemFont(ofSize: 16, weight: .bold), boldFont: .systemFont(ofSize: 16))
    }
}
