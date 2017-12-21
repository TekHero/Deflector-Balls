//
//  GameplayScene.swift
//  Deflector Balls
//
//  Created by Brian Lim on 5/31/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameplayScene: SKScene, SKPhysicsContactDelegate {
    
    var paddle = SKSpriteNode()
    var tapToPlayScreen = SKSpriteNode()
    var star = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var scoreLbl = SKLabelNode()
    
    let pauseMenuBg = SKSpriteNode(imageNamed: "PauseMenuBG")
    let returnHomeBtn = SKSpriteNode(imageNamed: "ReturnHomeBtn")
    let pauseTitle = SKLabelNode(fontNamed: "Prototype")
    
    var firstImpact = false
    var isGamePaused = false
    var isAlive = false
    var isSpawnedOnce = false
    
    var isStarSpawnedOnce = false
    
    var ballNames = ["BlueBall", "RedBall", "GreenBall", "OrangeBall", "PurpleBall", "YellowBall", "BrownBall", "LightGreenBall"]
    
    let emitter = SKEmitterNode(fileNamed: "Smoke.sks")
    let emitter2 = SKEmitterNode(fileNamed: "Smoke.sks")
    
    var counter = 0

    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        initialize()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if counter >= 15 && isSpawnedOnce == false {
            
            spawnBall2()
            isSpawnedOnce = true
            
        }
        
    }
    
    func initialize() {
        emitter?.targetNode = self
        emitter2?.targetNode = self
        
        spawnPaddle()
        createScoreLabel()
        createTapToPlayScreen()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == pauseBtn {
                
                pauseBtn.run(SKAction.setTexture(SKTexture(imageNamed: "PauseBtnDown")))
                pauseBtn.run(SKAction.setTexture(SKTexture(imageNamed: "PauseBtn")))
            }
            
            if atPoint(location) == pauseMenuBg {
                
            }
            
            if atPoint(location) == returnHomeBtn {
                
                returnHomeBtn.texture = SKTexture(imageNamed: "ReturnHomeBtnDown")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == tapToPlayScreen {
                
                spawnWalls()
                spawnBall1()
                createPauseBtn()
                spawnCollectables()
                self.tapToPlayScreen.removeFromParent()
                self.isAlive = true
            }
            
            if atPoint(location) == pauseBtn {
                
                pauseBtn.run(SKAction.setTexture(SKTexture(imageNamed: "PauseBtn")))
                if isGamePaused == true {
                    
                    isGamePaused = false
                    self.scene?.isPaused = false
                    
                } else {
                    isGamePaused = true
                    self.scene?.isPaused = true
                    self.createPauseMenu()
                }
            }
            
            if atPoint(location) == pauseTitle {
                
                self.scene?.isPaused = false
                self.pauseMenuBg.removeFromParent()
                self.returnHomeBtn.removeFromParent()
                self.pauseTitle.removeFromParent()
                
            }
            
            if atPoint(location) == returnHomeBtn {
                
                returnHomeBtn.texture = SKTexture(imageNamed: "ReturnHomeBtn")
                
                self.removeAllActions()
                self.removeAllChildren()
                
                let mainMenu = MainMenuScene(fileNamed: "MainMenuScene")
                mainMenu?.scaleMode = .aspectFill
                self.view?.presentScene(mainMenu!, transition: SKTransition.fade(withDuration: 0.5))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if self.scene?.isPaused == false && self.isAlive == true {
                
               paddle.position.x = location.x
            }
            
            if atPoint(location) != pauseBtn {
                
                pauseBtn.run(SKAction.setTexture(SKTexture(imageNamed: "PauseBtn")))
            }
            
            if atPoint(location) != returnHomeBtn {
                
                returnHomeBtn.texture = SKTexture(imageNamed: "ReturnHomeBtn")
            }
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Ball" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Ball" && secondBody.node?.name == "Paddle" {
            
            if firstImpact == false {
                
                playSound1()
                firstBody.applyImpulse(CGVector(dx: 200, dy: 20))
                updateScoreLbl()
                firstImpact = true
            } else {
                playSound1()
                firstBody.applyImpulse(CGVector(dx: -200, dy: 20))
                updateScoreLbl()
                firstImpact = false
            }
            
        }
        
        if firstBody.node?.name == "Ball" && secondBody.node?.name == "Kill Zone" {
            
            isAlive = false
            firstBody.node?.removeFromParent()
            
            endGame()
            playSound2()
            
        }
        
        if firstBody.node?.name == "Ball" && secondBody.node?.name == "Star" {
            
            playSound3()
            secondBody.node?.removeFromParent()
            starPointsUpdate()
        }
    }
    
    func spawnBall1() {
        
        let rand = Int(arc4random_uniform(8))
        
        let ballName = ballNames[rand]
        
        let ball = Ball(imageNamed: "\(ballName)")
        ball.name = "Ball"
        ball.size = CGSize(width: 70, height: 70)
        ball.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-500, secondNum: 500), y: 950)
        ball.initialize()
        emitter?.particleTexture = SKTexture(imageNamed: "\(ballName)")
        ball.addChild(emitter!)
        
        self.addChild(ball)
    }
    
    func spawnBall2() {
        
        let rand = Int(arc4random_uniform(8))
        
        let ballName1 = ballNames[rand]
        
        let ball2 = Ball(imageNamed: "\(ballName1)")
        ball2.name = "Ball"
        ball2.size = CGSize(width: 70, height: 70)
        ball2.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-500, secondNum: 300), y: 950)
        ball2.initialize()
        emitter2?.particleTexture = SKTexture(imageNamed: "\(ballName1)")
        ball2.addChild(emitter2!)
        
        self.addChild(ball2)
    }
    
    func spawnPaddle() {
        
        paddle = SKSpriteNode(imageNamed: "\(GameManager.instance.getPaddle())")
        paddle.name = "Paddle"
        paddle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        paddle.zPosition = 1
        paddle.size = CGSize(width: 350, height: 70)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.categoryBitMask = ColliderType.Paddle
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.isDynamic = false
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                
            case 480:
                print("iPhone Classic")
            case 960:
                // iPhone 4 or 4S
                paddle.position = CGPoint(x: 0, y: self.frame.minY + 300)
                
            case 1136:
                // iPhone 5 or 5S or 5C
                paddle.position = CGPoint(x: 0, y: self.frame.minY + 200)

            case 1334:
                // iPhone 6 or 6S
                paddle.position = CGPoint(x: 0, y: self.frame.minY + 200)
                
            case 2208:
                // iPhone 6+ or 6S+
                paddle.position = CGPoint(x: 0, y: self.frame.minY + 200)
                
            default:
                print("unknown")
            }
        }
        
        self.addChild(paddle)
    }
    
    func spawnStars() {
        
        star = SKSpriteNode(imageNamed: "StarCollectable")
        star.name = "Star"
        star.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        star.size = CGSize(width: 90, height: 90)
        star.zPosition = 3
        star.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-300, secondNum: 300), y: GameManager.instance.randomBetweenNumbers(400, secondNum: 700))
        star.physicsBody = SKPhysicsBody(rectangleOf: star.size)
        star.physicsBody?.categoryBitMask = ColliderType.Star
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.isDynamic = false
        
        let rotate1 = SKAction.rotate(byAngle: 1.5, duration: 0.7)
        let rotate2 = SKAction.rotate(byAngle: -1.5, duration: 0.7)
        let remove = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: 2.5)
        
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.4)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.4)
        
        if isStarSpawnedOnce == false {
            
            star.run(SKAction.repeatForever(rotate1))
            isStarSpawnedOnce = true
        } else {
            
            star.run(SKAction.repeatForever(rotate2))
            isStarSpawnedOnce = false
        }
        
        star.run(SKAction.sequence([wait, remove]))
        star.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
        
        self.addChild(star)
    }
    
    func spawnCollectables() {
        
        // Code multiple spawning logic
        let wait = SKAction.wait(forDuration: 2.7)
        let spawn = SKAction.run {
            
            self.spawnStars()
        }
        
        let sequence = SKAction.sequence([spawn,wait])
        
        self.run(SKAction.repeatForever(sequence))
    }
    
    func createTapToPlayScreen() {
        
        tapToPlayScreen = SKSpriteNode(color: UIColor.clear, size: CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!))
        tapToPlayScreen.name = "TapToPlay"
        tapToPlayScreen.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tapToPlayScreen.zPosition = 4
        tapToPlayScreen.position = CGPoint(x: 0, y: 0)
        
        let title = SKLabelNode(fontNamed: "Prototype")
        title.fontSize = 120
        title.zPosition = 5
        title.fontColor = SKColor.black
        title.text = "Tap to Play"
        title.position = CGPoint(x: 0, y: 300)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let sequence = SKAction.sequence([fadeOut, fadeIn])
        
        title.run(SKAction.repeatForever(sequence))
        
        tapToPlayScreen.addChild(title)
        
        self.addChild(tapToPlayScreen)
    }
    
    func createPauseMenu() {
        
        pauseMenuBg.name = "PauseMenu"
        pauseMenuBg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pauseMenuBg.zPosition = 10
        pauseMenuBg.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
        pauseMenuBg.position = CGPoint(x: 0, y: 0)
        
        returnHomeBtn.name = "ReturnHome"
        returnHomeBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        returnHomeBtn.size = CGSize(width: 200, height: 200)
        returnHomeBtn.zPosition = 11
        returnHomeBtn.position = CGPoint(x: 0, y: -400)
        
        pauseTitle.name = "PauseMenuTitle"
        pauseTitle.fontSize = 90
        pauseTitle.fontColor = SKColor.darkGray
        pauseTitle.zPosition = 11
        pauseTitle.text = "Tap to Resume"
        pauseTitle.position = CGPoint(x: 0, y: 0)
        
        self.addChild(pauseMenuBg)
        pauseMenuBg.addChild(returnHomeBtn)
        pauseMenuBg.addChild(pauseTitle)
    }
    
    func createPauseBtn() {
        
        pauseBtn = SKSpriteNode(imageNamed: "PauseBtn")
        pauseBtn.name = "Pause"
        pauseBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pauseBtn.zPosition = 2
        pauseBtn.size = CGSize(width: 100, height: 100)
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                
            case 480:
                print("iPhone Classic")
            case 960:
                // iPhone 4 or 4S
                pauseBtn.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.maxY - 230)
            case 1136:
                // iPhone 5 or 5S or 5C
                pauseBtn.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.maxY - 100)

            case 1334:
                // iPhone 6 or 6S
                pauseBtn.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.maxY - 100)
                
            case 2208:
                // iPhone 6+ or 6S+
                pauseBtn.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.maxY - 100)
            default:
                print("unknown")
            }
        }
        
        self.addChild(pauseBtn)
    }
    
    func createScoreLabel() {
        
        scoreLbl = SKLabelNode(fontNamed: "Prototype")
        scoreLbl.fontSize = 220
        scoreLbl.fontColor = SKColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.6)
        scoreLbl.zPosition = 2
        scoreLbl.text = "0"
        scoreLbl.position = CGPoint(x: 0, y: 600)
        
        self.addChild(scoreLbl)
    }
    
    func updateScoreLbl() {
        
        counter += 1
        scoreLbl.text = "\(counter)"
    }
    
    func starPointsUpdate() {
        
        counter += 2
        scoreLbl.text = "\(counter)"
    }
    
    func endGame() {
        
        UserDefaults.standard.set(counter, forKey: "SCORE")
        
        let wait = SKAction.wait(forDuration: 0.2)
        let run = SKAction.run {
            
            self.removeAllActions()
            self.removeAllChildren()
            let gameover = GameoverScene(fileNamed: "GameoverScene")
            gameover?.scaleMode = .aspectFill
            self.view?.presentScene(gameover!, transition: SKTransition.fade(withDuration: 0.5))
        }
        self.run(SKAction.sequence([wait, run]))
        
    }
    
    func spawnWalls() {
        
        let floor = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.frame.size.width, height: 10))
        floor.name = "Kill Zone"
        floor.zPosition = 3
        floor.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        floor.position = CGPoint(x: 0, y: -(self.frame.height / 2))
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = ColliderType.EndWall
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.isDynamic = false
        
        let ceiling = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.frame.size.width, height: 10))
        ceiling.zPosition = 3
        ceiling.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ceiling.position = CGPoint(x: 0, y: (self.frame.height / 2))
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        ceiling.physicsBody?.categoryBitMask = ColliderType.Border
        ceiling.physicsBody?.affectedByGravity = false
        ceiling.physicsBody?.isDynamic = false
        
        let leftWall = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 10, height: self.frame.size.height))
        leftWall.zPosition = 3
        leftWall.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        leftWall.position = CGPoint(x: -(self.frame.width / 2), y: 0)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.categoryBitMask = ColliderType.Border
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        
        let rightWall = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 10, height: self.frame.size.height))
        rightWall.zPosition = 3
        rightWall.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rightWall.position = CGPoint(x: (self.frame.width / 2), y: 0)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = ColliderType.Border
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        
        
        self.addChild(floor)
        self.addChild(leftWall)
        self.addChild(rightWall)
        
        let wait = SKAction.wait(forDuration: 1.5)
        let run = SKAction.run {
            
            self.addChild(ceiling)
        }
        
        let sequence = SKAction.sequence([wait, run])
        self.run(sequence)
        
    }
    
    func playSound1() {
        
        let play = SKAction.playSoundFileNamed("BallDeflectedSound5", waitForCompletion: false)
        if soundOn == true {
            self.run(play)
        }
    }
    
    func playSound2() {
        
        let play = SKAction.playSoundFileNamed("IncorrectSound1", waitForCompletion: false)
        if soundOn == true {
            self.run(play)
        }
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

    }
    
    func playSound3() {
        
        let play = SKAction.playSoundFileNamed("Powerup2", waitForCompletion: false)
        if soundOn == true {
            self.run(play)
        }
    }
    
}
