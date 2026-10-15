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
    private(set) var value: String?
    var visible: Bool {
        get { subviews.contains(front) }
        set {
            isUserInteractionEnabled = !newValue
            if newValue {
                flip(from: back, to: front, options: .transitionFlipFromLeft, duration: 0.4)
            } else {
                flip(from: front, to: back, options: .transitionFlipFromRight, duration: 0.55)
            }
        }
    }

    // MARK: Init
    convenience init(frame: CGRect, back backImage: String, front frontImage: String, color: UIColor = .clear) {
        self.init(frame: frame)

        value = frontImage
        back = createCard(backImage, color: UIColor(red: 206/255, green: 240/255, blue: 253/255, alpha: 1))
        front = createCard(frontImage, color: color)
        empty = UIView(frame: bounds)
        addSubview(empty)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        isUserInteractionEnabled = true
    }

    // MARK: API
    func hide() {
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
        UIView.transition(from: sideA, to: sideB, duration: duration, options: options)
    }
}
