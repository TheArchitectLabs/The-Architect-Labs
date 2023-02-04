//
//  Constants.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/13/23.
//

import SpriteKit

enum k {
    
    enum scenes {
        static let open: String = "OpeningScene"
        static let game: String = "GameScene"
        static let summary: String = "SummaryScene"
    }
    
    enum layers {
        static let background: CGFloat = -20
        static let particles: CGFloat = -10
        static let labels: CGFloat = 0
        static let player: CGFloat = 10
        static let invader: CGFloat = 10
    }
    
    enum fonts {
        static let normal: String = "HelveticaNeue-UltraLight"
        static let bold: String = "HelveticaNeue-Bold"
    }
    
    enum userDefaults {
        static let shotsFired: String = "shotsfired"
        static let invadersDestroyed: String = "invadersdestroyed"
        static let score: String = "score"
        static let hiScore: String = "hiscore"
        static let lives: String = "lives"
        static let level: String = "level"
        static let mysteryPosition: String = "mysteryPosition"
    }

    static let playerDims: CGSize = CGSize(width: 48, height: 32)
    static let playerWeaponDims: CGSize = CGSize(width: 4, height: 12)
    
    static let invaderDims: CGSize = CGSize(width: 36, height: 24)
    static let invaderWeaponDims: CGSize = CGSize(width: 4, height: 12)
    
    static let barrierDims: CGSize = CGSize(width: 72, height: 72)

    
    // Invader Grid Size
    static let cols: Int = 11
    static let rows: Int = 5

    
    // Mystery Ship Bonus Point Array
    static let mysteryBonus: [Int] = [
        100, 50, 50, 100, 150,
        100, 100, 50, 300, 100,
        100, 100, 50, 150, 100
    ]
}
