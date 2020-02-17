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
    
    override func didMove(to view: SKView) {
        let tapRestartLabel = childNode(withName: "tapRestartLabel") as! SKLabelNode
        tapRestartLabel.text = ""
        tapRestartLabel.position = CGPoint(x: self.frame.midX, y: tapRestartLabel.position.y)
        tapRestartLabel.fontName = "Optima-ExtraBlack"
//        self.backgroundColor = SKColor(red:127.0/256.0, green:120.0/256.0, blue:106.0/256.0, alpha:1.0)
        self.backgroundColor = .black
        
        let tutorialLabel = childNode(withName: "tutorialLabel") as! SKLabelNode
        tutorialLabel.text = ""
        tutorialLabel.position = CGPoint(x: self.frame.midX, y: tutorialLabel.position.y)
        tutorialLabel.fontName = "Optima-ExtraBlack"
        
        let box1 = childNode(withName: "box1") as! SKShapeNode
        box1.position = CGPoint(x: self.frame.midX, y: box1.position.y)
        let box2 = childNode(withName: "box2") as! SKShapeNode
        box2.position = CGPoint(x: self.frame.midX, y: box2.position.y)
        let box3 = SKShapeNode(rect: CGRect(x: 30, y: 635, width: 720, height: 350))
        box3.strokeTexture = SKTexture(imageNamed: "star.png")
        box3.lineWidth = 50
        box3.strokeColor = box2.strokeColor
        self.addChild(box3)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.showRestarts()
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        print("leaderboard or achievements view finished")
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
    func showRestarts() {
        canRestart = true
        let tapRestartLabel = childNode(withName:"tapRestartLabel") as! SKLabelNode
        tapRestartLabel.position = CGPoint(x: self.frame.midX, y: tapRestartLabel.position.y)
        tapRestartLabel.text = "Restart"
        tapRestartLabel.fontName = "Optima-ExtraBlack"
        let tutorialLabel = childNode(withName:"tutorialLabel") as! SKLabelNode
        tutorialLabel.position = CGPoint(x: self.frame.midX, y: tutorialLabel.position.y)
        tutorialLabel.text = "Tutorial"
        tutorialLabel.fontName = "Optima-ExtraBlack"
        
    }
    
    var gameScore : Int = 0 {
        // 1.
        didSet {
            let scoreLabel = childNode(withName:"scoreLabel") as! SKLabelNode
            scoreLabel.position = CGPoint(x: self.frame.midX, y: scoreLabel.position.y)
            scoreLabel.text = "Matter This Run: " + convertNumber(num: gameScore)
            scoreLabel.fontName = "Optima-ExtraBlack"
        }
    }
    var highScore : Int = 0 {
        // 1.
        didSet {
            let highestLabel = childNode(withName:"highestLabel") as! SKLabelNode
            highestLabel.position = CGPoint(x: self.frame.midX, y: highestLabel.position.y)
            highestLabel.text = "Highest: " + convertNumber(num: highScore)
            highestLabel.fontName = "Optima-ExtraBlack"
        }
    }
    
    func convertNumber(num: Int) -> String {
        if(num>1000000000) {
            let rounded = NSString(format: "%.01f", Float(num)/1000000000.0)
            return String(rounded) + "b"
        } else if(num>1000000) {
            let rounded = NSString(format: "%.01f", Float(num)/1000000.0)
            return String(rounded) + "m"
        } else if(num>1000) {
            let rounded = NSString(format: "%.01f", Float(num)/1000.0)
            return String(rounded) + "k"
        } else {
            return String(num)
        }
    }
    
    var lifetime : Int = 0 {
        // 1.
        didSet {
            let lifetimeLabel = childNode(withName:"lifetime") as! SKLabelNode
            lifetimeLabel.position = CGPoint(x: self.frame.midX, y: lifetimeLabel.position.y)
            lifetimeLabel.text = "Lifetime Matter: " + self.convertNumber(num: lifetime)
            let starType = childNode(withName:"starType") as! SKLabelNode
            starType.position = CGPoint(x: self.frame.midX, y: starType.position.y)
            starType.fontName = "Optima-ExtraBlack"
            let nextType = childNode(withName:"nextType") as! SKLabelNode
            nextType.position = CGPoint(x: self.frame.midX, y: nextType.position.y)
            starType.text = "White Dwarf"
            starType.fontColor = UIColor.white
            nextType.text = "Yellow Star at 1k Matter"
            starType.fontName = "Optima-ExtraBlack"
            if lifetime > 1000000 {
                starType.text = "Pulsar"
                starType.fontColor = UIColor.purple
                nextType.text = "You're the best star type!"
            } else if lifetime > 100000 {
                starType.text = "Blue Giant"
                starType.fontColor = UIColor.blue
                nextType.text = "Pulsar at 1m Matter"
            } else if lifetime > 10000 {
                starType.text = "Red Giant"
                starType.fontColor = UIColor.red
                nextType.text = "Blue Giant at 100k Matter"
            } else if lifetime > 1000 {
                starType.text = "Yellow Star"
                starType.fontColor = UIColor.yellow
                nextType.text = "Red Giant at 10k Matter"
            }
            let starTypeShadow = SKLabelNode(text: starType.text)
            starTypeShadow.fontColor = UIColor.black
            starTypeShadow.fontName = starType.fontName
            starTypeShadow.fontSize = starType.fontSize
            starTypeShadow.position = CGPoint(x: starType.position.x - 2, y: starType.position.y - 2)
            starTypeShadow.zPosition = starType.zPosition - 1
            starType.parent!.addChild(starTypeShadow)
            
        }
    }
    
    func testTouch(touches: Set<NSObject>, rect:CGRect) {
 
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        if let name = touchedNode.name
        {
            if name == "leadersLabel" {
                print("Touched Leaders")
                showLeaderboardAndAchievements(showLeaderboard: true)
            } else if name == "awardsLabel" {
                print("Touched Awards")
                showLeaderboardAndAchievements(showLeaderboard: false)
            } else if name == "box1" || name == "tapRestartLabel" {
                print("Touched Restart")
                if(canRestart) {
                    if let view = view {
                        // 2.
                        let gameScene = GameScene(size: view.bounds.size)
                        gameScene.scaleMode = .resizeFill
                        view.presentScene(gameScene)
                    }
                }
            } else if name == "box2" || name == "tutorialLabel" {
                print("Touched Tutorial")
                if(canRestart) {
                    if let view = view {
                        UserDefaults.standard.set(0, forKey: "tutorial")
                        // 2.
                        let gameScene = GameScene(size: view.bounds.size)
                        gameScene.scaleMode = .resizeFill
                        view.presentScene(gameScene)
                    }
                }
            }
        }
    
    }

    func showLeaderboardAndAchievements(showLeaderboard:Bool) {
        print("checkout leaderboards or achievements")
        let view = GKGameCenterViewController()
        view.gameCenterDelegate = self
        if showLeaderboard {
            view.viewState = GKGameCenterViewControllerState.leaderboards
            view.leaderboardIdentifier = "single_run_matter"
        } else {
            view.viewState = GKGameCenterViewControllerState.achievements
        }
        self.view!.window!.rootViewController!.present(view, animated: true, completion: nil)
    }
}
