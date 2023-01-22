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
    let score1Label = SKLabelNode(fontNamed: k.font)
    let hiScoreLabel = SKLabelNode(fontNamed: k.font)
    let livesLabel = SKLabelNode(fontNamed: k.font)
    
    // Player and Invaders
    let player = SKSpriteNode(imageNamed: "Ship")
    let invaders: [String] = ["InvaderA", "InvaderB", "InvaderC"]
    var moveDirection: MovementDirection = .right
    var moveSound: String = "fastinvader3"
    
    // Scores and Lives
    var score1: Int = 0 {
        didSet {
            score1Label.text = String(format: "%04d", score1)
            UserDefaults.standard.set(score1, forKey: k.score)
            if score1 > hiscore {
                hiscore = score1
            }
        }
    }
    var hiscore: Int = 0 {
        didSet {
            hiScoreLabel.text = String(format: "%04d", hiscore)
            UserDefaults.standard.set(score1, forKey: "hiscore")
        }
    }
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
            UserDefaults.standard.set(lives, forKey: k.lives)
        }
    }
    var shotsFired: Int = 0
    var invadersDestroyed: Int = 0
    
    // Core Motion Manager for Player Movement
    let motionManager = CMMotionManager()
    
    // Other
    var isPlayerAlive: Bool = true
    var isGameStarted: Bool = false
    var timeOfLastMove: CFTimeInterval = 2.0
    var timePerMove: CFTimeInterval = 0.5
    var totalInvaders: Int = 55
    var timeOfLastShot: CFTimeInterval = 2.0
    var totalHits: Int = 55
    
    var invaderCompressed: Bool = false
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        motionManager.startAccelerometerUpdates()

        createParticles()
        createBreakableBarrier()
        addHeaderLabels()
        createPlayer()
        createInvaders()
        
        shotsFired = UserDefaults.standard.integer(forKey: k.shotsFired)
        invadersDestroyed = UserDefaults.standard.integer(forKey: k.invadersDestroyed)
        lives = UserDefaults.standard.integer(forKey: k.lives)
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
                    shooterShot.zPosition = k.zPosInvader
                    shooterShot.name = "invaderWeapon"
                    addChild(shooterShot)
                    
                    shooterShot.physicsBody = SKPhysicsBody(rectangleOf: shooterShot.size)
                    shooterShot.physicsBody?.categoryBitMask = CollisionType.invaderWeapon.rawValue
                    shooterShot.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
                    shooterShot.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
                    shooterShot.physicsBody?.isDynamic = false
                    
                    let move = SKAction.move(to: CGPoint(x: shooterShot.position.x, y: -50), duration: 1.0)
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
        playerShot.zPosition = k.zPosPlayer
        playerShot.name = "playerWeapon"
        addChild(playerShot)
        
        playerShot.physicsBody = SKPhysicsBody(rectangleOf: playerShot.size)
        playerShot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        playerShot.physicsBody?.collisionBitMask = CollisionType.invader.rawValue | CollisionType.invaderWeapon.rawValue
        playerShot.physicsBody?.contactTestBitMask = CollisionType.invader.rawValue | CollisionType.invaderWeapon.rawValue
        playerShot.physicsBody?.isDynamic = false
        
        let move = SKAction.move(to: CGPoint(x: playerShot.position.x, y: 1050), duration: 1.0)
        let sequence = SKAction.sequence([move, .removeFromParent()])
        let shotSound = SKAction.playSoundFileNamed("ShipBullet.wav", waitForCompletion: true)
        playerShot.run(SKAction.group([sequence, shotSound]))
        
        shotsFired += 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "playerWeapon" {
            guard isPlayerAlive else { return }
            
            if firstNode.name == "block" {
                // Player hit a barrier - remove the player weapon
                secondNode.removeFromParent()
                firstNode.removeFromParent()
            } else if firstNode.name == "invaderWeapon" {
                // Player hit an invader weapon - remove both
                secondNode.removeFromParent()
                firstNode.removeFromParent()
            } else {
                // Player hit an invader - remove the invader and player weapon
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = firstNode.position
                    addChild(explosion)
                }
                score1 += firstNode.name == "InvaderA" ? 30 : firstNode.name == "InvaderB" ? 20 : 10
                invadersDestroyed += 1
                totalInvaders -= 1
                scene?.run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: true))
                secondNode.removeFromParent()
                firstNode.removeFromParent()
                if totalInvaders == 0 {
                    isGameStarted = false
                    // Destroy all remaining barrier blocks
                    enumerateChildNodes(withName: "block") { node, _ in node.removeFromParent() }
                    // Save the shots fired and total invaders destroyed to UserDefaults
                    UserDefaults.standard.set(shotsFired, forKey: k.shotsFired)
                    UserDefaults.standard.set(invadersDestroyed, forKey: k.invadersDestroyed)
                    // Delay 2 seconds then show the summary scene
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if let nextScene = GameScene(fileNamed: "SummaryScene"){
                            nextScene.scaleMode = self.scaleMode
                            let transition = SKTransition.flipHorizontal(withDuration: 2)
                            self.view?.presentScene(nextScene, transition: transition)
                        }
                    }
                }
            }
        } else if secondNode.name == "invaderWeapon" {
            // Invader hit a barrier - remove the invader weapon
            secondNode.removeFromParent()
            firstNode.removeFromParent()
        } else {
            // Invader hit the player - remove the player and invader weapon
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            scene?.run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: true))
            secondNode.removeFromParent()
            firstNode.removeFromParent()
            
            if lives == 0 {
                isGameStarted = false
                isPlayerAlive = false
                let gameOver = SKSpriteNode(imageNamed: "gameOver")
                gameOver.position = CGPoint(x: 384, y: 512)
                gameOver.zPosition = 100
                addChild(gameOver)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if let openScene = GameScene(fileNamed: "OpeningScene"){
                        openScene.scaleMode = self.scaleMode
                        let transition = SKTransition.fade(withDuration: 1)
                        self.view?.presentScene(openScene, transition: transition)
                    }
                }
            } else {
                isPlayerAlive = false
                lives -= 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.createPlayer()
                }
            }
        }
    }
    
    // MARK: - NODES
    // Particles, Barriers, and Labels
    func createParticles() {
        guard let particles = SKEmitterNode(fileNamed: "SpaceDust") else { fatalError("Could not load particle file") }
        particles.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        particles.zPosition = k.zPosParticles
        particles.advanceSimulationTime(10)
        addChild(particles)
    }
    
    func createBreakableBarrier() {
        for barrier in 0...3 {
            let startX = 132 + (barrier * 72) + (barrier * 72)
            
            for row in 1...3 {
                for col in 0...5 {
                    let block = SKSpriteNode(color: .red, size: CGSize(width: 12, height: 24))
                    block.position = CGPoint(x: startX + (Int(block.frame.width) * col), y: 250 + Int(block.frame.height) * row)
                    block.zPosition = k.zPosPlayer
                    block.name = "block"
                    addChild(block)
                    
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
                    block.physicsBody?.categoryBitMask = CollisionType.barrier.rawValue
                    block.physicsBody?.collisionBitMask = CollisionType.invaderWeapon.rawValue | CollisionType.playerWeapon.rawValue
                    block.physicsBody?.contactTestBitMask = CollisionType.invaderWeapon.rawValue | CollisionType.playerWeapon.rawValue
                    block.physicsBody?.isDynamic = true
                }
            }
        }
    }
    
    func addHeaderLabels() {
        score1Label.position = CGPoint(x: 123.5, y: 912)
        score1Label.zPosition = k.zPosLabels
        score1Label.name = "label"
        score1 = UserDefaults.standard.integer(forKey: k.score)
        addChild(score1Label)

        hiScoreLabel.position = CGPoint(x: 383.5, y: 912)
        hiScoreLabel.zPosition = k.zPosLabels
        hiScoreLabel.name = "label"
        hiscore = UserDefaults.standard.integer(forKey: k.hiScore)
        addChild(hiScoreLabel)
    }
    
    // Player
    func createPlayer() {
        player.size = k.playerDims
        player.position = CGPoint(x: frame.width / 2, y: 76)
        player.zPosition = k.zPosPlayer
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
                invader.position = CGPoint(x: Int(k.invaderDims.width * 1.5) * col, y: 800 - (row * Int(k.invaderDims.height * 1.5)))
                invader.zPosition = k.zPosInvader
                invader.name = invaderSprite
                addChild(invader)
                
                invader.physicsBody = SKPhysicsBody(texture: invader.texture!, size: k.invaderDims)
                invader.physicsBody?.categoryBitMask = CollisionType.invader.rawValue
                invader.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
                invader.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
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
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .none:
                break
            }
            let compress = SKAction.setTexture(SKTexture(imageNamed: self.invaderCompressed ? "\(node.name!)_01" : "\(node.name!)_00"))
            node.run(compress)
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
            timePerMove = 0.0625
        case 7...13:
            moveSound = "fastinvader1"
            timePerMove = 0.125
        case 14...27:
            moveSound = "fastinvader2"
            timePerMove = 0.25
        default:
            moveSound = "fastinvader3"
            timePerMove = 0.5
        }
    }
}
