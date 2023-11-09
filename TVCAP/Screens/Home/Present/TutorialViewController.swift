//
//  TutorialViewController.swift
//  TVCAP
//
//  Created by Diem Tran on 06/11/2023.
//

import UIKit

class TutorialViewController: UIViewController  {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var pageViewContainer: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var presentView: UIView!
    
    let tutorials: [TutorialModel] = [
        TutorialModel(title: "Connect to device",
                      content: "At the home screen tap to ”Tap to connect” button.",
                      image: R.image.iPhone14Pro1.callAsFunction(),
                      titleBold: ["Tap to connect"]),
        TutorialModel(title: "Connect to device",
                      content: "When bottom sheet appear, choose “Select Device” button.",
                      image: R.image.iPhone14Pro2.callAsFunction(),
                      titleBold: ["Select Device”"]),
        TutorialModel(title: "Select airplay device",
                      content: "Select your device on airplay pop-up.",
                      image: R.image.iPhone14Pro3.callAsFunction(),
                      titleBold: []),
        TutorialModel(title: "Turn on Screen Mirroring",
                      content: "Access control center and tap Screen Mirroring.",
                      image: R.image.iPhone14Pro4.callAsFunction(),
                      titleBold: ["control center", "Screen Mirroring."]),
        TutorialModel(title: "How to disconnect",
                      content: "Select “Screen Mirroring” then press “Stop Mirroring”.",
                      image: R.image.iPhone14Pro5.callAsFunction(),
                      titleBold: ["Screen Mirroring", "Stop Mirroring"])
    ]
    private var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.3)
        
        updataPageControl()
        
        mainScrollView.delegate = self
        tutorials.forEach { item in
            let view = TutorialView(model: item)
            pageViewContainer.addArrangedSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
            ])
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cornerRadiusTopViewPresent()
    }
    
// MARK: - Action
    @IBAction func actionDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func preAction(_ sender: Any) {
        print(mainScrollView.currentPage)
        if currentIndex > 0 {
            currentIndex -= 1
            scrollToPage(page: currentIndex, animated: true)
            updataPageControl()
            undataButtonBack()
        } else {
            print("Khong the pop ve dc nua")
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if currentIndex < tutorials.count - 1 {
            currentIndex += 1
            scrollToPage(page: currentIndex, animated: true)
            updataPageControl()
            undataButtonNext()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
// MARK: - Function
    private func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.mainScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.mainScrollView.scrollRectToVisible(frame, animated: animated)
    }
    private func updataPageControl() {
        pageControl.currentPage = currentIndex
    }
    private func undataButtonNext() {
        if currentIndex == 4 {
            nextButton.setTitle("Done ", for: .normal)
            nextButton.setTitleColor(UIColor(hexString: "#1797FF"), for: .normal)
            nextButton.setImage(UIImage(named: "icon.check.button"), for: .normal)
        }
    }
    private func undataButtonBack() {
        if currentIndex < 4 {
            nextButton.setTitle("Next ", for: .normal)
            nextButton.setTitleColor(UIColor(hexString: "#384161"), for: .normal)
            nextButton.setImage(UIImage(named: "icon.next.button"), for: .normal)
        }
    }
    
    private func cornerRadiusTopViewPresent() {
        presentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
}
// MARK: - Extension
extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = scrollView.currentPage
        pageControl.currentPage = scrollView.currentPage
        undataButtonBack()
        undataButtonNext()
    }
}
