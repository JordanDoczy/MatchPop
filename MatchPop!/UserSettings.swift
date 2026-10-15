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
    }

    private let defaults = UserDefaults.standard

    private init() {
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
