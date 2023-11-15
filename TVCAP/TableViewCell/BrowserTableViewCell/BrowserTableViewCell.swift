//
//  BrowserTableViewCell.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 08/11/2023.
//

import UIKit

class BrowserTableViewCell: UITableViewCell {
    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var titleURL: UILabel!
    @IBOutlet weak var urlString: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(historyModel: HistoryBrowserModel) {
        self.faviconImage.image = UIImage(data: historyModel.favicon)
        self.titleURL.text = historyModel.title
        self.urlString.text = historyModel.url
    }
}
