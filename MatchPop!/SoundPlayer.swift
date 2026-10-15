//
//  SoundPlayer.swift
//  MatchPop!
//

import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()

    // Several players per sound so rapid repeats (popping balloons) can overlap.
    private var players = [String: [AVAudioPlayer]]()

    private init() {
        // Ambient mixes with the user's music and respects the silent switch.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
    }

    func play(_ name: String) {
        guard UserSettings.shared.sound, let player = idlePlayer(for: name) else { return }
        player.currentTime = 0
        player.play()
    }

    private func idlePlayer(for name: String) -> AVAudioPlayer? {
        if let idle = players[name]?.first(where: { !$0.isPlaying }) {
            return idle
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        player.prepareToPlay()
        players[name, default: []].append(player)
        return player
    }
}
