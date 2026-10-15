//
//  ViewController.swift
//  CardFlip
//
//  Created by Jordan Doczy on 11/18/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import AVFoundation

final class MatchGameViewController: UIViewController, CardViewDelegate {

    private enum Segues {
        static let GameOver = "Game Over"
    }

    // MARK: Private Members
    private var audioPlayer: AVAudioPlayer?
    private var cards = [CardView]()
    private var cardHeight: CGFloat { cardWidth }
    private var cardsPerRow: Int {
        switch numberOfCards {
        case 0...12: 4
        case 13...30: 5
        default: 6
        }
    }
    private var cardWidth: CGFloat { (view.bounds.width - spacer * CGFloat(cardsPerRow + 1)) / CGFloat(cardsPerRow) }
    private var lastCard: CardView?
    var difficulty: UserSettings.Difficulty? {
        didSet { reset() }
    }
    private let images = [
        Assets.Images.Animals.Cat: UIColor(red: 230/255, green: 164/255, blue: 174/255, alpha: 1),
        Assets.Images.Animals.Cow: UIColor(red: 177/255, green: 237/255, blue: 235/255, alpha: 1),
        Assets.Images.Animals.Deer: UIColor(red: 246/255, green: 197/255, blue: 127/255, alpha: 1),
        Assets.Images.Animals.Dog: UIColor(red: 243/255, green: 234/255, blue: 170/255, alpha: 1),
        Assets.Images.Animals.Donkey: UIColor(red: 190/255, green: 203/255, blue: 215/255, alpha: 1),
        Assets.Images.Animals.Elephant: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
        Assets.Images.Animals.Fox: UIColor(red: 249/255, green: 247/255, blue: 223/255, alpha: 1),
        Assets.Images.Animals.Hen: UIColor(red: 209/255, green: 135/255, blue: 132/255, alpha: 1),
        Assets.Images.Animals.Leopard: UIColor(red: 164/255, green: 199/255, blue: 179/255, alpha: 1),
        Assets.Images.Animals.Lion: UIColor(red: 254/255, green: 242/255, blue: 118/255, alpha: 1),
        Assets.Images.Animals.Monkey: UIColor(red: 186/255, green: 162/255, blue: 150/255, alpha: 1),
        Assets.Images.Animals.Orangutan: UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1),
        Assets.Images.Animals.Owl: UIColor(red: 241/255, green: 179/255, blue: 131/255, alpha: 1),
        Assets.Images.Animals.Panda: UIColor(red: 255/255, green: 179/255, blue: 190/255, alpha: 1),
        Assets.Images.Animals.Panther: UIColor(red: 202/255, green: 233/255, blue: 201/255, alpha: 1),
        Assets.Images.Animals.Penguin: UIColor(red: 131/255, green: 144/255, blue: 166/255, alpha: 1),
        Assets.Images.Animals.Pig: UIColor(red: 230/255, green: 229/255, blue: 242/255, alpha: 1),
        Assets.Images.Animals.Rabbit: UIColor(red: 155/255, green: 163/255, blue: 216/255, alpha: 1),
        Assets.Images.Animals.Rooster: UIColor(red: 241/255, green: 179/255, blue: 131/255, alpha: 1),
        Assets.Images.Animals.Sheep: UIColor(red: 249/255, green: 221/255, blue: 191/255, alpha: 1),
        Assets.Images.Animals.Zebra: UIColor(red: 169/255, green: 255/255, blue: 190/255, alpha: 1)
    ]
    private var numberOfCards: Int {
        switch difficulty {
        case .easy: 12
        case .medium: 30
        case .hard: 42
        case nil: images.count * 2
        }
    }
    private var numberOfRows: Int { numberOfCards / cardsPerRow }
    private let spacer: CGFloat = 5
    // Delayed card flips from the previous deal; cancelled on reset so they can't touch new cards.
    private var pendingTasks = [Task<Void, Never>]()

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        difficulty = UserSettings.shared.difficulty
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if difficulty != UserSettings.shared.difficulty {
            difficulty = UserSettings.shared.difficulty
        }
    }

    // MARK: CardViewDelegate
    func cardTapped(_ card: CardView) {
        audioPlayer = AVAudioPlayer.playSound(Assets.Sounds.Click)
        card.visible = true

        guard let previous = lastCard else {
            lastCard = card
            return
        }
        lastCard = nil

        if card.value == previous.value {
            foundMatch(card, previous)
        } else {
            after(.seconds(1.25)) {
                card.visible = false
                try? await Task.sleep(for: .seconds(0.25))
                previous.visible = false
            }
        }
    }

    // MARK: Private Methods
    private func foundMatch(_ first: CardView, _ second: CardView) {
        audioPlayer = AVAudioPlayer.playSound(Assets.Sounds.Match)
        for card in [first, second] {
            card.hide()
            view.bringSubviewToFront(card)
        }
        cards.removeAll { $0 === first || $0 === second }

        if cards.isEmpty {
            performSegue(withIdentifier: Segues.GameOver, sender: self)
        }
    }

    private func after(_ delay: Duration, _ work: @escaping @MainActor () async -> Void) {
        pendingTasks.append(Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await work()
        })
    }

    private func animateCards() {
        let cards = cards
        after(.zero) {
            for card in cards {
                card.show()
                try? await Task.sleep(for: .seconds(0.015))
            }
        }
    }

    private func createCards() {
        let pairs = images.keys.shuffled().prefix(numberOfCards / 2)
        let cardImages = (pairs + pairs).shuffled()
        let yOffset = view.bounds.height / 2 - (CGFloat(numberOfRows) * (cardHeight + spacer)) / 2

        cards = cardImages.enumerated().map { index, image in
            let row = index / cardsPerRow
            let column = index % cardsPerRow
            let origin = CGPoint(
                x: CGFloat(column) * (cardWidth + spacer) + spacer,
                y: CGFloat(row) * (cardHeight + spacer) + yOffset
            )
            let card = CardView(
                frame: CGRect(origin: origin, size: CGSize(width: cardWidth, height: cardHeight)),
                back: Assets.Images.Card,
                front: image,
                color: images[image] ?? .clear
            )
            card.delegate = self
            view.addSubview(card)
            return card
        }
    }

    private func reset() {
        pendingTasks.forEach { $0.cancel() }
        pendingTasks.removeAll()
        lastCard = nil
        view.subviews.lazy.compactMap { $0 as? CardView }.forEach { $0.removeFromSuperview() }

        createCards()
        animateCards()
        audioPlayer = AVAudioPlayer.playSound(Assets.Sounds.Start)
    }
}
