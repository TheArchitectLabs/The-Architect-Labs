//
//  Player.swift
//  Asteroids
//
//  Created by Michael & Diana Pascucci on 2/19/23.
//

import SpriteKit

class Player: SKSpriteNode {
    
    func setup() {
        self.size = CGSize(width: 48, height: 48)
        self.position = CGPoint(x: 512, y: 384)
        self.zPosition = 1
        self.name = "player"
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.mass = 0.1
        self.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody?.collisionBitMask = CollisionType.asteroid.rawValue | CollisionType.enemy.rawValue | CollisionType.enemyBullet.rawValue
        self.physicsBody?.contactTestBitMask = CollisionType.asteroid.rawValue | CollisionType.enemy.rawValue | CollisionType.enemyBullet.rawValue
        self.physicsBody?.isDynamic = true
    }
    
    func startThrust(rotation: CGFloat) {
        self.texture = SKTexture(imageNamed: "ship-moving")
        let xVector: CGFloat = sin(rotation) * -0.3
        let yVector: CGFloat = cos(rotation) * 0.3
        let rotationVector: CGVector = CGVector(dx: xVector, dy: yVector)
        self.physicsBody?.applyImpulse(rotationVector)
    }
    
    func stopThrust() {
        self.texture = SKTexture(imageNamed: "ship-still")
    }
    
    func shoot(rotation: CGFloat) {
        let shotFired = SKAction.playSoundFileNamed("fire.wav", waitForCompletion: false)
        let bullet = SKShapeNode(ellipseOf: CGSize(width: 3, height: 3))
        bullet.name = "playerBullet"
        bullet.zPosition = 0
        bullet.position = CGPoint(x: self.position.x, y: self.position.y)
        bullet.fillColor = .white
        bullet.strokeColor = .white
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        bullet.physicsBody?.categoryBitMask = CollisionType.playerBullet.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.asteroid.rawValue | CollisionType.enemy.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.asteroid.rawValue | CollisionType.enemy.rawValue
        bullet.physicsBody?.isDynamic = true
        scene!.addChild(bullet)
        bullet.run(shotFired)
        
        let xVector: CGFloat = sin(rotation) * -0.3
        let yVector: CGFloat = cos(rotation) * 0.3
        let rotationVector: CGVector = CGVector(dx: xVector, dy: yVector)
        bullet.physicsBody?.applyImpulse(rotationVector)
    }
}
