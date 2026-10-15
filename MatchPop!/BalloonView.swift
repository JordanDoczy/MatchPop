//
//  AnimalView.swift
//  Balloon
//
//  Created by Jordan Doczy on 11/22/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

final class BalloonView: UIView {

    private(set) var popped = false

    private var balloon: UIImageView?
    var balloonAsset: String? {
        didSet {
            balloon?.removeFromSuperview()
            guard let balloonAsset, let image = UIImage(named: balloonAsset) else { return }
            let balloon = UIImageView(image: image)
            balloon.frame.size = CGSize(width: frame.width, height: frame.width * image.ratio)
            animal?.center.x = balloon.center.x
            addSubview(balloon)
            sendSubviewToBack(balloon)
            self.balloon = balloon
        }
    }

    private var animal: UIImageView?
    var animalAsset: String? {
        didSet {
            animal?.removeFromSuperview()
            guard let animalAsset, let image = UIImage(named: animalAsset) else { return }
            let animal = UIImageView(image: image)
            animal.frame.size = CGSize(width: frame.width, height: frame.width * image.ratio)
            animal.center.y = -animal.frame.height * 0.5
            addSubview(animal)
            self.animal = animal
        }
    }

    func pop(_ completion: @escaping () -> Void = {}) {
        popped = true
        guard let balloon, let popImage = UIImage(named: Assets.Images.Balloons.Pop) else {
            completion()
            return
        }
        let pop = UIImageView(image: popImage)
        pop.frame.size = CGSize(width: balloon.frame.width, height: balloon.frame.width * popImage.ratio)
        addSubview(pop)
        UIView.animate(withDuration: 0.25) {
            balloon.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            balloon.center.y -= balloon.bounds.height / 4
            balloon.alpha = 0
            self.animal?.alpha = 1
            pop.transform = CGAffineTransform(scaleX: 2, y: 2)
            pop.alpha = 0
        } completion: { _ in
            pop.removeFromSuperview()
            completion()
        }
    }
}

extension UIImage {
    var ratio: CGFloat {
        max(size.width / size.height, size.height / size.width)
    }
}
