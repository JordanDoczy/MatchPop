//
//  ViewController.swift
//  Balloon
//
//  Created by Jordan Doczy on 11/22/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import AVFoundation

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
    private let images = [
        Assets.Images.Animals.Cat,
        Assets.Images.Animals.Cow,
        Assets.Images.Animals.Deer,
        Assets.Images.Animals.Dog,
        Assets.Images.Animals.Donkey,
        Assets.Images.Animals.Elephant,
        Assets.Images.Animals.Fox,
        Assets.Images.Animals.Hen,
        Assets.Images.Animals.Leopard,
        Assets.Images.Animals.Lion,
        Assets.Images.Animals.Monkey,
        Assets.Images.Animals.Orangutan,
        Assets.Images.Animals.Owl,
        Assets.Images.Animals.Panda,
        Assets.Images.Animals.Panther,
        Assets.Images.Animals.Penguin,
        Assets.Images.Animals.Pig,
        Assets.Images.Animals.Rabbit,
        Assets.Images.Animals.Rooster,
        Assets.Images.Animals.Sheep,
        Assets.Images.Animals.Zebra
    ]
    private let animalSounds = [
        Assets.Images.Animals.Cat: Assets.Sounds.Cat,
        Assets.Images.Animals.Cow: Assets.Sounds.Cow,
        Assets.Images.Animals.Hen: Assets.Sounds.Chicken,
        Assets.Images.Animals.Dog: Assets.Sounds.Dog,
        Assets.Images.Animals.Donkey: Assets.Sounds.Donkey,
        Assets.Images.Animals.Rooster: Assets.Sounds.Rooster,
        Assets.Images.Animals.Sheep: Assets.Sounds.Sheep
    ]
    private var imageWidth: CGFloat { view.bounds.width / 10 }
    private var numberOfImages: Int {
        switch UserSettings.shared.difficulty {
        case .easy: 6
        case .medium: 11
        case .hard: images.count
        }
    }
    private var pops = 0
    private var sounds = [AVAudioPlayer]()

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator(referenceView: view)
        animator.addBehavior(animalBehavior)
        animalBehavior.collisionDelegate = self
        animalBehavior.boundary = CGRect(x: -50, y: -100, width: view.bounds.width + 100, height: view.bounds.height + 300)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        play(Assets.Sounds.GameOver)
        createBalloon("POP THE BALLOONS!")
    }

    // MARK: UICollisionBehaviorDelegate
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        guard let animal = item as? BalloonView, let asset = animal.animalAsset else { return }
        animalBehavior.removeView(animal)
        // Unpopped balloons that drift off screen come back from the bottom.
        if !animal.popped {
            createAnimal(asset)
        }
    }

    // MARK: Private Methods
    @discardableResult
    private func createAnimal(_ asset: String, yOffset: CGFloat = 0) -> BalloonView {
        let randomX = CGFloat.random(in: imageWidth...max(imageWidth, view.bounds.width - imageWidth))
        let animal = BalloonView(frame: CGRect(
            origin: CGPoint(x: randomX.rounded(.down), y: view.bounds.height + 70 + yOffset),
            size: CGSize(width: imageWidth, height: imageWidth)
        ))
        animal.animalAsset = asset
        animal.balloonAsset = balloons.randomElement()

        animal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popBalloon(_:))))
        animalBehavior.addView(animal)
        push(animal)

        return animal
    }

    private func releaseAnimals(from balloon: BalloonView) {
        balloon.subviews.first { $0 is UILabel }?.removeFromSuperview()
        balloon.pop {
            balloon.removeFromSuperview()
        }
        play(Assets.Sounds.Pop)

        let height = view.bounds.height
        for image in images.prefix(numberOfImages) {
            createAnimal(image, yOffset: -CGFloat.random(in: (height * 0.10)...(height * 0.75)))
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
        guard let animal = sender.view as? BalloonView else { return }
        animal.pop()
        animal.isUserInteractionEnabled = false
        animal.removeGestureRecognizer(sender)
        play(Assets.Sounds.Pop)
        play(animal.animalAsset.flatMap { animalSounds[$0] } ?? Assets.Sounds.Whistle)

        animalBehavior.instantaneousPush(animal, vector: CGVector(dx: 0, dy: -0.75))
        animalBehavior.addGravityBehavior(animal)

        pops += 1
        if pops == numberOfImages {
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playAgain(_:))))
            balloon = createBalloon("YOU WIN!\rPLAY AGAIN?", autoPop: false)
        }
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

    /// Keeps players alive until they finish; drops ones that already have.
    private func play(_ sound: String) {
        sounds.removeAll { !$0.isPlaying }
        if let player = AVAudioPlayer.playSound(sound) {
            sounds.append(player)
        }
    }
}
