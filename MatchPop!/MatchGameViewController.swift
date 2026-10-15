//
//  ViewController.swift
//  CardFlip
//
//  Created by Jordan Doczy on 11/18/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

final class MatchGameViewController: UIViewController, CardViewDelegate {

    private enum Segues {
        static let GameOver = "Game Over"
    }

    // MARK: Private Members
    private var cards = [CardView]()
    private var lastCard: CardView?
    private var hasDealt = false
    // Delayed card flips from the previous deal; cancelled on reset so they can't touch new cards.
    private var pendingTasks = [Task<Void, Never>]()

    var difficulty: UserSettings.Difficulty? {
        didSet { reset() }
    }

    // MARK: View Controller Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Card sizes depend on the final view width, which isn't known in viewDidLoad.
        if !hasDealt {
            hasDealt = true
            difficulty = UserSettings.shared.difficulty
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if difficulty != UserSettings.shared.difficulty {
            difficulty = UserSettings.shared.difficulty
        }
    }

    // MARK: CardViewDelegate
    func cardTapped(_ card: CardView) {
        SoundPlayer.shared.play(Assets.Sounds.Click)
        card.visible = true

        guard let previous = lastCard else {
            lastCard = card
            return
        }
        lastCard = nil

        if card.animal == previous.animal {
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
        SoundPlayer.shared.play(Assets.Sounds.Match)
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
        let cardCount = difficulty?.cardCount ?? Animal.allCases.count * 2
        let layout = CardLayout(cardCount: cardCount, containerSize: view.bounds.size)

        cards = Animal.shuffledDeck(cardCount: cardCount).enumerated().map { index, animal in
            let card = CardView(frame: layout.frame(at: index), animal: animal)
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
        SoundPlayer.shared.play(Assets.Sounds.Start)
    }
}
