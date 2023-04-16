//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/1/23.
//

import SpriteKit
import GameplayKit
import CoreMotion

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - PROPERTIES
    // Labels
    let score1Label = SKLabelNode(fontNamed: k.fonts.normal)
    let hiScoreLabel = SKLabelNode(fontNamed: k.fonts.normal)
    let livesLabel = SKLabelNode(fontNamed: k.fonts.bold)
    
    // Player and Invaders
    let player = SKSpriteNode(imageNamed: "Ship")
    let invaders: [String] = ["InvaderA", "InvaderB", "InvaderC"]
    var moveDirection: MovementDirection = .right
    var moveSound: String = "fastinvader3"
    
    // Scores and Lives
    var score: Int = 0 {
        didSet {
            score1Label.text = String(format: "%04d", score)
            UserDefaults.standard.set(score, forKey: k.userDefaults.score)
            if score > hiscore {
                hiscore = score
                UserDefaults.standard.set(score, forKey: k.userDefaults.hiScore)
            }
        }
    }
    var hiscore: Int = 0 {
        didSet {
            hiScoreLabel.text = String(format: "%04d", hiscore)
            UserDefaults.standard.set(hiscore, forKey: k.userDefaults.hiScore)
        }
    }
    var lives: Int = 0 {
        didSet {
            livesLabel.text = String(format: "%01d", lives)
            UserDefaults.standard.set(lives, forKey: k.userDefaults.lives)
        }
    }
    var level: Int = 1
    var shotsFired: Int = 0
    var invadersDestroyed: Int = 0
    
    // Core Motion Manager for Player Movement
    let motionManager = CMMotionManager()
    
    // Other
    var isPlayerAlive: Bool = true
    var isGameStarted: Bool = false
    var timeOfLastMove: CFTimeInterval = 2.0
    var timePerMove: CFTimeInterval = 0.5
    var adjustTimeForHeight: CFTimeInterval = 0.0
    var adjustLevelForHeight: Double = 0.0
    var totalInvaders: Int = 55
    var timeOfLastShot: CFTimeInterval = 2.0
    var totalHits: Int = 55
    
    var randomBonusTime: Int = 0
    var bonusPosition: Int = 0
    var bonusScore: Int = 0
    var bonusLeftRight: Bool = false
    
    var invaderCompressed: Bool = false
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        motionManager.startAccelerometerUpdates()

        shotsFired = UserDefaults.standard.integer(forKey: k.userDefaults.shotsFired)
        invadersDestroyed = UserDefaults.standard.integer(forKey: k.userDefaults.invadersDestroyed)
        lives = UserDefaults.standard.integer(forKey: k.userDefaults.lives)
        hiscore = UserDefaults.standard.integer(forKey: k.userDefaults.hiScore)
        score = UserDefaults.standard.integer(forKey: k.userDefaults.score)
        level = UserDefaults.standard.integer(forKey: k.userDefaults.level)
        
        randomBonusTime = Int.random(in: 900...4500 )

        createParticles()
        createBreakableBlocks()
        addHeaderLabels()
        createPlayer()
        createInvaders()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameStarted {
            // Control the sound and movement speed of each invader
            if currentTime - timeOfLastMove >= timePerMove {
                let moveSound = SKAction.playSoundFileNamed(moveSound, waitForCompletion: true)
                let move = SKAction.run { self.moveInvaders() }
                let sequence = SKAction.sequence([move, moveSound])
                scene?.run(sequence)
                self.timeOfLastMove = currentTime
            }
            
            // Control the movement of the player
            if let accelerometerData = motionManager.accelerometerData {
                player.position.x += CGFloat(accelerometerData.acceleration.x * 50)
                
                if player.position.x < frame.minX {
                    player.position.x = frame.minX
                } else if player.position.x > frame.maxX {
                    player.position.x = frame.maxX
                }
            }
            
            // Randomly create mystery ship
            randomBonusTime -= 1
            if randomBonusTime == 0 {
                bonusLeftRight = Bool.random()
                createMysteryInvader(moveLeft: bonusLeftRight)
            }
            
            // Have a random invader shoot once per second
            if totalInvaders > 0 {
                if currentTime - timeOfLastShot > 1.0 {
                    self.timeOfLastShot = currentTime
                    var remainingInvaders = [SKNode]()
                    enumerateChildNodes(withName: "Invader*") { node, stop in
                        remainingInvaders.append(node)
                    }
                    let remainingInvaderIndex = Int(arc4random_uniform(UInt32(remainingInvaders.count)))
                    let shooter = remainingInvaders[remainingInvaderIndex]
                    let shooterShot = SKSpriteNode(color: .red, size: k.invaderWeaponDims)
                    shooterShot.position = shooter.position
                    shooterShot.zPosition = k.layers.invader
                    shooterShot.name = "invaderWeapon"
                    addChild(shooterShot)

                    shooterShot.physicsBody = SKPhysicsBody(rectangleOf: shooterShot.size)
                    shooterShot.physicsBody?.categoryBitMask = CollisionType.invaderWeapon.rawValue
                    shooterShot.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.block.rawValue
                    shooterShot.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.block.rawValue
                    shooterShot.physicsBody?.isDynamic = false

                    let move = SKAction.move(to: CGPoint(x: shooterShot.position.x, y: 25), duration: 1.0)
                    let sequence = SKAction.sequence([move, .removeFromParent()])
                    let shotSound = SKAction.playSoundFileNamed("InvaderBullet.wav", waitForCompletion: true)
                    shooterShot.run(SKAction.group([sequence, shotSound]))
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isGameStarted = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard childNode(withName: "playerWeapon") == nil else { return }
        guard isPlayerAlive else { return }
        
        let playerShot = SKSpriteNode(color: .green, size: k.playerWeaponDims)
        playerShot.position = player.position
        playerShot.zPosition = k.layers.player
        playerShot.name = "playerWeapon"
        addChild(playerShot)
        
        playerShot.physicsBody = SKPhysicsBody(rectangleOf: playerShot.size)
        playerShot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        playerShot.physicsBody?.collisionBitMask = CollisionType.invader.rawValue | CollisionType.invaderWeapon.rawValue | CollisionType.block.rawValue | CollisionType.mysteryInvader.rawValue
        playerShot.physicsBody?.contactTestBitMask = CollisionType.invader.rawValue | CollisionType.invaderWeapon.rawValue | CollisionType.block.rawValue | CollisionType.mysteryInvader.rawValue
        playerShot.physicsBody?.isDynamic = false
        
        let move = SKAction.move(to: CGPoint(x: playerShot.position.x, y: 1050), duration: 1.0)
        let sequence = SKAction.sequence([move, .removeFromParent()])
        let shotSound = SKAction.playSoundFileNamed("ShipBullet.wav", waitForCompletion: true)
        playerShot.run(SKAction.group([sequence, shotSound]))
        
        shotsFired += 1
        bonusPosition = shotsFired % 15
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        switch secondNode.name {
        case "invaderWeapon": // Invader weapon hit the block - Remove both (1 & 2) - No explosions
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        case "player": // Invader or Invader weapon hit the player - Remove both (1 & 2) - Player explosion (2)
            firstNode.removeFromParent()
            secondNode.removeFromParent()
            createExplosion(at: secondNode)
            
            if lives == 0 {
                isGameStarted = false
                isPlayerAlive = false
                let gameOver = SKSpriteNode(imageNamed: "gameOver")
                gameOver.position = CGPoint(x: 384, y: 512)
                gameOver.setScale(0.9)
                gameOver.zPosition = 100
                addChild(gameOver)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if let openScene = GameScene(fileNamed: k.scenes.open){
                        openScene.scaleMode = self.scaleMode
                        let transition = SKTransition.fade(withDuration: 1)
                        self.view?.presentScene(openScene, transition: transition)
                    }
                }
            } else {
                isPlayerAlive = false
                lives -= 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.createPlayer()
                }
            }
        case "playerWeapon":
            if firstNode.name == "block" {
                // Player weapon hit a block - Remove both - No explosion
                firstNode.removeFromParent()
                secondNode.removeFromParent()
            } else if firstNode.name == "mystery" {
                // Player weapon hit a Mystery invader - Remove both - Mystery invader explosion (1)
                createExplosion(at: firstNode)
                bonusScore = k.mysteryBonus[bonusPosition]
                score += bonusScore
                randomBonusTime = Int.random(in: 900...4500 )
                secondNode.removeFromParent()
                firstNode.removeFromParent()
            } else if firstNode.name == "invaderweapon" {
                // Player weapon hit an Invader weapon - Remove both - No explosion
                secondNode.removeFromParent()
                firstNode.removeFromParent()
            } else {
                // Player weapon hit an invader - Remove both - Invader explosion (1)
                createExplosion(at: firstNode)
                score += firstNode.name == "InvaderA" ? 30 : firstNode.name == "InvaderB" ? 20 : 10
                invadersDestroyed += 1
                totalInvaders -= 1
                secondNode.removeFromParent()
                firstNode.removeFromParent()
                if totalInvaders == 0 {
                    // Increase the level number
                    level += 1
                    // Destroy all remaining barrier blocks and enemy weapons
                    enumerateChildNodes(withName: "block") { node, _ in node.removeFromParent() }
                    enumerateChildNodes(withName: "invaderweapon") { node, _ in node.removeFromParent() }
                    // Save the shots fired, total invaders destroyed, and level number to UserDefaults
                    UserDefaults.standard.set(shotsFired, forKey: k.userDefaults.shotsFired)
                    UserDefaults.standard.set(invadersDestroyed, forKey: k.userDefaults.invadersDestroyed)
                    UserDefaults.standard.set(level, forKey: k.userDefaults.level)
                    // Delay 2 seconds then show the summary scene
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isGameStarted = false
                        if let nextScene = GameScene(fileNamed: k.scenes.summary){
                            nextScene.scaleMode = self.scaleMode
                            let transition = SKTransition.flipHorizontal(withDuration: 2)
                            self.view?.presentScene(nextScene, transition: transition)
                        }
                    }
                }
            }
        default: // Invader hit block - Remove the block (2) - No explosions
            secondNode.removeFromParent()
        }
    }
    
    // MARK: - NODES
    // Particles, Barriers, and Labels
    func createParticles() {
        guard let particles = SKEmitterNode(fileNamed: "SpaceDust") else { fatalError("Could not load particle file") }
        particles.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        particles.zPosition = k.layers.particles
        particles.advanceSimulationTime(10)
        addChild(particles)
    }
    
    func createBreakableBlocks() {
        for barrier in 0...3 {
            let startX = 132 + (barrier * 72) + (barrier * 72)
            
            for row in 1...3 {
                for col in 0...5 {
                    let block = SKSpriteNode(color: .green, size: CGSize(width: 12, height: 24))
                    block.position = CGPoint(x: startX + (Int(block.frame.width) * col), y: 250 + Int(block.frame.height) * row)
                    block.zPosition = k.layers.player
                    block.name = "block"
                    addChild(block)
                    
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
                    block.physicsBody?.categoryBitMask = CollisionType.block.rawValue
                    block.physicsBody?.collisionBitMask = CollisionType.invaderWeapon.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.invader.rawValue
                    block.physicsBody?.contactTestBitMask = CollisionType.invaderWeapon.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.invader.rawValue
                    block.physicsBody?.isDynamic = true
                }
            }
        }
    }
    
    func addHeaderLabels() {
        score1Label.position = CGPoint(x: 123.5, y: 912)
        score1Label.zPosition = k.layers.labels
        score1Label.name = "label"
        score = UserDefaults.standard.integer(forKey: k.userDefaults.score)
        addChild(score1Label)

        hiScoreLabel.position = CGPoint(x: 383.5, y: 912)
        hiScoreLabel.zPosition = k.layers.labels
        hiScoreLabel.name = "label"
        hiscore = UserDefaults.standard.integer(forKey: k.userDefaults.hiScore)
        addChild(hiScoreLabel)
        
        livesLabel.position = CGPoint(x: 656.5, y: 912)
        livesLabel.zPosition = k.layers.labels
        livesLabel.name = "label"
        livesLabel.fontColor = .red
        livesLabel.fontSize = 18
        lives = UserDefaults.standard.integer(forKey: k.userDefaults.lives)
        addChild(livesLabel)
    }
    
    // Player
    func createPlayer() {
        player.size = k.playerDims
        player.position = CGPoint(x: frame.width / 2, y: 76)
        player.zPosition = k.layers.player
        player.name = "player"
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: k.playerDims)
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.invader.rawValue | CollisionType.invaderWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.invader.rawValue | CollisionType.invaderWeapon.rawValue
        player.physicsBody?.isDynamic = true
        
        isPlayerAlive = true
    }
    
    // Invaders
    func createInvaders() {
        var invaderSprite: String?
        var levelOffset: Int = 0
        
        levelOffset = level % 12
        if levelOffset == 0 {
            levelOffset = 1
        }
        adjustLevelForHeight = 1.0
        
        for row in 1...k.rows {
            if row == 1 {
                invaderSprite = invaders[0]
            } else if row == 2 || row == 3 {
                invaderSprite = invaders[1]
            } else {
                invaderSprite = invaders[2]
            }
            
            for col in 1...k.cols {
                let invader = SKSpriteNode(imageNamed: "\(invaderSprite!)_00")
                invader.size = k.invaderDims
                invader.position = CGPoint(x: Int(k.invaderDims.width * 1.5) * col, y: 810 - (levelOffset * 15) - (row * Int(k.invaderDims.height * 1.5)))
                invader.zPosition = k.layers.invader
                invader.name = invaderSprite
                addChild(invader)
                
                invader.physicsBody = SKPhysicsBody(texture: invader.texture!, size: k.invaderDims)
                invader.physicsBody?.categoryBitMask = CollisionType.invader.rawValue
                invader.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
                invader.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.block.rawValue
                invader.physicsBody?.isDynamic = true
            }
        }
        totalInvaders = 55
    }
    
    func moveInvaders() {
        determineMoveDirection()
        invaderSoundAndSpeed()
        invaderCompressed.toggle()
        
        enumerateChildNodes(withName: "Invader*") { [self] node, stop in
            switch self.moveDirection {
            case .right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .downThenLeft, .downThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 15)
            case .none:
                break
            }
            let compress = SKAction.setTexture(SKTexture(imageNamed: self.invaderCompressed ? "\(node.name!)_01" : "\(node.name!)_00"))
            node.run(compress)
        }
        
        if self.moveDirection == .downThenLeft || self.moveDirection == .downThenRight {
            adjustLevelForHeight += 1.0
            adjustTimeForHeight = (adjustLevelForHeight / 20) * 0.03125
        }
    }
    
    func determineMoveDirection() {
        var proposedMovementDirection: MovementDirection = moveDirection
        
        enumerateChildNodes(withName: "Invader*") { node, stop in
            switch self.moveDirection {
            case .right:
                if node.frame.maxX >= self.frame.width - 50 {
                    proposedMovementDirection = .downThenLeft
                    stop.pointee = true
                }
            case .left:
                if node.frame.minX <= 50 {
                    proposedMovementDirection = .downThenRight
                    stop.pointee = true
                }
            case .downThenRight:
                proposedMovementDirection = .right
                stop.pointee = true
            case .downThenLeft:
                proposedMovementDirection = .left
                stop.pointee = true
            default:
                break
            }
        }
        
        if (proposedMovementDirection != moveDirection) {
            moveDirection = proposedMovementDirection
        }
    }
    
    func invaderSoundAndSpeed() {
        switch totalInvaders {
        case 1...6:
            moveSound = "fastinvader4"
            timePerMove = 0.0625 - adjustTimeForHeight
        case 7...13:
            moveSound = "fastinvader1"
            timePerMove = 0.125 - adjustTimeForHeight
        case 14...27:
            moveSound = "fastinvader2"
            timePerMove = 0.25 - adjustTimeForHeight
        default:
            moveSound = "fastinvader3"
            timePerMove = 0.5 - adjustTimeForHeight
        }
    }
    
    func createMysteryInvader(moveLeft: Bool) {
        guard childNode(withName: "mystery") == nil else { return }
        
        let mysteryInvader = SKSpriteNode(imageNamed: "mystery_ship")
        mysteryInvader.setScale(0.3)
        mysteryInvader.position = moveLeft ? CGPoint(x: 800, y: 820) : CGPoint(x: -32, y: 820)
        mysteryInvader.zPosition = k.layers.invader
        mysteryInvader.name = "mystery"
        addChild(mysteryInvader)
        
        mysteryInvader.physicsBody = SKPhysicsBody(texture: mysteryInvader.texture!, size: mysteryInvader.size)
        mysteryInvader.physicsBody?.categoryBitMask = CollisionType.mysteryInvader.rawValue
        mysteryInvader.physicsBody?.collisionBitMask = CollisionType.playerWeapon.rawValue
        mysteryInvader.physicsBody?.contactTestBitMask = CollisionType.playerWeapon.rawValue
        mysteryInvader.physicsBody?.isDynamic = true
        
        let mysteryMove = moveLeft ? SKAction.move(to: CGPoint(x: -32, y: 820), duration: 5) : SKAction.move(to: CGPoint(x: 800, y: 820), duration: 5)
        let mysterySound = SKAction.repeatForever(SKAction.playSoundFileNamed("ufo_highpitch.wav", waitForCompletion: true))
        let mysterySequence = SKAction.sequence([mysteryMove, .removeFromParent()])
        mysteryInvader.run(SKAction.group([mysterySequence, mysterySound]))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.randomBonusTime = Int.random(in: 900...4500)
        }
    }
    
    func createExplosion(at node: SKNode) {
        let explosion = SKSpriteNode(imageNamed: "explosion2")
        explosion.size = CGSize(width: 48, height: 32)
        explosion.zPosition = k.layers.invader
        explosion.position = node.position
        explosion.name = "explosion"
        addChild(explosion)
        
        let fade = SKAction.fadeOut(withDuration: 0.4)
        let sound = SKAction.playSoundFileNamed(node.name == "player" ? "ShipHit.wav" : "InvaderHit.wav", waitForCompletion: true)
        let sequence = SKAction.sequence([fade, .removeFromParent()])
        
        let group = SKAction.group([sequence, sound])
        explosion.run(group)
        
        if node.name == "mystery" {
            let pointLabel = SKLabelNode(fontNamed: k.fonts.bold)
            pointLabel.fontSize = 20
            pointLabel.position = node.position
            pointLabel.text = String(k.mysteryBonus[bonusPosition])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.addChild(pointLabel)
                pointLabel.run(sequence)
            }
        }
    }
}
