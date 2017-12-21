//
//  Ball.swift
//  Deflector Balls
//
//  Created by Brian Lim on 5/30/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
    
    func initialize() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.zPosition = 3
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
        self.physicsBody?.categoryBitMask = ColliderType.Ball
        self.physicsBody?.collisionBitMask = ColliderType.Border | ColliderType.Paddle | ColliderType.Button | ColliderType.EndWall
        self.physicsBody?.contactTestBitMask = ColliderType.Paddle | ColliderType.EndWall | ColliderType.Star
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.mass = 1.0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.allowsRotation = true
        
    }
}
