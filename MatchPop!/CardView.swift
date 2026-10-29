//
//  CardView.swift
//  CardFlip
//
//  Created by Jordan Doczy on 11/18/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

protocol CardViewDelegate: AnyObject {
    func cardTapped(_ card: CardView)
}

final class CardView: UIView {

    // MARK: Private Members
    private var back: UIView!
    private var front: UIView!
    private var empty: UIView!

    // MARK: Public Members
    weak var delegate: CardViewDelegate?
    private(set) var animal: Animal!
    var visible: Bool {
        get { subviews.contains(front) }
        set {
            isUserInteractionEnabled = !newValue
            accessibilityLabel = newValue ? animal.rawValue.capitalized : "Card, face down"
            if newValue {
                flip(from: back, to: front, options: .transitionFlipFromLeft, duration: 0.4)
            } else {
                flip(from: front, to: back, options: .transitionFlipFromRight, duration: 0.55)
            }
        }
    }

    // MARK: Init
    convenience init(frame: CGRect, animal: Animal) {
        self.init(frame: frame)

        self.animal = animal
        back = createCard(Assets.Images.Card, color: UIColor(red: 206/255, green: 240/255, blue: 253/255, alpha: 1))
        front = createCard(animal.imageName, color: animal.cardColor)
        empty = UIView(frame: bounds)
        addSubview(empty)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        isUserInteractionEnabled = true

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Card, face down"
    }

    // MARK: API
    func hide() {
        accessibilityElementsHidden = true
        UIView.animate(withDuration: 0.55) {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        }
    }

    func show() {
        flip(from: empty, to: back, options: .transitionFlipFromLeft, duration: 0.35)
    }

    override func accessibilityActivate() -> Bool {
        tapped()
        return true
    }

    @objc private func tapped() {
        delegate?.cardTapped(self)
    }

    // MARK: Private Methods
    private func createCard(_ imageName: String, color: UIColor) -> UIView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.frame = bounds

        let card = UIView(frame: bounds)
        card.layer.cornerRadius = 8
        card.backgroundColor = color
        card.addSubview(imageView)
        return card
    }

    private func flip(from sideA: UIView, to sideB: UIView, options: UIView.AnimationOptions, duration: TimeInterval) {
        // Reduce Motion swaps the flip for a fade.
        let options = UIAccessibility.isReduceMotionEnabled ? .transitionCrossDissolve : options
        UIView.transition(from: sideA, to: sideB, duration: duration, options: options)
    }
}
