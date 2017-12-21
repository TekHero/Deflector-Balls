//
//  GameoverScene.swift
//  Deflector Balls
//
//  Created by Brian Lim on 6/1/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import SpriteKit
import UIKit
import GameKit

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

class GameoverScene: SKScene, GKGameCenterControllerDelegate {
    
    var titleLbl = SKLabelNode()
    var scoreTitle = SKLabelNode()
    var recordTitle = SKLabelNode()
    var scoreLbl = SKLabelNode()
    var recordLbl = SKLabelNode()
    
    var retryBtn = SKSpriteNode()
    var homeBtn = SKSpriteNode()
    var rateBtn = SKSpriteNode()
    var musicBtn = SKSpriteNode()
    var shareBtn = SKSpriteNode()
    
    var userScore = 0
    var userHighscore = 0
    
    var shouldAnimate = false
    
    override func didMove(to view: SKView) {
        adShown += 1
        
        checkScore()
        initialize()
        
        waitBeforeShowingAd()
        
        if soundOn == true {
            
            musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtn")))
        } else {
            
            musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOffBtn")))
        }
        
    }
    
    func initialize() {
        
        createTitle()
        createRetryBtn()
        createScoreTitleAndLabel()
        createRecordTitleAndLabel()
        createMusicBtn()
        createRateBtn()
        createShareBtn()
        createHomeBtn()
    }
    
    func checkScore() {
        
        // Checking to see if there is a integer for the key "SCORE"
        if let score: Int = UserDefaults.standard.integer(forKey: "SCORE") {
            userScore = score
            
            // Checking to see if there if a integer for the key "HIGHSCORE"
            if let highscore: Int = UserDefaults.standard.integer(forKey: "HIGHSCORE") {
                
                // If there is, check if the current score is greater then the value of the current highscore
                if score > highscore {
                    // If it is, set the current score as the new high score
                    GameManager.instance.setHighscore(score)
                    userHighscore = score
                    saveHighscore(score)
                    shouldAnimate = true
                    
                } else {
                    // Score is not greater then highscore
                }
            } else {
                // There is no integer for the key "HIGHSCORE"
                // Set the current score as the highscore since there is no value for highscore yet
                GameManager.instance.setHighscore(score)
                userHighscore = score
                saveHighscore(score)
                shouldAnimate = true
                
            }
        }
        
        // Checking to see if there a integer for the key "HIGHSCORE"
        if let highscore: Int = UserDefaults.standard.integer(forKey: "HIGHSCORE") {
            // If so, then set the value of this key to the userHighscore variable
            userHighscore = highscore
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == retryBtn {
                
                retryBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RetryBtnDown")))
            }
            
            if atPoint(location) == rateBtn {
                
                rateBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RateBtnDown")))
            }
            
            if atPoint(location) == musicBtn {
                
                musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtnDown")))
            }
            
            if atPoint(location) == homeBtn {
                
                homeBtn.run(SKAction.setTexture(SKTexture(imageNamed: "HomeBtnDown")))
            }
            
            if atPoint(location) == shareBtn {
                
                shareBtn.run(SKAction.setTexture(SKTexture(imageNamed: "ShareBtnDown")))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == retryBtn {
                
                playSound1()
                retryBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RetryBtn")))
                
                let gameplay = GameplayScene(fileNamed: "GameplayScene")
                gameplay?.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.fade(withDuration: 0.5))
            }
            
            if atPoint(location) == rateBtn {
                
                playSound1()
                rateBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RateBtn")))
                rateBtnPressed()
            }
            
            if atPoint(location) == musicBtn {
                
                musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtn")))
                playSound1()
                soundBtnPressed()
            }
            
            if atPoint(location) == homeBtn {
                
                playSound1()
                homeBtn.run(SKAction.setTexture(SKTexture(imageNamed: "HomeBtn")))
                
                let mainMenu = MainMenuScene(fileNamed: "MainMenuScene")
                mainMenu?.scaleMode = .aspectFill
                self.view?.presentScene(mainMenu!, transition: SKTransition.fade(withDuration: 0.5))
            }
            
            if atPoint(location) == shareBtn {
                
                playSound1()
                shareBtn.run(SKAction.setTexture(SKTexture(imageNamed: "ShareBtn")))
                delayShare()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) != retryBtn {
                
                retryBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RetryBtn")))
            }
            
            if atPoint(location) != rateBtn {
                
                rateBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RateBtn")))
            }
            
            if atPoint(location) != musicBtn {
                
                musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtn")))
            }
            
            if atPoint(location) != homeBtn {
                
                homeBtn.run(SKAction.setTexture(SKTexture(imageNamed: "HomeBtn")))
            }
            
            if atPoint(location) != shareBtn {
                
                shareBtn.run(SKAction.setTexture(SKTexture(imageNamed: "ShareBtn")))
            }
        }
    }
    
    func createTitle() {
        
        titleLbl = SKLabelNode(fontNamed: "Prototype")
        titleLbl.name = "Title"
        titleLbl.zPosition = 1
        titleLbl.fontSize = 160
        titleLbl.fontColor = SKColor.black
        titleLbl.text = "GAMEOVER"
        
        let moveRight = SKAction.moveTo(x: 15, duration: 0.5)
        let moveLeft = SKAction.moveTo(x: -15, duration: 0.5)
        let sequence = SKAction.sequence([moveRight, moveLeft])
        titleLbl.run(SKAction.repeatForever(sequence))
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                
            case 480:
                print("iPhone Classic")
            case 960:
                // iPhone 4 or 4S
                titleLbl.position = CGPoint(x: 0, y: 650)

            case 1136:
                // iPhone 5 or 5S or 5C
                titleLbl.position = CGPoint(x: 0, y: 740)

            case 1334:
                // iPhone 6 or 6S
                titleLbl.position = CGPoint(x: 0, y: 740)
                
            case 2208:
                // iPhone 6+ or 6S+
                titleLbl.position = CGPoint(x: 0, y: 760)

            default:
                print("unknown")
            }
        }
        
        self.addChild(titleLbl)
    }
    
    func createScoreTitleAndLabel() {
        
        scoreTitle = SKLabelNode(fontNamed: "Prototype")
        scoreTitle.fontSize = 100
        scoreTitle.fontColor = SKColor.gray
        scoreTitle.zPosition = 2
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: -250, y: 450)
        
        scoreLbl = SKLabelNode(fontNamed: "Prototype")
        scoreLbl.fontSize = 150
        scoreLbl.fontColor = SKColor.darkGray
        scoreLbl.zPosition = 2
        scoreLbl.text = "\(userScore)"
        scoreLbl.position = CGPoint(x: -250, y: scoreTitle.position.y - 180)
        
        self.addChild(scoreTitle)
        self.addChild(scoreLbl)
    }
    
    func createRecordTitleAndLabel() {
        
        recordTitle = SKLabelNode(fontNamed: "Prototype")
        recordTitle.fontSize = 100
        recordTitle.fontColor = SKColor.gray
        recordTitle.zPosition = 2
        recordTitle.text = "RECORD"
        recordTitle.position = CGPoint(x: 250, y: 450)
        
        recordLbl = SKLabelNode(fontNamed: "Prototype")
        recordLbl.fontSize = 150
        recordLbl.fontColor = SKColor.darkGray
        recordLbl.zPosition = 2
        recordLbl.text = "\(userHighscore)"
        recordLbl.position = CGPoint(x: 250, y: recordTitle.position.y - 180)
        if shouldAnimate == true {
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            recordLbl.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))
        }
        
        self.addChild(recordTitle)
        self.addChild(recordLbl)
    }
    
    func createRetryBtn() {
        
        retryBtn = SKSpriteNode(imageNamed: "RetryBtn")
        retryBtn.name = "Retry"
        retryBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        retryBtn.zPosition = 2
        retryBtn.size = CGSize(width: 300, height: 300)
        retryBtn.position = CGPoint(x: 0, y: -50)
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        
        retryBtn.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
        
        self.addChild(retryBtn)
    }
    
    func createMusicBtn() {
        
        musicBtn = SKSpriteNode(imageNamed: "MusicOnBtn")
        musicBtn.name = "Music"
        musicBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        musicBtn.size = CGSize(width: 150, height: 150)
        musicBtn.zPosition = 4
        musicBtn.position = CGPoint(x: 115, y: -650)
        
        self.addChild(musicBtn)
        
    }
    
    func createRateBtn() {
        
        rateBtn = SKSpriteNode(imageNamed: "RateBtn")
        rateBtn.name = "Rate"
        rateBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rateBtn.size = CGSize(width: 150, height: 150)
        rateBtn.zPosition = 4
        rateBtn.position = CGPoint(x: -115, y: -650)
        
        self.addChild(rateBtn)
    }
    
    func createShareBtn() {
        
        shareBtn = SKSpriteNode(imageNamed: "ShareBtn")
        shareBtn.name = "Share"
        shareBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shareBtn.size = CGSize(width: 150, height: 150)
        shareBtn.zPosition = 4
        shareBtn.position = CGPoint(x: 350, y: -650)
        
        self.addChild(shareBtn)
    }
    
    func createHomeBtn() {
        
        homeBtn = SKSpriteNode(imageNamed: "HomeBtn")
        homeBtn.name = "Home"
        homeBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        homeBtn.size = CGSize(width: 150, height: 150)
        homeBtn.zPosition = 4
        homeBtn.position = CGPoint(x: -350, y: -650)
        
        self.addChild(homeBtn)
    }
    
    func delayShare() {
        
        let wait = SKAction.wait(forDuration: 0.2)
        let run = SKAction.run {
            
            self.socialShare("I just got a score of \(self.userScore) in Rebound It!", sharingURL: URL(string: "https://itunes.apple.com/us/app/rebound-it!/id1122571821?ls=1&mt=8"))
        }
        
        let sequence = SKAction.sequence([wait, run])
        self.run(sequence)
    }
    
    func socialShare(_ sharingText: String?, sharingURL: URL?) {
        var sharingItems = [AnyObject]()
        
        let screenshot = self.view?.pb_takeSnapshot()
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
        
        if let text = sharingText {
            sharingItems.append(text as AnyObject)
        }
        if let image = screenshot {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList,UIActivityType.assignToContact,UIActivityType.postToTencentWeibo,UIActivityType.postToVimeo,UIActivityType.print,UIActivityType.postToWeibo,UIActivityType.message,UIActivityType.saveToCameraRoll]
        
        
        self.view?.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    //send high score to leaderboard
    func saveHighscore(_ score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "Rebound_It_2016") //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    // error
                }
            })
            
        }
        
        
    }
    
    func soundBtnPressed() {
        if soundOn == true {
            musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOffBtn")))
            soundOn = false
            // Sound is OFF
        } else {
            musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtn")))
            soundOn = true
            // Sound is ON
        }
    }
    
    func waitBeforeShowingAd() {
        let wait = SKAction.wait(forDuration: 0.5)
        let run = SKAction.run {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showInterstitialKey"), object: nil)
        }
        let sequence = SKAction.sequence([wait, run])
        self.run(sequence)
    }
    
    func rateBtnPressed() {
        
        let wait = SKAction.wait(forDuration: 0.1)
        let run = SKAction.run {
            
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1122571821")!)
        }
        
        self.run(SKAction.sequence([wait, run]))
    }
    
    func playSound1() {
        
        let play = SKAction.playSoundFileNamed("Menu Selection Click", waitForCompletion: false)
        if soundOn == true {
            self.run(play)
        }
    }
    

}

















