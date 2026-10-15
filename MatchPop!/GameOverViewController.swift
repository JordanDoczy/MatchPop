//
//  ViewController.swift
//  Balloon
//
//  Created by Jordan Doczy on 11/22/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

final class GameOverViewController: UIViewController, UICollisionBehaviorDelegate {

    private enum Segues {
        static let PlayAgain = "Play Again"
    }

    // MARK: Private Members
    private let animalBehavior = AnimalBehavior()
    private var animator: UIDynamicAnimator!
    private var balloon: BalloonView?
    private let balloons = [
        Assets.Images.Balloons.Red,
        Assets.Images.Balloons.Orange,
        Assets.Images.Balloons.Yellow,
        Assets.Images.Balloons.Green,
        Assets.Images.Balloons.Blue,
        Assets.Images.Balloons.Purple
    ]
    private var imageWidth: CGFloat { view.bounds.width / 10 }
    private var numberOfAnimals: Int { UserSettings.shared.difficulty.balloonCount }
    private var pops = 0

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator(referenceView: view)
        animator.addBehavior(animalBehavior)
        animalBehavior.collisionDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The view only has its final size here, not in viewDidLoad.
        if animalBehavior.boundary == nil {
            animalBehavior.boundary = CGRect(x: -50, y: -100, width: view.bounds.width + 100, height: view.bounds.height + 300)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        play(Assets.Sounds.GameOver)
        createBalloon("POP THE BALLOONS!")
    }

    // MARK: UICollisionBehaviorDelegate
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        guard let balloon = item as? BalloonView, let animal = balloon.animal else { return }
        animalBehavior.removeView(balloon)
        // Unpopped balloons that drift off screen come back from the bottom.
        if !balloon.popped {
            createAnimal(animal)
        }
    }

    // MARK: Private Methods
    @discardableResult
    private func createAnimal(_ animal: Animal, yOffset: CGFloat = 0) -> BalloonView {
        let randomX = CGFloat.random(in: imageWidth...max(imageWidth, view.bounds.width - imageWidth))
        let balloon = BalloonView(frame: CGRect(
            origin: CGPoint(x: randomX.rounded(.down), y: view.bounds.height + 70 + yOffset),
            size: CGSize(width: imageWidth, height: imageWidth)
        ))
        balloon.animal = animal
        balloon.balloonAsset = balloons.randomElement()

        balloon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popBalloon(_:))))
        animalBehavior.addView(balloon)
        push(balloon)

        return balloon
    }

    private func releaseAnimals(from balloon: BalloonView) {
        balloon.subviews.first { $0 is UILabel }?.removeFromSuperview()
        balloon.pop {
            balloon.removeFromSuperview()
        }
        play(Assets.Sounds.Pop)

        let height = view.bounds.height
        for animal in Animal.allCases.prefix(numberOfAnimals) {
            createAnimal(animal, yOffset: -CGFloat.random(in: (height * 0.10)...(height * 0.75)))
        }
    }

    @discardableResult
    private func createBalloon(_ text: String, autoPop: Bool = true) -> BalloonView {
        let balloon = BalloonView()
        balloon.frame.size.width = view.bounds.width / 2
        balloon.balloonAsset = Assets.Images.Balloons.Red
        balloon.center.x = view.center.x
        balloon.frame.origin.y = view.bounds.height
        view.addSubview(balloon)

        let label = UILabel(frame: CGRect(x: 0, y: 70, width: balloon.frame.width, height: 50))
        label.text = text
        label.numberOfLines = 4
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "ChalkboardSE-Light", size: 15)
        balloon.addSubview(label)

        UIView.animate(withDuration: 2) {
            balloon.frame.origin.y = self.view.bounds.height / 4
        } completion: { _ in
            guard autoPop else { return }
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                self.releaseAnimals(from: balloon)
            }
        }

        return balloon
    }

    @objc private func popBalloon(_ sender: UITapGestureRecognizer) {
        guard let balloon = sender.view as? BalloonView else { return }
        balloon.pop()
        balloon.isUserInteractionEnabled = false
        balloon.removeGestureRecognizer(sender)
        play(Assets.Sounds.Pop)
        play(balloon.animal?.soundName ?? Assets.Sounds.Whistle)

        animalBehavior.instantaneousPush(balloon, vector: CGVector(dx: 0, dy: -0.75))
        animalBehavior.addGravityBehavior(balloon)

        pops += 1
        if pops == numberOfAnimals {
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playAgain(_:))))
            self.balloon = createBalloon("YOU WIN!\rPLAY AGAIN?", autoPop: false)
        }
    }

    @IBAction func playAgainTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.PlayAgain, sender: self)
    }

    @objc private func playAgain(_ sender: UITapGestureRecognizer) {
        guard let balloon else { return }
        play(Assets.Sounds.Pop)
        balloon.subviews.first { $0 is UILabel }?.removeFromSuperview()
        balloon.pop {
            self.performSegue(withIdentifier: Segues.PlayAgain, sender: self)
        }
    }

    private func push(_ animal: BalloonView) {
        let speed = max(Double.random(in: 0..<1), 0.45)
        animalBehavior.continuousPush(animal, vector: CGVector(dx: 0, dy: speed * -0.025))
    }

    private func play(_ sound: String) {
        SoundPlayer.shared.play(sound)
    }
}
