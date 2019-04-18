//
//  GameScene.swift
//  JumpingGame
//
//  Created by user152256 on 4/3/19.
//  Copyright © 2019 Sullivan, Katherine. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var landImpact : SKSpriteNode?
    var gameTimer : Timer?
    var bombTimer : Timer?
    var ground : SKSpriteNode?
    var ceiling : SKSpriteNode?
    var scoreLabel : SKLabelNode?
    var finalScoreLabel : SKLabelNode?
    var yourScoreLabel : SKLabelNode?
    
    let landImpactCategory : UInt32 = 0x1 << 1
    let coinCategory : UInt32 = 0x1 << 2
    let bombCategory : UInt32 = 0x1 << 3
    let groundAndCeilingCategory : UInt32 = 0x1 << 4

    var score = 0
    override func didMove(to view: SKView) {
        
        landImpact = childNode(withName: "landImpact") as? SKSpriteNode
        
        
        
      
        //Collision
        physicsWorld.contactDelegate = self
        
        landImpact = childNode(withName: "landImpact") as? SKSpriteNode
        landImpact?.physicsBody?.categoryBitMask = landImpactCategory
        landImpact?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        landImpact?.physicsBody?.collisionBitMask = groundAndCeilingCategory
        var landImpactRun : [SKTexture] = []
        for number in 1...5 {
            landImpactRun.append(SKTexture(imageNamed: "a\(number)"))
        }
        
        landImpact?.run(SKAction.repeatForever(SKAction.animate(with: landImpactRun, timePerFrame: 0.09)))
        
        //ground = childNode(withName: "ground") as? SKSpriteNode
        //ground?.physicsBody?.categoryBitMask = groundAndCeilingCategory
        //ground?.physicsBody?.collisionBitMask = landImpactCategory
        
        //ceiling = childNode(withName: "ceiling") as? SKSpriteNode
        //ceiling?.physicsBody?.categoryBitMask = groundAndCeilingCategory
        //ground?.physicsBody?.collisionBitMask = landImpactCategory
        
        scoreLabel = childNode(withName: "scoreLabel" ) as? SKLabelNode
        
        startTimer()
        generateGround()
    }
    
    func generateGround() {
        let sizingGround = SKSpriteNode(imageNamed: "ground")
        let numberOfGround = Int(size.width / sizingGround.size.width) + 1
        for number in 0...numberOfGround {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = groundAndCeilingCategory
            ground.physicsBody?.collisionBitMask = landImpactCategory
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            addChild(ground)
            
            let groundX = -size.width / 2 + ground.size.width / 2 + ground.size.width * CGFloat(number)
            ground.position = CGPoint(x: groundX, y: -size.height / 2 + ground.size.height / 2 - 18)
            let speed = 100.0
            let firstMoveLeft = SKAction.moveBy(x: -ground.size.width - ground.size.width * CGFloat(number),
                y: 0, duration: TimeInterval(ground.size.width + ground.size.width * CGFloat(number)) / speed)
            
            let resetGround = SKAction.moveBy(x: size.width + ground.size.width, y: 0, duration: 0)
            let groundFullMove = SKAction.moveBy(x: -size.width - ground.size.width, y: 0, duration: TimeInterval(size.width + ground.size.width) / speed)
            let groundMovingForever = SKAction.repeatForever(SKAction.sequence([groundFullMove, resetGround]))
            
            ground.run(SKAction.sequence([firstMoveLeft, resetGround, groundMovingForever]))
        }
    }
    
    func startTimer(){
        //Setting up timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(Timer) in self.generateCoin()})
        
        //Setting up timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: {(Timer) in self.generateExplosion()})    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scene?.isPaused == false {
        landImpact?.physicsBody?.applyForce(CGVector(dx: 0, dy: 10000))
        }
        let touch = touches.first
        if let location = touch?.location(in: self){
            let theNodes = nodes(at: location)
            
            for node in theNodes {
                if node.name == "play"{
                    score = 0 // restart game
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimer()
                }
            }
        }
    }
    
    func generateCoin(){
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = landImpactCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        let sizingGround = SKSpriteNode(imageNamed: "ground")
        
        let maximumY = size.height / 2 - coin.size.height / 2
        let minimumY = -size.height / 2 + coin.size.height / 2 + sizingGround.size.height
        let range = maximumY - minimumY
        let coinY = maximumY - CGFloat(arc4random_uniform(UInt32(range)))
        
        coin.position = CGPoint(x: size.width / 2 + coin.size.width / 2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - coin.size.width, y: 0, duration: 5)
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
 
    
    func generateExplosion(){
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = landImpactCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        
        let sizingGround = SKSpriteNode(imageNamed: "ground")
        
        let maximumY = size.height / 2 - bomb.size.height / 2
        let minimumY = -size.height / 2 + bomb.size.height / 2 + sizingGround.size.height
        let range = maximumY - minimumY
        let bombY = maximumY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position = CGPoint(x: size.width / 2 + bomb.size.width / 2, y: bombY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 5)
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        score += 1
        scoreLabel?.text = "Score: \(score)"
        
        //Business Rules
        if contact.bodyA.categoryBitMask == coinCategory {
            contact.bodyA.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        if contact.bodyB.categoryBitMask == coinCategory{
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"        }
        
        if contact.bodyA.categoryBitMask == bombCategory {
            contact.bodyA.node?.removeFromParent()
                gameOver()
        }
        
        if contact.bodyB.categoryBitMask == bombCategory{
            contact.bodyB.node?.removeFromParent()
                gameOver()
            
        }
        
    }
    
    func gameOver(){
        scene?.isPaused = true
        gameTimer?.invalidate()
        bombTimer?.invalidate()
        
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil{
            addChild(yourScoreLabel!)
        }
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if finalScoreLabel != nil{
            addChild(finalScoreLabel!)
        }
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
    }
}
