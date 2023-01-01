//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/1/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - PROPERTIES
    // Images, fonts, and sounds
    let background = SKSpriteNode(color: .black, size: CGSize(width: 768, height: 1024))
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        
        // Background
        background.zPosition = -100
        addChild(background)

    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
