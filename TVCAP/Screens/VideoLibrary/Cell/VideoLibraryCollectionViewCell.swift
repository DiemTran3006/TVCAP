//
//  VideoLibraryCollectionViewCell.swift
//  TVCAP
//
//  Created by Diem Tran on 09/11/2023.
//

import UIKit

class VideoLibraryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 16
    }
    // MARK: - Function
        func configCell(modol: VideoModel) {
            if let image = modol.thumbnailImage {
                imageView.image = image.imageResized(to: .init(width: 200, height: 200))
            }
            print(modol.asset?.duration ?? 0)
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
            let size = image.size
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(origin: .zero, size: newSize)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
    }

    extension UIImage {
        func imageResized(to size: CGSize) -> UIImage {
            return UIGraphicsImageRenderer(size: size).image { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }
