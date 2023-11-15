//
//  EmptyLibraryView.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import UIKit

protocol EmptyLibraryDelegate: AnyObject {
    func handleButtonAdd()
}

class EmptyLibraryView: UIView {
    @IBOutlet weak var titleEmpty: UILabel!
    @IBOutlet weak var subtitleEmpty: UILabel!
    @IBOutlet weak var buttonAdd: GradientButton!
    
    private let nibName = "EmptyLibraryView"
    public weak var delegate: EmptyLibraryDelegate?
    
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
    
    func configureVideo() {
        self.titleEmpty.text = "No Videos Available"
        self.subtitleEmpty.text = "Please add more videos."
        self.buttonAdd.setTitle("Add Videos", for: .normal)
    }
    
    @IBAction func handleButtonAdd(_ sender: Any) {
        self.delegate?.handleButtonAdd()
    }
}
