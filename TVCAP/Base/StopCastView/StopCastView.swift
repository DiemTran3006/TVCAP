//
//  StopCastView.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import UIKit

protocol StopCastDelegate: AnyObject {
    func handleStopCast()
    func handleCancel()
}

class StopCastView: UIView {
    let nibName = "StopCastView"
    
    weak var delegate: StopCastDelegate?
    
    @IBAction func handleStopCast(_ sender: Any) {
        self.delegate?.handleStopCast()
    }
    @IBAction func handleCancelCast(_ sender: Any) {
        self.delegate?.handleCancel()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

