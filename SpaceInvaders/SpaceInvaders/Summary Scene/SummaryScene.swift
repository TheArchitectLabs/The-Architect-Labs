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
    let scoreLabel = SKLabelNode(fontNamed: k.font)
    let hiScoreLabel = SKLabelNode(fontNamed: k.font)
    let livesLabel = SKLabelNode(fontNamed: k.fontBold)
    let wavesLabel = SKLabelNode(fontNamed: k.font)
    
    let shotsLabel = SKLabelNode(fontNamed: k.font)
    let destroyedLabel = SKLabelNode(fontNamed: k.font)
    let accuracyLabel = SKLabelNode(fontNamed: k.font)
    let bonusLabel = SKLabelNode(fontNamed: k.font)

    let timerLabel = SKLabelNode(fontNamed: k.fontBold)
    
    let extraLifeLabel = SKLabelNode(fontNamed: k.fontBold)
    
    // Scores and Lives
    var score: Int = 0
    var hiscore: Int = 0
    var lives: Int = 0 {
        didSet {
            UserDefaults.standard.set(lives, forKey: k.lives)
            livesLabel.text = String(format: "%01d", lives)
        }
    }
    var countdown: Int = 0 {
        didSet {
            timerLabel.text = String(format: "%04d", countdown)
        }
    }
    var level: Int = 0
    var shotsFired: Int = 0
    var invadersDestroyed: Int = 0
    var accuracy: Double = 0
    var bonus: Int = 0
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        getDefaults()

        scoreLabel.position = CGPoint(x: 123.5, y: 912)
        scoreLabel.zPosition = k.zPosLabels
        scoreLabel.name = "label"
        scoreLabel.text = String(format: "%04d", score)
        addChild(scoreLabel)
        
        hiScoreLabel.position = CGPoint(x: 383.5, y: 912)
        hiScoreLabel.zPosition = k.zPosLabels
        hiScoreLabel.name = "label"
        hiScoreLabel.text = String(format: "%04d", hiscore)
        addChild(hiScoreLabel)
        
        livesLabel.position = CGPoint(x: 656.5, y: 912)
        livesLabel.zPosition = 1
        livesLabel.name = "label"
        livesLabel.fontColor = .red
        livesLabel.fontSize = 18
        lives = UserDefaults.standard.integer(forKey: k.lives)
        addChild(livesLabel)
        
        extraLifeLabel.position = CGPoint(x: 384, y: 774)
        extraLifeLabel.zPosition = k.zPosLabels
        extraLifeLabel.name = "label"
        extraLifeLabel.fontColor = .red
        extraLifeLabel.text = "** EXTRA LIFE AWARDED **"
        addChild(extraLifeLabel)
        
        timerLabel.position = CGPoint(x: 516, y: 274)
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
        
        wavesLabel.position = CGPoint(x: 480, y: 383)
        wavesLabel.zPosition = k.zPosLabels
        wavesLabel.name = "label"
        wavesLabel.text = String(format: "%04d", level - 1)
        addChild(wavesLabel)
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
        score = UserDefaults.standard.integer(forKey: k.score)
        hiscore = UserDefaults.standard.integer(forKey: k.hiScore)
        level = UserDefaults.standard.integer(forKey: k.level)
        lives = UserDefaults.standard.integer(forKey: k.lives)
        shotsFired = UserDefaults.standard.integer(forKey: k.shotsFired)
        invadersDestroyed = UserDefaults.standard.integer(forKey: k.invadersDestroyed)
        accuracy = (Double(invadersDestroyed) / Double(shotsFired) * 100)
        bonus = Int(accuracy) * 10
        score += bonus
        if score > hiscore {
            hiscore = score
            UserDefaults.standard.set(score, forKey: k.hiScore)
        }
        UserDefaults.standard.set(score, forKey: k.score)
        
        let wavesCompleted: Int = level - 1
        if wavesCompleted.isMultiple(of: 3) {
            extraLifeLabel.isHidden = false
            lives += 1
        } else {
            extraLifeLabel.isHidden = true
        }
        
        countdown = 500
    }
}
