//
//  Sounds.swift
//  QuickSpell
//
//  Created by Michael & Diana Pascucci on 11/11/22.
//

import SwiftUI
import AVKit

class SoundManager {
    
    // MARK: - SINGLETON
    static let instance = SoundManager()
    
    // MARK: - PROPERTIES
    private var player: AVAudioPlayer?
 
    // MARK: - METHODS
    func playSound(_ title: String) {
        
        guard let url = Bundle.main.url(forResource: title, withExtension: ".wav") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        player?.stop()
    }
    
}
