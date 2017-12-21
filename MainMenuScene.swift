//
//  MainMenuScene.swift
//  Deflector Balls
//
//  Created by Brian Lim on 5/30/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import SpriteKit
import UIKit
import GameKit
import StoreKit

extension UIScreen {
    
    enum SizeType: CGFloat {
        case unknown = 0.0
        case iPhone4 = 960.0
        case iPhone5 = 1136.0
        case iPhone6 = 1334.0
        case iPhone6Plus = 2208.0
    }
    
    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .unknown }
        return sizeType
    }
}

class MainMenuScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var titleLbl = SKLabelNode()
    var playBtn = SKSpriteNode()
    var iAPBtn = SKSpriteNode()
    var rateBtn = SKSpriteNode()
    var musicBtn = SKSpriteNode()
    var leaderboardBtn = SKSpriteNode()
    var paddle = SKSpriteNode()
    var paddleTitle = SKLabelNode()
    var leftArrow = SKSpriteNode()
    var rightArrow = SKSpriteNode()
    
    var IAPMenu = SKSpriteNode()
    var purchaseRemoveAdsBtn = SKSpriteNode()
    var restorePurchasesBtn = SKSpriteNode()
    var returnBtn = SKSpriteNode()
    
    var balls = [SKSpriteNode]()
    
    let productIdentifiers = Set(["Rebound_It_Game_Remove_Ads"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        requestProductData()
        SKPaymentQueue.default().add(self)
        
        initialize()
        
        if soundOn == true {
            
            musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtn")))
        } else {
            
            musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOffBtn")))
        }
        
    }
    
    func initialize() {
        authenticateLocalPlayer()
        spawnWalls()
        
        createTitle()
        createPlayBtn()
        createiAPBtn()
        createRateBtn()
        createMusicBtn()
        createLeaderboardBtn()
        spawnBalls()
        createPaddle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == playBtn {
                
                playBtn.run(SKAction.setTexture(SKTexture(imageNamed: "PlayBtnDown")))
            }
            
            if atPoint(location) == iAPBtn {
                
                iAPBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RemoveAdBtnDown")))
            }
            
            if atPoint(location) == rateBtn {
                
                rateBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RateBtnDown")))
            }
            
            if atPoint(location) == musicBtn {
                
                musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtnDown")))
            }
            
            if atPoint(location) == leaderboardBtn {
                
                leaderboardBtn.run(SKAction.setTexture(SKTexture(imageNamed: "LeaderboardBtnDown")))
            }
            
            if atPoint(location) == leftArrow {
                
                playSound1()
                GameManager.instance.decrementIndex()
                paddle.removeFromParent()
                createPaddle()
                
            }
            
            if atPoint(location) == rightArrow {
                
                playSound1()
                GameManager.instance.incrementIndex()
                paddle.removeFromParent()
                createPaddle()
            }
            
            if atPoint(location) == returnBtn {
                
                returnBtn.texture = SKTexture(imageNamed: "ReturnBtnDown")
            }
            
            if atPoint(location) == purchaseRemoveAdsBtn {
                
                purchaseRemoveAdsBtn.texture = SKTexture(imageNamed: "PurchaseRemoveAdBtnDown")
            }
            
            if atPoint(location) == restorePurchasesBtn {
                
                restorePurchasesBtn.texture = SKTexture(imageNamed: "RestorePurchasesBtnDown")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == playBtn {
                
                playSound1()
                playBtn.run(SKAction.setTexture(SKTexture(imageNamed: "PlayBtn")))
                let gameplay = GameplayScene(fileNamed: "GameplayScene")
                gameplay?.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.fade(withDuration: 0.5))
            }
            
            if atPoint(location) == iAPBtn {
                
                playSound1()
                iAPBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RemoveAdBtn")))
                createIAPMenu()
            
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
            
            if atPoint(location) == leaderboardBtn {
                
                playSound1()
                leaderboardBtn.run(SKAction.setTexture(SKTexture(imageNamed: "LeaderboardBtn")))
                leaderboardBtnPressed()
            }
            
            if atPoint(location) == returnBtn {
                
                playSound1()
                returnBtn.texture = SKTexture(imageNamed: "ReturnBtn")
                self.IAPMenu.removeFromParent()
                self.returnBtn.removeFromParent()
                self.purchaseRemoveAdsBtn.removeFromParent()
                self.restorePurchasesBtn.removeFromParent()
                
                self.scene?.isPaused = false
            }
            
            if atPoint(location) == purchaseRemoveAdsBtn {
                
                playSound1()
                purchaseRemoveAdsBtn.texture = SKTexture(imageNamed: "PurchaseRemoveAdBtn")
                if defaults.bool(forKey: "purchased") == false {
                    
                    let payment = SKPayment(product: productsArray[0])
                    SKPaymentQueue.default().add(payment)
                } else {
                    // Purchased was made already
                }
            }
            
            if atPoint(location) == restorePurchasesBtn {
                
                playSound1()
                restorePurchasesBtn.texture = SKTexture(imageNamed: "RestorePurchasesBtn")
                restorePurchases()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) != playBtn {
                
                playBtn.run(SKAction.setTexture(SKTexture(imageNamed: "PlayBtn")))
            }
            
            if atPoint(location) != iAPBtn {
                
                iAPBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RemoveAdBtn")))
            }
            
            if atPoint(location) != rateBtn {
                
                rateBtn.run(SKAction.setTexture(SKTexture(imageNamed: "RateBtn")))
            }
            
            if atPoint(location) != musicBtn {
                
                musicBtn.run(SKAction.setTexture(SKTexture(imageNamed: "MusicOnBtn")))
            }
            
            if atPoint(location) != leaderboardBtn {
                
                leaderboardBtn.run(SKAction.setTexture(SKTexture(imageNamed: "LeaderboardBtn")))
            }
            
            if atPoint(location) != returnBtn {
                
                returnBtn.texture = SKTexture(imageNamed: "ReturnBtn")
            }
            
            if atPoint(location) != purchaseRemoveAdsBtn {
                
                purchaseRemoveAdsBtn.texture = SKTexture(imageNamed: "PurchaseRemoveAdBtn")
            }
            
            if atPoint(location) != restorePurchasesBtn {
                
                restorePurchasesBtn.texture = SKTexture(imageNamed: "RestorePurchasesBtn")
            }
        }
    }
    
    func createIAPMenu() {
        
        IAPMenu = SKSpriteNode(imageNamed: "IAPBG")
        IAPMenu.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
        IAPMenu.name = "IAPMenu"
        IAPMenu.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        IAPMenu.zPosition = 12
        IAPMenu.position = CGPoint(x: 0, y: 0)
        
        purchaseRemoveAdsBtn = SKSpriteNode(imageNamed: "PurchaseRemoveAdBtn")
        purchaseRemoveAdsBtn.name = "RemoveAdPurchase"
        purchaseRemoveAdsBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        purchaseRemoveAdsBtn.zPosition = 13
        purchaseRemoveAdsBtn.size = CGSize(width: 450, height: 150)
        purchaseRemoveAdsBtn.position = CGPoint(x: 0, y: 200)
        
        restorePurchasesBtn = SKSpriteNode(imageNamed: "RestorePurchasesBtn")
        restorePurchasesBtn.name = "RestorePurchasesBtn"
        restorePurchasesBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        restorePurchasesBtn.zPosition = 13
        restorePurchasesBtn.size = CGSize(width: 450, height: 150)
        restorePurchasesBtn.position = CGPoint(x: 0, y: 0)
        
        returnBtn = SKSpriteNode(imageNamed: "ReturnBtn")
        returnBtn.name = "Return"
        returnBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        returnBtn.zPosition = 13
        returnBtn.size = CGSize(width: 300, height: 120)
        returnBtn.position = CGPoint(x: 0, y: -220)
        
        let wait = SKAction.wait(forDuration: 0.1)
        let run = SKAction.run {
            
            self.scene?.isPaused = true
            
            self.addChild(self.IAPMenu)
            self.IAPMenu.addChild(self.purchaseRemoveAdsBtn)
            self.IAPMenu.addChild(self.restorePurchasesBtn)
            self.IAPMenu.addChild(self.returnBtn)
            
        }
        
        self.run(SKAction.sequence([wait, run]))
    }
    
    func createPaddle() {
        
        paddle = SKSpriteNode(imageNamed: "\(GameManager.instance.getPaddle())")
        paddle.name = "Paddle"
        paddle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        paddle.position = CGPoint(x: 0, y: -400)
        paddle.zPosition = 4
        paddle.size = CGSize(width: 450, height: 100)
        
        paddleTitle = SKLabelNode(fontNamed: "Prototype")
        paddleTitle.name = "PaddleTitle"
        paddleTitle.fontSize = 50
        paddleTitle.fontColor = SKColor.darkGray
        paddleTitle.text = "Choose a Paddle:"
        paddleTitle.zPosition = 4
        paddleTitle.position = CGPoint(x: 0, y: paddle.position.y + 70)
        
        leftArrow = SKSpriteNode(imageNamed: "LeftArrow")
        leftArrow.name = "Left"
        leftArrow.size = CGSize(width: 75, height: 75)
        leftArrow.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        leftArrow.zPosition = 5
        leftArrow.position = CGPoint(x: paddle.position.x - 290, y: paddle.position.y)
        
        rightArrow = SKSpriteNode(imageNamed: "RightArrow")
        rightArrow.name = "Right"
        rightArrow.size = CGSize(width: 75, height: 75)
        rightArrow.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rightArrow.zPosition = 5
        rightArrow.position = CGPoint(x: paddle.position.x + 290, y: paddle.position.y)
        
        self.addChild(paddle)
        self.addChild(paddleTitle)
        self.addChild(leftArrow)
        self.addChild(rightArrow)
    }
    
    func spawnBalls() {
        
        let blueBall = Ball(imageNamed: "BlueBall")
        blueBall.name = "BlueBall"
        blueBall.size = CGSize(width: 70, height: 70)
        blueBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY + 100)
        blueBall.initialize()
        
        let redBall = Ball(imageNamed: "RedBall")
        redBall.name = "BlueBall"
        redBall.size = CGSize(width: 70, height: 70)
        redBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY + 100)
        redBall.initialize()
        
        let greenBall = Ball(imageNamed: "GreenBall")
        greenBall.name = "BlueBall"
        greenBall.size = CGSize(width: 70, height: 70)
        greenBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY + 100)
        greenBall.initialize()
        
        let yellowBall = Ball(imageNamed: "YellowBall")
        yellowBall.name = "BlueBall"
        yellowBall.size = CGSize(width: 70, height: 70)
        yellowBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY + 100)
        yellowBall.initialize()
        
        let lightGreenBall = Ball(imageNamed: "LightGreenBall")
        lightGreenBall.name = "BlueBall"
        lightGreenBall.size = CGSize(width: 70, height: 70)
        lightGreenBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY + 100)
        lightGreenBall.initialize()
        
        let purpleBall = Ball(imageNamed: "PurpleBall")
        purpleBall.name = "BlueBall"
        purpleBall.size = CGSize(width: 70, height: 70)
        purpleBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY + 100)
        purpleBall.initialize()
        
        let orangeBall = Ball(imageNamed: "OrangeBall")
        orangeBall.name = "OrangeBall"
        orangeBall.size = CGSize(width: 70, height: 70)
        orangeBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY + 100)
        orangeBall.initialize()
        
        let brownBall = Ball(imageNamed: "BrownBall")
        brownBall.name = "BrownBall"
        brownBall.size = CGSize(width: 70, height: 70)
        brownBall.position = CGPoint(x: GameManager.instance.randomBetweenNumbers(-400, secondNum: 400), y: self.frame.maxY - 50)
        brownBall.initialize()
        
        let wait = SKAction.wait(forDuration: 0.2)
        let run1 = SKAction.run {
            
            self.addChild(blueBall)

        }
        
        let run2 = SKAction.run {
            
            self.addChild(redBall)

        }
        
        let run3 = SKAction.run {
            
            self.addChild(greenBall)

        }
        
        let run4 = SKAction.run {
            
            self.addChild(yellowBall)

        }
        
        let run5 = SKAction.run {
            
            self.addChild(lightGreenBall)

        }
        
        let run6 = SKAction.run {
            
            self.addChild(purpleBall)

        }
        
        let run7 = SKAction.run {
            
            self.addChild(orangeBall)

        }
        
        let run8 = SKAction.run {
            
            self.addChild(brownBall)

        }
        
        self.run(SKAction.sequence([run1, wait, run2, wait, run3, wait, run4, wait, run5, wait, run6, wait, run7, wait, run8]))
        
    }
    
    func spawnWalls() {
        
        let floor = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.frame.size.width, height: 10))
        floor.zPosition = 3
        floor.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        floor.position = CGPoint(x: 0, y: -(self.frame.height / 2))
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = ColliderType.Border
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
    
    func createTitle() {
        
        titleLbl = SKLabelNode(fontNamed: "Prototype")
        titleLbl.fontSize = 140
        titleLbl.fontColor = SKColor.black
        titleLbl.zPosition = 4
        titleLbl.text = "Rebound It!"
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        
        titleLbl.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
        
        if UIScreen.main.sizeType == .iPhone4 {
            
            titleLbl.position = CGPoint(x: 0, y: 630)
            // iPhone 4/s
            
        } else if UIScreen.main.sizeType == .iPhone5 {
            
            titleLbl.position = CGPoint(x: 0, y: 740)
            // iPhone 5/s
            
        } else if UIScreen.main.sizeType == .iPhone6 {
            
            titleLbl.position = CGPoint(x: 0, y: 740)
            // iPhone 6/s
            
        } else if UIScreen.main.sizeType == .iPhone6Plus {
            
            titleLbl.position = CGPoint(x: 0, y: 760)
            // iPhone 6/s plus
        }
        
        self.addChild(titleLbl)
    }
    
    func createPlayBtn() {
        
        playBtn = SKSpriteNode(imageNamed: "PlayBtn")
        playBtn.name = "Play"
        playBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playBtn.size = CGSize(width: 300, height: 300)
        playBtn.zPosition = 2
        playBtn.position = CGPoint(x: 0, y: 0)
        playBtn.physicsBody = SKPhysicsBody(circleOfRadius: playBtn.size.height / 2)
        playBtn.physicsBody?.categoryBitMask = ColliderType.Button
        playBtn.physicsBody?.affectedByGravity = false
        playBtn.physicsBody?.isDynamic = false
        
        self.addChild(playBtn)
    }
    
    func createLeaderboardBtn() {
        
        leaderboardBtn = SKSpriteNode(imageNamed: "LeaderboardBtn")
        leaderboardBtn.name = "Leaderboard"
        leaderboardBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        leaderboardBtn.size = CGSize(width: 150, height: 150)
        leaderboardBtn.zPosition = 4
        leaderboardBtn.position = CGPoint(x: 350, y: -650)
        
        self.addChild(leaderboardBtn)
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
    
    func createiAPBtn() {
        
        iAPBtn = SKSpriteNode(imageNamed: "RemoveAdBtn")
        iAPBtn.name = "iAP"
        iAPBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        iAPBtn.size = CGSize(width: 150, height: 150)
        iAPBtn.zPosition = 4
        iAPBtn.position = CGPoint(x: -350, y: -650)
        
        self.addChild(iAPBtn)
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
    
    func rateBtnPressed() {
        
        let wait = SKAction.wait(forDuration: 0.1)
        let run = SKAction.run {
            
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1122571821")!)
        }
        
        self.run(SKAction.sequence([wait, run]))
    }
    
    func leaderboardBtnPressed() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "Rebound_It_2016"
        self.view?.window?.rootViewController?.present(gcVC, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.view?.window?.rootViewController?.present(viewController!, animated: true, completion: nil)
                
            }
                
            else {
                print((GKLocalPlayer.localPlayer().isAuthenticated))
            }
        }
        
    }
    
    func playSound1() {
        
        let play = SKAction.playSoundFileNamed("Menu Selection Click", waitForCompletion: false)
        if soundOn == true {
            self.run(play)
        }
    }
    
    // ------ PAYMENT CODE ------ //
    
    func restorePurchases() {
        
        if (SKPaymentQueue.canMakePayments()) {
            
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.purchased:
                // Transaction Approved
                self.deliverProduct(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case SKPaymentTransactionState.failed:
                // Transaction Failed
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case SKPaymentTransactionState.restored:
                // Transation Restored
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func deliverProduct(_ transaction:SKPaymentTransaction) {
        
        if transaction.payment.productIdentifier == "Rebound_It_Game_Remove_Ads"
        {
            // Non-Consumable Product Purchased
            // Unlock Feature
            defaults.set(true, forKey: "purchased")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            
            for i in 0 ..< products.count {
                
                self.product = products[i]
                self.productsArray.append(product!)
                
            }
            
        } else {
            
            // No products found
            
        }
        
        var invalidProducts: [String]?
        invalidProducts = response.invalidProductIdentifiers
        
        for product in invalidProducts! {
            print("Product not found: \(product)")
        }
    }
    
    func requestProductData() {
        
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                self.productIdentifiers as Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.shared.openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // Transactions Restored
        
        for transaction:SKPaymentTransaction in queue.transactions {
            
            if transaction.payment.productIdentifier == "Rebound_It_Game_Remove_Ads"
            {
                // Non-Consumable Product Purchased
                // Unlock Feature
                defaults.set(true, forKey: "purchased")
                
            }
        }
        
        let alertController = UIAlertController(title: "Thank You", message: "Your purchase(s) were restored", preferredStyle: UIAlertControllerStyle.alert)
        let doneAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(doneAction)
        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)

    }
    
}
