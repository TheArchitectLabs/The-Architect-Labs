//
//  Asteroid.swift
//  Asteroids
//
//  Created by Michael & Diana Pascucci on 2/18/23.
//

import SpriteKit

class Asteroid: SKSpriteNode {
    
    var xMovement: CGFloat = 0
    var yMovement: CGFloat = 0
    
    func setUp(atX x: Int, atY y: Int, withWidth asteroidWidth: Int, withHeight asteroidHeight: Int, withName name: String) {
        guard let asteroidTexture: SKTexture = self.texture else { fatalError("No texture available") }
        
        xMovement = CGFloat.random(in: -2...2)
        yMovement = CGFloat.random(in: -2...2)
        
        self.size = CGSize(width: asteroidWidth, height: asteroidHeight)
        self.position = CGPoint(x: x, y: y)
        self.zPosition = 1
        self.name = name
        
        self.physicsBody = SKPhysicsBody(texture: asteroidTexture, size: CGSize(width: asteroidWidth, height: asteroidHeight))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionType.asteroid.rawValue
        self.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerBullet.rawValue | CollisionType.enemy.rawValue | CollisionType.enemyBullet.rawValue
        self.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerBullet.rawValue | CollisionType.enemy.rawValue | CollisionType.enemyBullet.rawValue
        self.physicsBody?.isDynamic = true
    }
    
    func move() {
        self.position = CGPoint(x: self.position.x + xMovement, y: self.position.y + yMovement)
    }
}
