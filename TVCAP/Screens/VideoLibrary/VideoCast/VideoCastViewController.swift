//
//  VideoCastViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 09/11/2023.
//

import UIKit

protocol VideoCastProtocol: AnyObject {
    
    func popimage(image: String)
}

class VideoCastViewController: UIViewController {
    @IBOutlet weak var videoLibrary: UIImageView!
    let image = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        videoLibrary.image = UIImage(named: image)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
