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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configure(historyModel: HistoryBrowserModel) {
        self.faviconImage.image = UIImage(data: historyModel.favicon)
        self.titleURL.text = historyModel.title
        self.urlString.text = historyModel.url
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateFormatted = dateFormatter.date(from: historyModel.dateTime)
        dateFormatter.dateFormat = "HH:mm a"
        guard let dateFormatted else { return }
        let stringFormatted = dateFormatter.string(from: dateFormatted)
        self.time.text = stringFormatted
    }
}
