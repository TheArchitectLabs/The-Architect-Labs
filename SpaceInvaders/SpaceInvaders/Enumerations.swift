//
//  Enumerations.swift
//  SpaceInvaders
//
//  Created by Michael & Diana Pascucci on 1/20/23.
//

import Foundation

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case invader = 4
    case invaderWeapon = 8
    case block = 16
    case mysteryInvader = 32
}

enum MovementDirection {
    case right
    case left
    case downThenRight
    case downThenLeft
    case none
}
