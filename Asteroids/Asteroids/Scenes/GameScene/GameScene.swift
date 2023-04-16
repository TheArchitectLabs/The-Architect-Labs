//
//  GameScene.swift
//  Asteroids
//
//  Created by Michael & Diana Pascucci on 2/5/23.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - PROPERTIES
    let player: Player = Player(imageNamed: "ship-still")
    
    let thrustSound = SKAudioNode(fileNamed: "thrust.wav")
    
    var isRotatingLeft: Bool = false
    var isRotatingRight: Bool = false
    var rotation: CGFloat = 0
    var offset: CGFloat = .pi
    var isThrusterOn: Bool = false
    
    var enemyExists: Bool = false
    var randomEnemyTime: Double = 0
    var lastEnemyBullet: CFTimeInterval = 0
    
    var level: Int = 1
    var lives: Int = 3
    var maxAsteroids: Int = 11
    var totalAsteroids: Int = 0
    var isPlayerAlive: Bool = true
    
    // MARK: - didMove - Setup the scene
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Create the background and buttons
        createButtonsAndBackground()
        
        // Create the player
        player.setup()
        addChild(player)
        
        // Create the asteroids in a random place
        for _ in 1...maxAsteroids {
            let randomX: Int = Int.random(in: 0...1024)
            let randomY: Int = Int.random(in: 0...768)
            
            let asteroid: Asteroid = Asteroid(imageNamed: "asteroid")
            asteroid.setUp(atX: randomX, atY: randomY, withWidth: 120, withHeight: 120, withName: "asteroid-large")
            addChild(asteroid)
            totalAsteroids += 1
        }
        
        // Set a random time between 15 and 75 seconds to send out the first enemy ship
        randomEnemyTime = Double.random(in: 900...4500)
    }
    
    // MARK: - touchesBegan - What to do when a touch is registered
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = nodes(at: location)
        guard let tapped = tappedNode.first else { return }
        
        switch tapped.name {
        case "left":
            isRotatingLeft = true
            isRotatingRight = false
        case "right":
            isRotatingLeft = false
            isRotatingRight = true
        case "fire":
            player.shoot(rotation: rotation)
        case "thrust":
            isThrusterOn = true
            addChild(thrustSound)
        default:
            print("Touch Began - Nothing to do here")
        }
    }
    
    // MARK: - touchesEnded - What to do when a touch is removed
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = nodes(at: location)
        guard let tapped = tappedNode.first else { return }

        if tapped.name == "left" || tapped.name == "right" {
            isRotatingLeft = false
            isRotatingRight = false
        } else if tapped.name == "thrust" {
            isThrusterOn = false
            thrustSound.removeFromParent()
        } else {
            // Do nothing
        }
    }
    
    // MARK: - touchesMoved - What to do when a touch is moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        for touch in touches {
            let touchLocation = touch.location(in: self)
            let touchNodes = nodes(at: touchLocation)
            guard let tappedNode = touchNodes.first else { return }
            
            if tappedNode.contains(childNode(withName: "background")!) {
                isRotatingLeft = false
                isRotatingRight = false
                isThrusterOn = false
            }
        }
    }
    
    // MARK: - update - refreshes the screen with changes and adjustments
    override func update(_ currentTime: TimeInterval) {
        guard isPlayerAlive else { return }
        // Force the player to wrap around the screen continuously
        if player.position.y > 768 { player.position.y = 0 }
        if player.position.y < 0 { player.position.y = 768 }
        if player.position.x > 1024 { player.position.x = 0 }
        if player.position.x < 0 { player.position.x = 1024 }
        
        // Rotate the player left or right until the Left or Right button is released
        if isRotatingLeft {
            offset += 6
            if abs(offset) ==  360 { offset = 0 }
            rotation = (.pi / 180) * offset
            player.zRotation = rotation
        } else if isRotatingRight {
            offset -= 6
            if abs(offset) ==  360 { offset = 0 }
            rotation = (.pi / 180) * offset
            player.zRotation = rotation
        }
        
        // Turn on the thrusters until the Thrust button is released
        if isThrusterOn {
            player.startThrust(rotation: rotation)
        } else {
            player.stopThrust()
        }
        
        // Remove player bullets that have gone off screen. They do not wrap around like the player
        // Might need to change this later to a certain distance with wrapping
        enumerateChildNodes(withName: "playerBullet") { node, stop in
            if node.position.x < 0 || node.position.x > 1024 || node.position.y < 0 || node.position.y > 768 {
                node.removeFromParent()
            }
        }
        
        // Move the asteroids and force them to wrap around the screen continously
        for node in self.children {
            if let theAsteroid: Asteroid = node as? Asteroid {
                theAsteroid.move()
                if theAsteroid.position.y > 768 { theAsteroid.position.y = 0 }
                if theAsteroid.position.y < 0 { theAsteroid.position.y = 768 }
                if theAsteroid.position.x > 1024 { theAsteroid.position.x = 0 }
                if theAsteroid.position.x < 0 { theAsteroid.position.x = 1024 }
            }
        }
    }
    
    // MARK: - didBegin - Contact Deletegate to handle physics contacts
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        switch secondNode.name {
        case "player":
            // Player was hit by asteroid, enemy, or enemy bullet
            // Remove player; Break/Destroy asteroid OR Remove enemy or enemy bullet
            firstNode.removeFromParent()
            
        case "playerBullet":
            if firstNode.name == "enemy" {
                // Player bullet hit an enemy; Destroy the enemy and the player bullet
                firstNode.removeFromParent()
                secondNode.removeFromParent()
            } else {
                // Player bullet hit an asteroid; Break or Destroy the asteroid and remove the player bullet
                if firstNode.name == "asteroid-large" || firstNode.name == "asteroid-medium" {
                    let remove: SKAction = SKAction.removeFromParent()
                    let create: SKAction = SKAction.run {
                        for _ in 0...1 {
                            let asteroid: Asteroid = Asteroid(imageNamed: "asteroid")
                            asteroid.setUp(atX: Int(firstNode.position.x),
                                           atY: Int(firstNode.position.y),
                                           withWidth: firstNode.name == "asteroid-large" ? 48 : 24,
                                           withHeight: firstNode.name == "asteroid-large" ? 48 : 24,
                                           withName: firstNode.name == "asteroid-large" ? "asteroid-medium" : "asteroid-small")
                            self.addChild(asteroid)
                        }
                    }
                    let sound : SKAction = SKAction.playSoundFileNamed(firstNode.name == "asteroid-large" ? "bangLarge.wav" : "bangMedium.wav", waitForCompletion: false)
                    let group: SKAction = SKAction.group([create, sound])
                    let sequence: SKAction = SKAction.sequence([group, remove])
                    firstNode.run(sequence)
                    self.totalAsteroids += 1
                    secondNode.removeFromParent()
                } else {
                    let remove: SKAction = SKAction.removeFromParent()
                    let sound: SKAction = SKAction.playSoundFileNamed("bangSmall.wav", waitForCompletion: false)
                    let group: SKAction = SKAction.group([remove, sound])
                    firstNode.run(group)
                    self.totalAsteroids -= 1
                    secondNode.removeFromParent()
                    
                    if self.totalAsteroids == 0 {
                        print("Everything has been destroyed - Next level!")
                    }
                }
            }
        case "enemy":
            // Enemy was hit by asteroid
            // Break/Destroy asteroid; Remove enemy
            print("Enemy hit by asteroid")
            secondNode.removeFromParent()
        case "enemyBullet":
            // Enemy bullet hit an asteroid
            // Break/Destroy asteroid; Remove enemy bullet
            secondNode.removeFromParent()
        default:
            print("Collision Detection: Nothing to do here")
        }
    }
    
    // MARK: - Creates the buttons and backgrounds
    func createButtonsAndBackground() {
        let leftButton = SKShapeNode(ellipseOf: CGSize(width: 64, height: 64))
        leftButton.position = CGPoint(x: 100, y: 100)
        leftButton.zPosition = 10
        leftButton.fillColor = .blue
        leftButton.strokeColor = .white
        leftButton.name = "left"
        addChild(leftButton)
        
        let rightButton = SKShapeNode(ellipseOf: CGSize(width: 64, height: 64))
        rightButton.position = CGPoint(x: 200, y: 100)
        rightButton.zPosition = 10
        rightButton.fillColor = .red
        rightButton.strokeColor = .white
        rightButton.name = "right"
        addChild(rightButton)
        
        let thrustButton = SKShapeNode(ellipseOf: CGSize(width: 64, height: 64))
        thrustButton.position = CGPoint(x: 824, y: 100)
        thrustButton.zPosition = 10
        thrustButton.fillColor = .red
        thrustButton.strokeColor = .white
        thrustButton.name = "thrust"
        addChild(thrustButton)
        
        let fireButton = SKShapeNode(ellipseOf: CGSize(width: 64, height: 64))
        fireButton.position = CGPoint(x: 924, y: 100)
        fireButton.zPosition = 10
        fireButton.fillColor = .blue
        fireButton.strokeColor = .white
        fireButton.name = "fire"
        addChild(fireButton)
        
        let background = SKSpriteNode(color: .black, size: CGSize(width: 1024, height: 768))
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -100
        background.name = "background"
        addChild(background)
    }
}
