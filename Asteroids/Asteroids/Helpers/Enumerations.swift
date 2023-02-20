//
//  Enumerations.swift
//  Asteroids
//
//  Created by Michael & Diana Pascucci on 2/19/23.
//

import Foundation

enum CollisionType: UInt32 {
    case asteroid = 1
    case enemy = 2
    case enemyBullet = 4
    case player = 8
    case playerBullet = 16
}
