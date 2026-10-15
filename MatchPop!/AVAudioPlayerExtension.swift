//
//  AudioPlayer.swift
//  CardFlip
//
//  Created by Jordan Doczy on 11/20/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import AVFoundation

extension AVAudioPlayer {
    /// Returns the player so callers can keep it alive until playback finishes.
    @discardableResult
    static func playSound(_ fileName: String, type: String = "wav") -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: type),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        if UserSettings.shared.sound {
            player.play()
        }
        return player
    }
}
