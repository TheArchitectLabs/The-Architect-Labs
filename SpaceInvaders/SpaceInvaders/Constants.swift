//
//  Constants.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/13/23.
//

import SpriteKit

struct k {
    
    static let font: String = "HelveticaNeue-UltraLight"
    static let fontBold: String = "HelveticaNeue-Bold"
    
    static let playerDims: CGSize = CGSize(width: 48, height: 32)
    static let playerWeaponDims: CGSize = CGSize(width: 4, height: 12)
    
    static let invaderDims: CGSize = CGSize(width: 36, height: 24)
    static let invaderWeaponDims: CGSize = CGSize(width: 4, height: 12)
    
    static let barrierDims: CGSize = CGSize(width: 72, height: 72)
    
    // Z-Positions
    static let zPosBackground: CGFloat = -100
    static let zPosParticles: CGFloat = -99
    static let zPosLabels: CGFloat = -97
    static let zPosPlayer: CGFloat = 0
    static let zPosInvader: CGFloat = 0
    
    // Invader Grid
    static let cols: Int = 11
    static let rows: Int = 5
    
    // UserDefaults Keys
    static let shotsFired: String = "shotsfired"
    static let invadersDestroyed: String = "invadersdestroyed"
    static let score: String = "score"
    static let hiScore: String = "hiscore"
    static let lives: String = "lives"
    
}
