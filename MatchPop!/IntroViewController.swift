//
//  IntroViewController.swift
//  CardFlip
//
//  Created by Jordan Doczy on 11/18/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

final class IntroViewController: UIViewController {

    private enum Segues {
        static let Settings = "Show Settings"
    }

    // MARK: Private Members
    private var foreground: UIImageView!
    private var clouds = [UIImageView]()
    private var loaded = false

    // MARK: IBOutlets
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.alpha = 0
        startButton.alpha = 0
        titleLabel.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded {
            animateForeground()
            play(Assets.Sounds.Intro)
            loaded = true
        }
        animateClouds()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.Settings {
            removeClouds()
        }
    }

    // MARK: Private Methods
    private func createImageView(_ imageName: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        let aspect = imageView.image.map { $0.size.height / $0.size.width } ?? 0
        imageView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.width * aspect)
        return imageView
    }

    private func play(_ sound: String) {
        SoundPlayer.shared.play(sound)
    }

    private func removeClouds() {
        clouds.forEach { $0.removeFromSuperview() }
        clouds.removeAll()
    }

    // MARK: Handlers
    @IBAction func unwindToIntro(_ segue: UIStoryboardSegue) {}

    @objc private func pandaTapped(_ sender: UITapGestureRecognizer) {
        play(Assets.Sounds.Giggle)
    }

    // MARK: Animate Methods
    private func animateBackground() {
        let background = createImageView(Assets.Images.Scenery.Background)
        view.addSubview(background)
        view.sendSubviewToBack(background)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveEaseOut) {
            background.center.y -= background.bounds.height
        } completion: { _ in
            self.animateMountains(above: background)
        }
    }

    private func animateClouds() {
        removeClouds()
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        animateCloud(width: 120, y: 1, fromX: view.bounds.width, toX: -120 - 50, duration: 20)
        animateCloud(width: 60, y: 1, yPadding: 80, fromX: -60, toX: view.bounds.width + 50, duration: 15)
    }

    /// `y` is a multiple of the cloud's own height, matching the original layout.
    private func animateCloud(width: CGFloat, y: CGFloat, yPadding: CGFloat = 0, fromX: CGFloat, toX: CGFloat, duration: TimeInterval) {
        guard let image = UIImage(named: Assets.Images.Scenery.Cloud) else { return }
        let cloud = UIImageView(image: image)
        let height = width * image.size.height / image.size.width
        cloud.frame = CGRect(x: fromX, y: height * y + yPadding, width: width, height: height)
        view.addSubview(cloud)
        clouds.append(cloud)

        UIView.animate(withDuration: duration, delay: 0.5, options: [.curveLinear, .repeat]) {
            cloud.center.x = toX
        }
    }

    private func animateForeground() {
        foreground = createImageView(Assets.Images.Scenery.Foreground)
        view.addSubview(foreground)
        view.sendSubviewToBack(foreground)

        UIView.animate(withDuration: 0.4) {
            self.foreground.center.y -= self.foreground.bounds.height
        } completion: { _ in
            self.animateBackground()
        }
    }

    private func animateMountains(above background: UIView) {
        let mountains = UIImageView(image: UIImage(named: Assets.Images.Scenery.Mountains))
        let imageWidth = background.bounds.width / 2
        let aspect = mountains.image.map { $0.size.height / $0.size.width } ?? 0
        let imageHeight = imageWidth * aspect

        mountains.frame = CGRect(x: view.bounds.width - imageWidth, y: background.center.y - imageHeight, width: imageWidth, height: imageHeight)
        view.addSubview(mountains)
        view.sendSubviewToBack(mountains)

        UIView.animate(withDuration: 0.3, delay: 0.05, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear) {
            mountains.center.y -= imageHeight / 2
        } completion: { _ in
            self.animatePanda()
            self.animateUI()
        }
    }

    private func animatePanda() {
        let imageView = UIImageView(image: UIImage(named: Animal.panda.imageName))
        let imageWidth: CGFloat = 50
        let aspect = imageView.image.map { $0.size.height / $0.size.width } ?? 0
        let imageHeight = imageWidth * aspect

        imageView.frame = CGRect(x: 20, y: view.bounds.height, width: imageWidth, height: imageHeight)
        view.addSubview(imageView)

        imageView.isUserInteractionEnabled = true
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .button
        imageView.accessibilityLabel = "Panda"
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pandaTapped(_:))))

        UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.95, initialSpringVelocity: 20, options: .curveLinear) {
            imageView.center.y = self.foreground.center.y - imageHeight + 10
        }
    }

    private func animateUI() {
        UIView.animate(withDuration: 0.4) {
            self.startButton.alpha = 1
            self.titleLabel.alpha = 1
            self.settingsButton.alpha = 1
        }
    }
}
