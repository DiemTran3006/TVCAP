//
//  KeyNotifier.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 09/11/2023.
//

import UIKit

final class KeyboardNotifier {
    var enabled: Bool = true {
        didSet {
            setNeedsUpdateConstraint()
        }
    }
    
    init(
        parentView: UIView,
        constraint: NSLayoutConstraint
    ) {
        self.parentView = parentView
        self.constraint = constraint
        
        baseConstant = constraint.constant
        notificationObserver = NotificationCenter.default
            .addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main
            ) { [weak self] in
                self?.keyboardEndFrame = ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                self?.setNeedsUpdateConstraint(animationDuration: UIView.inheritedAnimationDuration)
            }
    }
    
    private weak var parentView: UIView?
    private weak var constraint: NSLayoutConstraint?
    private let baseConstant: CGFloat
    private var notificationObserver: NSObjectProtocol!
    private var keyboardEndFrame: CGRect?
    private var latestAnimationDuration: TimeInterval?
    
    private func setNeedsUpdateConstraint(animationDuration: TimeInterval = 0) {
        guard
            latestAnimationDuration == nil
                || animationDuration > latestAnimationDuration!
        else { return }
        let shouldUpdate = latestAnimationDuration == nil
        latestAnimationDuration = animationDuration
        if shouldUpdate {
            DispatchQueue.main.async {
                self.updateConstraint()
            }
        }
    }
    
    private func updateConstraint() {
        defer {
            latestAnimationDuration = nil
        }
        guard
            let latestAnimationDuration = latestAnimationDuration,
            enabled,
            let keyboardEndFrame = keyboardEndFrame,
            let parentView = parentView,
            let constraint = constraint
        else { return }
        let isParentFirstItem = constraint.firstItem is UILayoutGuide || constraint.firstItem === parentView
        let followsLayoutGuide = constraint.firstItem is UILayoutGuide || constraint.secondItem is UILayoutGuide
        let multiplierSign: CGFloat = isParentFirstItem ? 1 : -1
        let screenHeight = UIScreen.main.bounds.height
        if keyboardEndFrame.minY >= screenHeight {
            constraint.constant = baseConstant
        } else {
            let safeAreaInsets = (followsLayoutGuide ? parentView.safeAreaInsets.bottom : 0)
            // if our constraint makes view invisible when keyboard is hidden, we need to ignore it
            let fixedBaseConstant = max(multiplierSign * baseConstant, 0)
            constraint.constant = multiplierSign * (screenHeight - keyboardEndFrame.minY - safeAreaInsets + fixedBaseConstant)-70
        }
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { parentView.layoutIfNeeded() },
            completion: nil
        )
    }
}
