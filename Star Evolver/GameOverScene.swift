//
//  GameOverScene.swift
//  Star Evolver
//
//  Created by Drew Bratcher on 4/28/15.
//  Copyright (c) 2015 Drew Bratcher. All rights reserved.
//

import SpriteKit
import GameKit

class GameOverScene: SKScene, GKGameCenterControllerDelegate {
    
    var canRestart = false
    
    override func didMoveToView(view: SKView) {
        let tapRestartLabel = childNodeWithName("tapRestartLabel") as! SKLabelNode
        tapRestartLabel.text = ""
        tapRestartLabel.position = CGPoint(x: self.frame.midX, y: tapRestartLabel.position.y)
        tapRestartLabel.fontName = "Optima-ExtraBlack"
        self.backgroundColor = SKColor(red:127.0/256.0, green:120.0/256.0, blue:106.0/256.0, alpha:1.0)
        
        let tutorialLabel = childNodeWithName("tutorialLabel") as! SKLabelNode
        tutorialLabel.text = ""
        tutorialLabel.position = CGPoint(x: self.frame.midX, y: tutorialLabel.position.y)
        tutorialLabel.fontName = "Optima-ExtraBlack"
        
        let box1 = childNodeWithName("box1") as! SKShapeNode
        box1.position = CGPoint(x: self.frame.midX, y: box1.position.y)
        let box2 = childNodeWithName("box2") as! SKShapeNode
        box2.position = CGPoint(x: self.frame.midX, y: box2.position.y)
        let box3 = SKShapeNode(rect: CGRect(x: 30, y: 635, width: 720, height: 350))
        box3.strokeTexture = SKTexture(imageNamed: "star.png")
        box3.lineWidth = 50
        box3.strokeColor = box2.strokeColor
        self.addChild(box3)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.showRestarts()
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        println("leaderboard or achievements view finished")
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func showRestarts() {
        canRestart = true
        let tapRestartLabel = childNodeWithName("tapRestartLabel") as! SKLabelNode
        tapRestartLabel.position = CGPoint(x: self.frame.midX, y: tapRestartLabel.position.y)
        tapRestartLabel.text = "Restart"
        tapRestartLabel.fontName = "Optima-ExtraBlack"
        let tutorialLabel = childNodeWithName("tutorialLabel") as! SKLabelNode
        tutorialLabel.position = CGPoint(x: self.frame.midX, y: tutorialLabel.position.y)
        tutorialLabel.text = "Tutorial"
        tutorialLabel.fontName = "Optima-ExtraBlack"
        
    }
    
    var gameScore : Int = 0 {
        // 1.
        didSet {
            let scoreLabel = childNodeWithName("scoreLabel") as! SKLabelNode
            scoreLabel.position = CGPoint(x: self.frame.midX, y: scoreLabel.position.y)
            scoreLabel.text = "Matter This Run: " + convertNumber(gameScore)
            scoreLabel.fontName = "Optima-ExtraBlack"
        }
    }
    var highScore : Int = 0 {
        // 1.
        didSet {
            let highestLabel = childNodeWithName("highestLabel") as! SKLabelNode
            highestLabel.position = CGPoint(x: self.frame.midX, y: highestLabel.position.y)
            highestLabel.text = "Highest: " + convertNumber(highScore)
            highestLabel.fontName = "Optima-ExtraBlack"
        }
    }
    
    func convertNumber(num:Int) -> String {
        if(num>1000000000) {
            var rounded = NSString(format: "%.01f", Float(num)/1000000000.0)
            return String(rounded) + "b"
        } else if(num>1000000) {
            var rounded = NSString(format: "%.01f", Float(num)/1000000.0)
            return String(rounded) + "m"
        } else if(num>1000) {
            var rounded = NSString(format: "%.01f", Float(num)/1000.0)
            return String(rounded) + "k"
        } else {
            return String(num)
        }
    }
    
    var lifetime : Int = 0 {
        // 1.
        didSet {
            let lifetimeLabel = childNodeWithName("lifetime") as! SKLabelNode
            lifetimeLabel.position = CGPoint(x: self.frame.midX, y: lifetimeLabel.position.y)
            lifetimeLabel.text = "Lifetime Matter: " + self.convertNumber(lifetime)
            let starType = childNodeWithName("starType") as! SKLabelNode
            starType.position = CGPoint(x: self.frame.midX, y: starType.position.y)
            starType.fontName = "Optima-ExtraBlack"
            let nextType = childNodeWithName("nextType") as! SKLabelNode
            nextType.position = CGPoint(x: self.frame.midX, y: nextType.position.y)
            starType.text = "White Dwarf"
            starType.fontColor = UIColor.whiteColor()
            nextType.text = "Yellow Star at 1k Matter"
            starType.fontName = "Optima-ExtraBlack"
            if lifetime > 1000000 {
                starType.text = "Pulsar"
                starType.fontColor = UIColor.purpleColor()
                nextType.text = "You're the best star type!"
            } else if lifetime > 100000 {
                starType.text = "Blue Giant"
                starType.fontColor = UIColor.blueColor()
                nextType.text = "Pulsar at 1m Matter"
            } else if lifetime > 10000 {
                starType.text = "Red Giant"
                starType.fontColor = UIColor.redColor()
                nextType.text = "Blue Giant at 100k Matter"
            } else if lifetime > 1000 {
                starType.text = "Yellow Star"
                starType.fontColor = UIColor.yellowColor()
                nextType.text = "Red Giant at 10k Matter"
            }
            let starTypeShadow = SKLabelNode(text: starType.text)
            starTypeShadow.fontColor = UIColor.blackColor()
            starTypeShadow.fontName = starType.fontName
            starTypeShadow.fontSize = starType.fontSize
            starTypeShadow.position = CGPoint(x: starType.position.x - 2, y: starType.position.y - 2)
            starTypeShadow.zPosition = starType.zPosition - 1
            starType.parent!.addChild(starTypeShadow)
            
        }
    }
    
    func testTouch(touches: Set<NSObject>, rect:CGRect) {
 
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch:UITouch = touches.first as! UITouch
        let positionInScene = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
        
        if let name = touchedNode.name
        {
            if name == "leadersLabel" {
                println("Touched Leaders")
                showLeaderboardAndAchievements(true)
            } else if name == "awardsLabel" {
                println("Touched Awards")
                showLeaderboardAndAchievements(false)
            } else if name == "box1" || name == "tapRestartLabel" {
                println("Touched Restart")
                if(canRestart) {
                    if let view = view {
                        // 2.
                        let gameScene = GameScene(size: view.bounds.size)
                        gameScene.scaleMode = .ResizeFill
                        view.presentScene(gameScene)
                    }
                }
            } else if name == "box2" || name == "tutorialLabel" {
                println("Touched Tutorial")
                if(canRestart) {
                    if let view = view {
                        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "tutorial")
                        // 2.
                        let gameScene = GameScene(size: view.bounds.size)
                        gameScene.scaleMode = .ResizeFill
                        view.presentScene(gameScene)
                    }
                }
            }
        }
    
    }

    func showLeaderboardAndAchievements(showLeaderboard:Bool) {
        println("checkout leaderboards or achievements")
        let view = GKGameCenterViewController()
        view.gameCenterDelegate = self
        if showLeaderboard {
            view.viewState = GKGameCenterViewControllerState.Leaderboards
            view.leaderboardIdentifier = "single_run_matter"
        } else {
            view.viewState = GKGameCenterViewControllerState.Achievements
        }
        self.view!.window!.rootViewController!.presentViewController(view, animated: true, completion: nil)
    }
}