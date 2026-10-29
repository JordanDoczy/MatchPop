//
//  CardLayout.swift
//  MatchPop!
//

import CoreGraphics

/// Square cards in a grid that fills the width and is centered vertically.
struct CardLayout {
    let cardCount: Int
    let containerSize: CGSize
    var spacing: CGFloat = 5

    var cardsPerRow: Int {
        switch cardCount {
        case 0...12: 4
        case 13...30: 5
        default: 6
        }
    }

    var rows: Int { (cardCount + cardsPerRow - 1) / cardsPerRow }

    var cardSide: CGFloat {
        (containerSize.width - spacing * CGFloat(cardsPerRow + 1)) / CGFloat(cardsPerRow)
    }

    func frame(at index: Int) -> CGRect {
        let row = index / cardsPerRow
        let column = index % cardsPerRow
        let top = containerSize.height / 2 - CGFloat(rows) * (cardSide + spacing) / 2
        return CGRect(
            x: CGFloat(column) * (cardSide + spacing) + spacing,
            y: CGFloat(row) * (cardSide + spacing) + top,
            width: cardSide,
            height: cardSide
        )
    }
}
