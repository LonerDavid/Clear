//
//  AudioPlayerManager.swift
//  Clear
//
//  Created by Haruaki on 2025/6/20.
//

import Foundation
import AVFoundation

class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    private var player:AVAudioPlayer?

    func playBackgroundSound(named name: String, fileType: String = "mp3", loops: Bool = true) {
        if let url = Bundle.main.url(forResource: name, withExtension: fileType) {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = loops ? -1 : 0
                player?.volume = 0.5
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player?.play()
            } catch {
                print("❌ 播放音樂失敗：\(error)")
            }
        }
    }

    func stop() {
        player?.stop()
    }
}
