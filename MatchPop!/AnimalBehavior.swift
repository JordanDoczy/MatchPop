//
//  AnimalBehavior.swift
//  Balloon
//
//  Created by Jordan Doczy on 11/22/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

final class AnimalBehavior: UIDynamicBehavior {

    private let collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.collisionMode = .boundaries
        return behavior
    }()
    private let gravityBehavior = UIGravityBehavior()
    private var pushBehaviors = [UIView: UIPushBehavior]()
    private let animalBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        return behavior
    }()

    var boundary: CGRect? {
        didSet {
            guard let b = boundary else { return }
            collisionBehavior.addBoundary(withIdentifier: "left" as NSString, from: CGPoint(x: b.minX, y: b.minY), to: CGPoint(x: b.minX, y: b.maxY))
            collisionBehavior.addBoundary(withIdentifier: "right" as NSString, from: CGPoint(x: b.maxX, y: b.minY), to: CGPoint(x: b.maxX, y: b.maxY))
            collisionBehavior.addBoundary(withIdentifier: "top" as NSString, from: CGPoint(x: b.minX, y: b.minY), to: CGPoint(x: b.maxX, y: b.minY))
            collisionBehavior.addBoundary(withIdentifier: "bottom" as NSString, from: CGPoint(x: b.minX, y: b.maxY), to: CGPoint(x: b.maxX, y: b.maxY))
        }
    }

    var collisionDelegate: UICollisionBehaviorDelegate? {
        get { collisionBehavior.collisionDelegate }
        set { collisionBehavior.collisionDelegate = newValue }
    }

    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(gravityBehavior)
        addChildBehavior(animalBehavior)
    }

    func addView(_ view: UIView) {
        addToSuperview(view)
        animalBehavior.addItem(view)
        collisionBehavior.addItem(view)
    }

    func removeView(_ view: UIView) {
        animalBehavior.removeItem(view)
        collisionBehavior.removeItem(view)
        gravityBehavior.removeItem(view)
        stopContinuousPush(view)
        view.removeFromSuperview()
    }

    func addGravityBehavior(_ view: UIView) {
        addToSuperview(view)
        gravityBehavior.addItem(view)
    }

    func removeGravityBehavior(_ view: UIView) {
        gravityBehavior.removeItem(view)
    }

    func continuousPush(_ view: UIView, vector: CGVector) {
        addToSuperview(view)
        let behavior = UIPushBehavior(items: [view], mode: .continuous)
        behavior.pushDirection = vector
        addChildBehavior(behavior)
        pushBehaviors[view] = behavior
    }

    func instantaneousPush(_ view: UIView, vector: CGVector) {
        addToSuperview(view)
        let behavior = UIPushBehavior(items: [view], mode: .instantaneous)
        behavior.pushDirection = vector
        behavior.action = { [unowned behavior] in
            behavior.dynamicAnimator?.removeBehavior(behavior)
        }
        addChildBehavior(behavior)
    }

    func stopContinuousPush(_ view: UIView) {
        guard let behavior = pushBehaviors.removeValue(forKey: view) else { return }
        behavior.removeItem(view)
        removeChildBehavior(behavior)
    }

    private func addToSuperview(_ view: UIView) {
        guard let superview = dynamicAnimator?.referenceView, view.superview !== superview else { return }
        superview.addSubview(view)
    }
}
