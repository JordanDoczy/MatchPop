//
//  Animal.swift
//  MatchPop!
//

import UIKit

/// Every animal that appears on a card or under a balloon.
enum Animal: String, CaseIterable {
    case cat, cow, deer, dog, donkey, elephant, fox, hen, leopard, lion, monkey
    case orangutan, owl, panda, panther, penguin, pig, rabbit, rooster, sheep, zebra

    var imageName: String { rawValue }

    var cardColor: UIColor {
        let (r, g, b): (CGFloat, CGFloat, CGFloat) = switch self {
        case .cat: (230, 164, 174)
        case .cow: (177, 237, 235)
        case .deer: (246, 197, 127)
        case .dog: (243, 234, 170)
        case .donkey: (190, 203, 215)
        case .elephant: (255, 255, 255)
        case .fox: (249, 247, 223)
        case .hen: (209, 135, 132)
        case .leopard: (164, 199, 179)
        case .lion: (254, 242, 118)
        case .monkey: (186, 162, 150)
        case .orangutan: (203, 203, 203)
        case .owl: (241, 179, 131)
        case .panda: (255, 179, 190)
        case .panther: (202, 233, 201)
        case .penguin: (131, 144, 166)
        case .pig: (230, 229, 242)
        case .rabbit: (155, 163, 216)
        case .rooster: (241, 179, 131)
        case .sheep: (249, 221, 191)
        case .zebra: (169, 255, 190)
        }
        return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }

    /// Each of `cardCount / 2` random animals appears twice, in random order.
    static func shuffledDeck(cardCount: Int) -> [Animal] {
        let pairs = allCases.shuffled().prefix(cardCount / 2)
        return (pairs + pairs).shuffled()
    }

    /// Animals without a recording of their own get a whistle.
    var soundName: String {
        switch self {
        case .cat: Assets.Sounds.Cat
        case .cow: Assets.Sounds.Cow
        case .dog: Assets.Sounds.Dog
        case .donkey: Assets.Sounds.Donkey
        case .hen: Assets.Sounds.Chicken
        case .rooster: Assets.Sounds.Rooster
        case .sheep: Assets.Sounds.Sheep
        default: Assets.Sounds.Whistle
        }
    }
}
