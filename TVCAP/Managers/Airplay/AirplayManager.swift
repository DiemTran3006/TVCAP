//
//  AirplayManager.swift
//  TVCAP
//
//  Created by Diem Tran on 08/11/2023.
//

import UIKit
import AVKit
import MediaPlayer

class AirplayManager: NSObject {
    static var shared: AirplayManager = AirplayManager()
    
    func showAirplay(view: UIView) {
        let rect = CGRect(x: -100, y: 0, width: 0, height: 0)
        let airplayVolume = MPVolumeView(frame: rect)
        airplayVolume.showsVolumeSlider = false
        view.addSubview(airplayVolume)
        for itemView: UIView in airplayVolume.subviews {
            if let button = itemView as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
        airplayVolume.removeFromSuperview()
    }
}
