//
//  SummaryScene.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/18/23.
//

import SpriteKit

class SummaryScene: SKScene {
    
    // MARK: - PROPERTIES
    // Labels
    let score1Label = SKLabelNode(fontNamed: k.font)
    let hiScoreLabel = SKLabelNode(fontNamed: k.font)
    let livesLabel = SKLabelNode(fontNamed: k.font)
    
    let shotsLabel = SKLabelNode(fontNamed: k.font)
    let destroyedLabel = SKLabelNode(fontNamed: k.font)
    let accuracyLabel = SKLabelNode(fontNamed: k.font)
    let bonusLabel = SKLabelNode(fontNamed: k.font)

    let timerLabel = SKLabelNode(fontNamed: k.fontBold)
    
    // Scores and Lives
    var score1: Int = 0
    var hiscore: Int = 0
    var lives: Int = 0 {
        didSet {
            enumerateChildNodes(withName: "lifeSprite") { node, _ in
                node.removeFromParent()
            }
            for i in 0..<lives {
                let liveSprite = SKSpriteNode(imageNamed: "Ship")
                liveSprite.size = k.playerDims
                liveSprite.name = "lifeSprite"
                liveSprite.position = CGPoint(x: (670 - Int(liveSprite.frame.width)) + (Int(liveSprite.frame.width + 10) * i), y: 925)
                liveSprite.zPosition = k.zPosLabels
                addChild(liveSprite)
            }
        }
    }
    var countdown: Int = 0 {
        didSet {
            timerLabel.text = String(format: "%04d", countdown)
        }
    }
    var shotsFired: Int = 0
    var invadersDestroyed: Int = 0
    var accuracy: Double = 0
    var bonus: Int = 0
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        getDefaults()

        score1Label.position = CGPoint(x: 123.5, y: 912)
        score1Label.zPosition = k.zPosLabels
        score1Label.name = "label"
        score1Label.text = String(format: "%04d", score1)
        addChild(score1Label)
        
        hiScoreLabel.position = CGPoint(x: 383.5, y: 912)
        hiScoreLabel.zPosition = k.zPosLabels
        hiScoreLabel.name = "label"
        hiScoreLabel.text = String(format: "%04d", hiscore)
        addChild(hiScoreLabel)
        
        timerLabel.position = CGPoint(x: 516, y: 320)
        timerLabel.zPosition = k.zPosLabels
        timerLabel.name = "label"
        addChild(timerLabel)
        
        shotsLabel.position = CGPoint(x: 480, y: 585)
        shotsLabel.zPosition = k.zPosLabels
        shotsLabel.name = "label"
        shotsLabel.text = String(format: "%04d", shotsFired)
        addChild(shotsLabel)
        
        destroyedLabel.position = CGPoint(x: 480, y: 537)
        destroyedLabel.zPosition = k.zPosLabels
        destroyedLabel.name = "label"
        destroyedLabel.text = String(format: "%04d", invadersDestroyed)
        addChild(destroyedLabel)
        
        accuracyLabel.position = CGPoint(x: 480, y: 484)
        accuracyLabel.zPosition = k.zPosLabels
        accuracyLabel.name = "label"
        accuracyLabel.text = String(format: "%.1f%%", accuracy)
        addChild(accuracyLabel)
        
        bonusLabel.position = CGPoint(x: 480, y: 441)
        bonusLabel.zPosition = k.zPosLabels
        bonusLabel.name = "label"
        bonusLabel.text = String(format: "%04d", bonus)
        addChild(bonusLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if countdown > 0 {
            countdown -= 1
        } else {
            UserDefaults.standard.set(0, forKey: k.invadersDestroyed)
            UserDefaults.standard.set(0, forKey: k.shotsFired)
            if let nextScene = GameScene(fileNamed: "GameScene"){
                nextScene.scaleMode = self.scaleMode
                let transition = SKTransition.flipHorizontal(withDuration: 2)
                self.view?.presentScene(nextScene, transition: transition)
            }
        }
    }
    
    func getDefaults() {
        score1 = UserDefaults.standard.integer(forKey: k.score)
        hiscore = UserDefaults.standard.integer(forKey: k.hiScore)
        lives = UserDefaults.standard.integer(forKey: k.lives)
        shotsFired = UserDefaults.standard.integer(forKey: k.shotsFired)
        invadersDestroyed = UserDefaults.standard.integer(forKey: k.invadersDestroyed)
        accuracy = (Double(invadersDestroyed) / Double(shotsFired) * 100)
        bonus = Int(accuracy) * 10
        score1 += bonus
        if score1 > hiscore {
            hiscore = score1
            UserDefaults.standard.set(score1, forKey: k.hiScore)
        }
        UserDefaults.standard.set(score1, forKey: k.score)
        countdown = 600
    }
}
