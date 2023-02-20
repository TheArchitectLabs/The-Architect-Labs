//
//  Enemy.swift
//  Asteroids
//
//  Created by Michael & Diana Pascucci on 2/19/23.
//

import SpriteKit

class Enemy: SKSpriteNode {
    
    func setup() {
        self.size = CGSize(width: 48, height: 48)
        self.position = CGPoint(x: 1074, y: 200)
        self.zPosition = 1
        self.name = "enemy"
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        self.physicsBody?.collisionBitMask = CollisionType.asteroid.rawValue | CollisionType.player.rawValue | CollisionType.playerBullet.rawValue
        self.physicsBody?.contactTestBitMask = CollisionType.asteroid.rawValue | CollisionType.player.rawValue | CollisionType.playerBullet.rawValue
        self.physicsBody?.isDynamic = true
    }
    
    func move() -> Bool {
        let movement = SKAction.move(to: CGPoint(x: -50, y: 200), duration: 8)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        
        let enemySound = SKAction.repeatForever(SKAction.playSoundFileNamed("saucerBig.wav", waitForCompletion: true))
        let actionGroup = SKAction.group([sequence, enemySound])
        
        self.run(actionGroup)
        return false
    }
    
    func shoot(playerX: CGFloat, playerY: CGFloat) {
        let offsetX: CGFloat = CGFloat.random(in: -75...75)
        let offsetY: CGFloat = CGFloat.random(in: -75...75)
        let shotPosition: CGPoint = CGPoint(x: playerX + offsetX, y: playerY + offsetY)
        
        let bullet = SKShapeNode(ellipseOf: CGSize(width: 3, height: 3))
        bullet.name = "enemyBullet"
        bullet.zPosition = 0
        bullet.position = CGPoint(x: self.position.x, y: self.position.y)
        bullet.fillColor = .red
        bullet.strokeColor = .white
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        bullet.physicsBody?.categoryBitMask = CollisionType.enemyBullet.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.asteroid.rawValue | CollisionType.player.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.asteroid.rawValue | CollisionType.player.rawValue
        bullet.physicsBody?.isDynamic = true
        self.addChild(bullet)
        
        let move = SKAction.move(to: shotPosition, duration: 1)
        let enemyShotFired = SKAction.playSoundFileNamed("fire.wav", waitForCompletion: false)
        let enemyBulletGroup = SKAction.group([move, enemyShotFired])
        let sequence = SKAction.sequence([enemyBulletGroup, .removeFromParent()])
        
        bullet.run(sequence)
    }
}
