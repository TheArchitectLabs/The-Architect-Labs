//
//  Garbage - Delete.swift
//  Asteroids
//
//  Created by Michael & Diana Pascucci on 2/20/23.
//

import Foundation

//enumerateChildNodes(withName: "enemy") { node, stop in
//
//        }

// See if the random enemy time has expired
//        if randomEnemyTime < 0 {
//            for node in self.children {
//                if let _: Enemy = node as? Enemy {
//                    // do nothing
//                } else {
//                    print("Create the enemy")
//                    let enemy: Enemy = Enemy(imageNamed: "enemy")
//                    enemy.setup()
//                    addChild(enemy)
//                    print("Move the enemy")
//                    enemyExists = enemy.move()
//                    randomEnemyTime = Double.random(in: 900...4500)
//                }
//            }
////            if childNode(withName: "enemy") != nil {
////                print("Enemy exists - should be shooting")
////                if currentTime - lastEnemyBullet > 1 {
////                    print("Shots fired")
////                    createEnemyBullet()
////                    lastEnemyBullet = currentTime
////                }
////            } else {
////                let enemy: Enemy = Enemy(imageNamed: "enemy")
////                enemy.setup()
////                addChild(enemy)
////                enemy.move()
////                randomEnemyTime = Double.random(in: 900...4500)
////            }
//        } else {
//            randomEnemyTime -= 1
//        }
