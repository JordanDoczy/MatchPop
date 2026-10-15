//
//  UserSettings.swift
//  CardFlip
//
//  Created by Jordan Doczy on 11/20/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation

final class UserSettings {
    static let shared = UserSettings()

    private enum Keys {
        static let sound = "sound"
        static let difficulty = "difficulty"
    }

    enum Difficulty: Int {
        case easy = 0, medium, hard

        var cardCount: Int {
            switch self {
            case .easy: 12
            case .medium: 30
            case .hard: Animal.allCases.count * 2
            }
        }

        var balloonCount: Int {
            switch self {
            case .easy: 6
            case .medium: 11
            case .hard: Animal.allCases.count
            }
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.sound: true,
            Keys.difficulty: Difficulty.medium.rawValue
        ])
    }

    var sound: Bool {
        get { defaults.bool(forKey: Keys.sound) }
        set { defaults.set(newValue, forKey: Keys.sound) }
    }

    var difficulty: Difficulty {
        get { Difficulty(rawValue: defaults.integer(forKey: Keys.difficulty)) ?? .medium }
        set { defaults.set(newValue.rawValue, forKey: Keys.difficulty) }
    }
}
