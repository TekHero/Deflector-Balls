//
//  GameManager.swift
//  Deflector Balls
//
//  Created by Brian Lim on 5/30/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import SpriteKit
import UIKit

struct ColliderType {
    
    static let Ball: UInt32 = 1
    static let Border: UInt32 = 2
    static let Paddle: UInt32 = 3
    static let Button: UInt32 = 4
    static let EndWall: UInt32 = 5
    static let Star: UInt32 = 6
}

class GameManager {
    
    static let instance = GameManager()
    fileprivate init() {}
    
    var paddleIndex = Int(0)
    var paddles = ["BluePaddle","RedPaddle","GreenPaddle","OrangePaddle","YellowPaddle","PurplePaddle","LightGreenPaddle","BrownPaddle", "GradientBluePaddle","GradientGreenPaddle", "GradientOrangePaddle", "GradientRedPaddle", "GradientGreenAndBluePaddle", "GradientPurplePaddle", "RadialRedPaddle","RadialGreenPaddle","RadialBluePaddle","RadialYellowPaddle","RadialOrangePaddle","RadialPurplePaddle"]
    
    
    func incrementIndex() {
        
        paddleIndex += 1
        
        if paddleIndex == paddles.count {
            
            paddleIndex = 0
        }
    }
    
    func decrementIndex() {
        
        if paddleIndex == 0 {
            
            paddleIndex = paddles.count
        }
        
        paddleIndex -= 1
        
    }
    
    func getPaddle() -> String {
        
        return paddles[paddleIndex]
    }
    
    func randomBetweenNumbers(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    // Saving and Grabbing highscores
    func setHighscore(_ highscore: Int) {
        UserDefaults.standard.set(highscore, forKey: "HIGHSCORE")
    }
    
    func getHighscore() -> Int {
        return UserDefaults.standard.integer(forKey: "HIGHSCORE")
    }
}
