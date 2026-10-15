//
//  MatchPopTests.swift
//  MatchPopTests
//

import UIKit
import Foundation
import Testing
@testable import MatchPop_

struct AnimalTests {

    @Test(arguments: [12, 30, 42])
    func deckHasEachAnimalExactlyTwice(cardCount: Int) {
        let deck = Animal.shuffledDeck(cardCount: cardCount)

        #expect(deck.count == cardCount)
        let counts = Dictionary(grouping: deck, by: \.self).mapValues(\.count)
        #expect(counts.count == cardCount / 2)
        #expect(counts.values.allSatisfy { $0 == 2 })
    }

    @Test func hardModeUsesEveryAnimal() {
        let deck = Animal.shuffledDeck(cardCount: UserSettings.Difficulty.hard.cardCount)
        #expect(Set(deck) == Set(Animal.allCases))
    }

    @Test func everyAnimalHasAnImageInTheAssetCatalog() {
        for animal in Animal.allCases {
            #expect(UIImage(named: animal.imageName) != nil, "Missing image for \(animal)")
        }
    }

    @Test func everyAnimalSoundIsBundled() {
        for animal in Animal.allCases {
            #expect(Bundle.main.url(forResource: animal.soundName, withExtension: "wav") != nil, "Missing sound for \(animal)")
        }
    }
}

struct CardLayoutTests {

    @Test(arguments: [(12, 4), (30, 5), (42, 6)])
    func cardsPerRowGrowsWithCardCount(cardCount: Int, perRow: Int) {
        let layout = CardLayout(cardCount: cardCount, containerSize: CGSize(width: 402, height: 874))
        #expect(layout.cardsPerRow == perRow)
    }

    @Test(arguments: [12, 30, 42])
    func cardsFitOnScreenWithoutOverlapping(cardCount: Int) {
        let container = CGRect(x: 0, y: 0, width: 402, height: 874)
        let layout = CardLayout(cardCount: cardCount, containerSize: container.size)
        let frames = (0..<cardCount).map(layout.frame(at:))

        for frame in frames {
            #expect(container.contains(frame))
        }
        for (i, a) in frames.enumerated() {
            for b in frames[(i + 1)...] {
                #expect(!a.intersects(b))
            }
        }
    }

    @Test func gridIsVerticallyCentered() {
        let layout = CardLayout(cardCount: 12, containerSize: CGSize(width: 402, height: 874))
        let top = layout.frame(at: 0).minY
        let bottom = layout.frame(at: 11).maxY + layout.spacing
        #expect(abs((874 - bottom) - top) < 0.001)
    }
}

struct UserSettingsTests {

    private func makeSettings() -> UserSettings {
        let suite = "MatchPopTests.\(UUID().uuidString)"
        return UserSettings(defaults: UserDefaults(suiteName: suite)!)
    }

    @Test func defaultsToSoundOnAndMediumDifficulty() {
        let settings = makeSettings()
        #expect(settings.sound)
        #expect(settings.difficulty == .medium)
    }

    @Test func persistsChanges() {
        let settings = makeSettings()
        settings.sound = false
        settings.difficulty = .hard
        #expect(!settings.sound)
        #expect(settings.difficulty == .hard)
    }

    @Test func balloonCountNeverExceedsAnimals() {
        for difficulty in [UserSettings.Difficulty.easy, .medium, .hard] {
            #expect(difficulty.balloonCount <= Animal.allCases.count)
            #expect(difficulty.cardCount / 2 <= Animal.allCases.count)
        }
    }
}
