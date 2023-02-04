//
//  OpeningScene.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/16/23.
//

import SpriteKit

class OpeningScene: SKScene {
    
    let startButton = SKLabelNode(fontNamed: k.fonts.bold)
    let highScoreLabel = SKLabelNode(fontNamed: k.fonts.normal)
    let resetLabel = SKLabelNode(fontNamed: k.fonts.normal)
    var highScore: Int = 0 {
        didSet {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        startButton.position = CGPoint(x: frame.width / 2, y: 150)
        startButton.zPosition = k.layers.labels
        startButton.name = "start"
        startButton.text = "START"
        addChild(startButton)
        
        highScoreLabel.position = CGPoint(x: 384, y: 914)
        highScoreLabel.zPosition = k.layers.labels
        highScoreLabel.name = "hiscore"
        highScoreLabel.text = "0000"
        addChild(highScoreLabel)
        
        resetLabel.position = CGPoint(x: frame.width - 100, y: 100)
        resetLabel.zPosition = k.layers.labels
        resetLabel.fontSize = 18
        resetLabel.name = "reset"
        resetLabel.text = "RESET HI-SCORE"
        addChild(resetLabel)
        
        highScore = UserDefaults.standard.integer(forKey: k.userDefaults.hiScore)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "start" {
            // Set the default values for a new game
            UserDefaults.standard.set(0, forKey: k.userDefaults.score)
            UserDefaults.standard.set(2, forKey: k.userDefaults.lives)
            UserDefaults.standard.set(0, forKey: k.userDefaults.invadersDestroyed)
            UserDefaults.standard.set(0, forKey: k.userDefaults.shotsFired)
            UserDefaults.standard.set(1, forKey: k.userDefaults.level)
            UserDefaults.standard.set(0, forKey: k.userDefaults.mysteryPosition)
            
            // Open the game scene and begin play
            if let nextScene = GameScene(fileNamed: k.scenes.game){
                nextScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 1)
                view?.presentScene(nextScene, transition: transition)
            }
        } else if tapped.name == "reset" {
            // Reset the Hi-Score value
            highScore = 0
            UserDefaults.standard.set(0, forKey: k.userDefaults.hiScore)
        } else {
            return
        }
    }
}
