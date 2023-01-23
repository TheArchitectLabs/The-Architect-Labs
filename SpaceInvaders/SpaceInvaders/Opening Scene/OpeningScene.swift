//
//  OpeningScene.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/16/23.
//

import SpriteKit

class OpeningScene: SKScene {
    
    let highScoreLabel = SKLabelNode(fontNamed: k.font)
    let startButton = SKLabelNode(fontNamed: k.fontBold)
    let resetLabel = SKLabelNode(fontNamed: k.font)
    var highScore: Int = 0 {
        didSet {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        startButton.position = CGPoint(x: frame.width / 2, y: 150)
        startButton.zPosition = 1
        startButton.name = "start"
        startButton.text = "START"
        addChild(startButton)
        
        highScoreLabel.position = CGPoint(x: 384, y: 914)
        highScoreLabel.zPosition = 1
        highScoreLabel.name = "hiscore"
        highScoreLabel.text = "0000"
        addChild(highScoreLabel)
        
        resetLabel.position = CGPoint(x: frame.width - 100, y: 100)
        resetLabel.zPosition = 1
        resetLabel.fontSize = 18
        resetLabel.name = "reset"
        resetLabel.text = "RESET HI-SCORE"
        addChild(resetLabel)
        
        highScore = UserDefaults.standard.integer(forKey: k.hiScore)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "start" {
            // Set the default values for a new game
            UserDefaults.standard.set(0, forKey: k.score)
            UserDefaults.standard.set(2, forKey: k.lives)
            UserDefaults.standard.set(0, forKey: k.invadersDestroyed)
            UserDefaults.standard.set(0, forKey: k.shotsFired)
            
            // Open the game scene and begin play
            if let nextScene = GameScene(fileNamed: "GameScene"){
                nextScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 1)
                view?.presentScene(nextScene, transition: transition)
            }
        } else if tapped.name == "reset" {
            // Reset the Hi-Score value
            highScore = 0
            UserDefaults.standard.set(0, forKey: k.hiScore)
        } else {
            return
        }
    }
}
