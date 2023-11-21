//
//  VideoLibraryCollectionViewCell.swift
//  TVCAP
//
//  Created by Diem Tran on 09/11/2023.
//

import UIKit

class VideoLibraryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 16
    }
    
    // MARK: - Function
    func configCell(modol: VideoModel) {
        if let image = modol.thumbnailImage {
            imageView.image = image.croppedImage(inRect: .init(x: 0, y: 0, width: 400, height: 400))
        }
        let time = modol.asset?.duration ?? 0
        timeLabel.text = time.asString(style: .positional)
        let isSelected = modol.isSelected ?? false
        if isSelected {
            imageView.layer.borderColor = UIColor(hexString: "#1C7CFA").cgColor
        } else {
            imageView.layer.borderColor = UIColor(hexString: "#FFF").cgColor
        }
    }
}

