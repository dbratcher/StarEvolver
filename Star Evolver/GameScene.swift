//
//  GameScene.swift
//  Star Evolver
//
//  Created by Drew Bratcher on 4/25/15.
//  Copyright (c) 2015 Drew Bratcher. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene, GKGameCenterControllerDelegate {
    var tempo = 0
    var level = 1
    var score = 0
    var lifetime_score = 0
    var levelTime = 10
    var stars = Set<Star>()
    var matter = Set<Matter>()
    var myStar: Star!
    var matterPool = MatterPool()
    var tapToStart = false
    var firstStarDestroyed = false
    var tapToStartLabel: SKLabelNode?
    var instructionLabel: SKLabelNode?
    var instructionLabel2: SKLabelNode?
    var beginLabel: SKLabelNode?
    var matterCollected: SKLabelNode?
    var arrow1: SKShapeNode?
    var arrow2: SKShapeNode?
    var previousLifetime = 0
    var previousScore = 0
    var achievements = [String:GKAchievement]()
    var rootNode = SKNode()
    
    override func didMove(to view: SKView) {
        // Game Center sign-in happens once in GameViewController.
        if GKLocalPlayer.local.isAuthenticated { loadAchievements() }
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.removeAllChildren()
        self.removeAllActions()
        tempo = 0
        level = 1
        score = 0
        levelTime = 10
        stars = Set<Star>()
//        self.backgroundColor = SKColor(red:127.0/256.0, green:120.0/256.0, blue:106.0/256.0, alpha:1.0)
        self.backgroundColor = .black
        let center = CGPoint(x: frame.midX, y: frame.midY)
        let zero = CGPoint(x: 0, y: 0)
        self.rootNode.position = center
        lifetime_score = UserDefaults.standard.integer(forKey:"lifetime_score")
        var starColor = SKColor.white
        var insideColor = SKColor.lightGray
        if lifetime_score > 1000000 {
            starColor = SKColor.purple
            insideColor = SKColor.darkGray
        } else if lifetime_score > 100000 {
            starColor = SKColor.blue
            insideColor = SKColor.cyan
        } else if lifetime_score > 10000 {
            starColor = SKColor.red
            insideColor = SKColor.orange
        } else if lifetime_score > 1000 {
            starColor = SKColor.yellow
            insideColor = SKColor.darkGray
        }
        myStar = Star(position: zero, scene: self.rootNode, color:starColor, mass:2, setInsideColor: insideColor)
        lifetime_score = UserDefaults.standard.integer(forKey:"lifetime_score")
        let zoomOut = SKAction.scale(to: 0.2, duration: 0)
        myStar.run(action: zoomOut)
        
        
        matterCollected = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        matterCollected!.text = "Matter: " + String(score)
        // Pin the counter near the top, below the status bar / Dynamic Island.
        let topInset = view.safeAreaInsets.top
        matterCollected!.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - topInset - 30)
        matterCollected?.fontSize = 15
        self.addChild(matterCollected!)
        // First run (or after tapping Tutorial on game over): show the tutorial.
        // The ramp starts once the player finishes it.
        let ranTutorial = UserDefaults.standard.integer(forKey:"tutorial")
        if ranTutorial == 0 {
            tapToStart = true
            tutorial()
        } else {
            increaseTempo()
        }

        // handle zooming

        let zoomHandler = UIPinchGestureRecognizer(target: self, action: #selector(handleZoom(sender:)))
        self.view?.addGestureRecognizer(zoomHandler)
        self.zoomHandler = zoomHandler

        self.addChild(self.rootNode)
    }

    private var zoomHandler: UIPinchGestureRecognizer?

    override func willMove(from view: SKView) {
        // Don't leave this scene's pinch recognizer on the view after a restart.
        if let zoomHandler = zoomHandler {
            view.removeGestureRecognizer(zoomHandler)
        }
    }

    @objc func handleZoom(sender:UIPinchGestureRecognizer) {
        print(sender.scale)
        if sender.scale < 1 {
            rootNode.xScale -= 0.01
            rootNode.yScale -= 0.01
        }
        if sender.scale > 1 {
            rootNode.xScale += 0.01
            rootNode.yScale += 0.01
        }
        
        print(rootNode.xScale)
        print(rootNode.yScale)
    }

    
    func loadAchievements() {
        GKAchievement.loadAchievements { (loaded, error) -> Void in
            if error != nil {
                print(error ?? "no error")
                return
            }
            for one in loaded ?? [] {
                self.achievements[one.identifier] = one
            }
        }
    }
    
    func updatePercentComplete(award:GKAchievement, score:Int, divisor:Int, lastScore:Int, displayName:String) {
        award.percentComplete = Double(score * 100 / divisor)
        if lastScore != 0 {
            let lastPercentComplete = Double(lastScore * 100 / divisor)
            let not_filled = achievements[award.identifier] != nil && achievements[award.identifier]?.isCompleted == nil
            if award.percentComplete >= 100.0 && lastPercentComplete < 100.0 && not_filled {
                print("need to show something")
                showBanner(title: "Awarded " + displayName , message: nil)
            }
        }
    }
    
    func showBanner(title:String, message: String?) {
        GKNotificationBanner.show(withTitle: title, message: message, completionHandler: nil)
    }
    
    
    func updateAchievements() {
        let tempLifetime = UserDefaults.standard.integer(forKey:"lifetime_score") + score
        let matter1 = GKAchievement(identifier: "matter_collected_1")
        updatePercentComplete(award: matter1, score: score, divisor: 5, lastScore: previousScore, displayName: "Matter Collected")
        let star_destroyer = GKAchievement(identifier: "star_destroyer")
        updatePercentComplete(award: star_destroyer, score: score, divisor: 100, lastScore: previousScore, displayName: "Star Destroyer")
        let sun_crusher = GKAchievement(identifier: "sun_crusher")
        updatePercentComplete(award: sun_crusher, score: score, divisor: 500, lastScore: previousScore, displayName: "Sun Crusher")
        let world_devourer = GKAchievement(identifier: "world_devourer")
        updatePercentComplete(award: world_devourer, score: score, divisor: 1000, lastScore: previousScore, displayName: "World Devourer")
        let white_dwarf = GKAchievement(identifier: "star_size_1")
        updatePercentComplete(award: white_dwarf, score: tempLifetime, divisor: 10, lastScore: previousLifetime, displayName: "White Dwarf")
        let yellow_star = GKAchievement(identifier: "yellow_star")
        updatePercentComplete(award: yellow_star, score: tempLifetime, divisor: 1000, lastScore: previousLifetime, displayName: "Yellow Star")
        let red_giant = GKAchievement(identifier: "red_giant")
        updatePercentComplete(award: red_giant, score: tempLifetime, divisor: 10000, lastScore: previousLifetime, displayName: "Red Giant")
        let blue_giant = GKAchievement(identifier: "blue_giant")
        updatePercentComplete(award: blue_giant, score: tempLifetime, divisor: 100000, lastScore: previousLifetime, displayName: "Blue Giant")
        let pulsar = GKAchievement(identifier: "pulsar")
        pulsar.percentComplete = 0.0
        if tempLifetime > 1000000 {
            pulsar.percentComplete = 100.0
        }
        let achieved = [matter1, star_destroyer, sun_crusher, world_devourer, white_dwarf, yellow_star, red_giant, blue_giant, pulsar]
        if GKLocalPlayer.local.isAuthenticated {
            GKAchievement.report(achieved, withCompletionHandler: nil)
        }
        previousLifetime = tempLifetime
        previousScore = score
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        print("game center view finished")
    }
    
    
    // Tutorial star stops this far above your star (rootNode coordinates, origin = screen center).
    let tutorialStarOffset: CGFloat = 170

    func tutorial() {
        // Fly a star in from the top and park it above the player's star.
        // Stars live in rootNode, whose origin is the screen center.
        let startPoint = CGPoint(x: 0, y: frame.height / 2 + 60)
        let randomRed = CGFloat(drand48() + 0.5)
        let randomGreen = CGFloat(drand48() + 0.5)
        let randomBlue = CGFloat(drand48() + 0.5)
        let randomColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        let newStar = Star(position: startPoint, scene: self.rootNode, color:randomColor, mass:0, setInsideColor: nil)
        stars.insert(newStar)
        let zoomOut = SKAction.scale(by: 0.2, duration: 0)
        newStar.run(action: zoomOut)
        let moveIn = SKAction.move(to: CGPoint(x: 0, y: tutorialStarOffset), duration: TimeInterval(1))
        newStar.run(action: moveIn)

        // Labels and arrows live in scene coordinates.
        let starY = frame.midY + tutorialStarOffset
        tapToStartLabel = makeTutorialLabel("Tap To Destroy", y: starY + 95)
        arrow1 = makeDownArrow(tipY: starY + 40)
    }

    func makeTutorialLabel(_ text: String, y: CGFloat, fontSize: CGFloat = 28) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: y)
        addChild(label)
        return label
    }

    /// A small downward-pointing triangle whose tip sits at tipY.
    func makeDownArrow(tipY: CGFloat) -> SKShapeNode {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.midX - 25, y: tipY + 25))
        path.addLine(to: CGPoint(x: frame.midX, y: tipY))
        path.addLine(to: CGPoint(x: frame.midX + 25, y: tipY + 25))
        path.close()
        let arrow = SKShapeNode(path: path.cgPath)
        arrow.fillColor = .lightGray
        arrow.strokeColor = .lightGray
        addChild(arrow)
        return arrow
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if tapToStart && firstStarDestroyed {
            arrow2?.removeFromParent()
            instructionLabel?.removeFromParent()
            instructionLabel2?.removeFromParent()
            beginLabel?.removeFromParent()
            tapToStart = false
            increaseTempo()
            UserDefaults.standard.set(1, forKey: "tutorial")
        }
        
        for touch in touches {
            let location = touch.location(in: self.rootNode)
            print("checking user touch at x: " + String(describing: location.x) + " y: " + String(describing: location.y))
            for star in stars {
                if star.hasLocation(location: location) {
                    print("user got star:" + String(star.hashValue));
                    
                    if tapToStart {
                        arrow1?.removeFromParent()
                        tapToStartLabel?.removeFromParent()
                        firstStarDestroyed = true
                        // Point at the player's star (screen center).
                        instructionLabel2 = makeTutorialLabel("Protect Your Star", y: frame.midY + 115)
                        arrow2 = makeDownArrow(tipY: frame.midY + 45)
                        instructionLabel = makeTutorialLabel("Collect Matter", y: frame.midY - 120)
                        beginLabel = makeTutorialLabel("Tap anywhere to begin", y: frame.midY - 220, fontSize: 18)
                    }
                    
                    
                    let newMatter1 = matterPool.getMatter(position: location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: 0, dy: 50))
                    matter.insert(newMatter1)
                    let newMatter2 = matterPool.getMatter(position: location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: 50, dy: 0))
                    matter.insert(newMatter2)
                    let newMatter3 = matterPool.getMatter(position: location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: -50, dy: 0))
                    matter.insert(newMatter3)
                    let newMatter4 = matterPool.getMatter(position: location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: 0, dy: -50))
                    matter.insert(newMatter4)
//
//                    let newMatter5 = Matter(position: location, scene: self, color: star.color, radius: 5)
//                    newMatter5.square.physicsBody?.applyForce(CGVector(dx: 25, dy: -25))
//                    matter.insert(newMatter5)
//                    let newMatter6 = Matter(position: location, scene: self, color: star.color, radius: 5)
//                    newMatter6.square.physicsBody?.applyForce(CGVector(dx: 25, dy: 25))
//                    matter.insert(newMatter6)
//                    let newMatter7 = Matter(position: location, scene: self, color: star.color, radius: 5)
//                    newMatter7.square.physicsBody?.applyForce(CGVector(dx: -25, dy: -25))
//                    matter.insert(newMatter7)
//                    let newMatter8 = Matter(position: location, scene: self, color: star.color, radius: 5)
//                    newMatter8.square.physicsBody?.applyForce(CGVector(dx: -25, dy: 25))
//                    matter.insert(newMatter8)
                    print("matter created")
                    star.remove()
                    stars.remove(star)
                }
            }
            
        }
    }
    
    
    func increaseTempo(){
        
        // Scene action instead of a dispatch timer: it stops when the scene goes away,
        // so finished runs don't keep ticking (and stay in memory) after a restart.
        run(SKAction.sequence([
            SKAction.wait(forDuration: Double(levelTime) * 2),
            SKAction.run { [weak self] in self?.increaseTempo() }
        ]), withKey: "tempo")

        print("increasing tempo")
        tempo += 1
        if tempo > level {
            increaseLevel()
        }
    }
    
    func increaseLevel(){
        print("increasing level")
        tempo = 1
        level += 1
        levelTime *= 2
    }
    
    func reportSingleScore(matter:Int) {
        submitScore(matter, leaderboardID: "single_run_matter")
    }

    func reportLifetimeScore(matter:Int) {
        submitScore(matter, leaderboardID: "lifetime_matter")
    }

    private func submitScore(_ value: Int, leaderboardID: String) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(value, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: [leaderboardID]) { error in
            print("sent \(leaderboardID) score \(value): \(String(describing: error))")
        }
    }
   
    override func update(_ currentTime: CFTimeInterval) {
        
        
        let center = CGPoint(x: 0, y: 0)
        if stars.count < level && !tapToStart {
            print("need to generate new star")
            let randomX = CGFloat(Int(arc4random()) % Int(frame.width)) - frame.midX
            let randomY = CGFloat(Int(arc4random()) % 2 * Int(frame.height+200)) - 100 - frame.midY // Top or Bottom
            let randomSpeed = Float(arc4random()).truncatingRemainder(dividingBy: 10) / 5 + 2
            let randomPoint = CGPoint(x: randomX, y: randomY)
            let randomRed = CGFloat(drand48() + 0.5)
            let randomGreen = CGFloat(drand48() + 0.5)
            let randomBlue = CGFloat(drand48() + 0.5)
            let randomColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
            let newStar = Star(position: randomPoint, scene: self.rootNode, color:randomColor, mass:0, setInsideColor: nil )
            stars.insert(newStar)
            let zoomOut = SKAction.scale(by: 0.2, duration: 0)
            newStar.run(action: zoomOut)
            let moveToCenter = SKAction.move(to: center, duration: TimeInterval(randomSpeed))
            newStar.run(action: moveToCenter)
            print("new star generated, stars size: " + String(stars.count))
        }
        
        myStar.updateRadius()
        for star in stars {
            if star.distanceFrom(location: center) < star.radius + myStar.radius {
                print("hit center with star: \(star)")
                star.remove()
                stars.remove(star)
                self.runEnded()
            }
        }
        
        for piece in matter {
            if Int(piece.distanceFrom(location: center)) < Int(piece.radius) + Int(myStar.radius) {
                print("collected some matter")
                updateAchievements()
                matter.remove(piece)
                matterPool.returnMatter(usedMatter: piece)
                score+=1
                if score % 100 == 0 {
                    let grow = SKAction.scale(by: 1.10, duration: 2)
                    myStar.run(action: grow)
                }
                matterCollected!.text = "Matter: " + String(score)
            }
        }
    }

    func runEnded() {
        if let mainView = view {
            let gameOverScene = GameOverScene.unarchiveFromFile(file: "GameOverScene") as! GameOverScene
            // The .sks is laid out at 768x1024; fit it to the screen instead of cropping it.
            gameOverScene.scaleMode = .aspectFit

            lifetime_score = UserDefaults.standard.integer(forKey:"lifetime_score") + score
            UserDefaults.standard.set(lifetime_score, forKey: "lifetime_score")
            
            if score > UserDefaults.standard.integer(forKey:"highscore") {
                UserDefaults.standard.set(score, forKey: "highscore")
            }
            
            gameOverScene.lifetime = lifetime_score
            gameOverScene.gameScore = score
            gameOverScene.highScore = UserDefaults.standard.integer(forKey:"highscore")
            mainView.presentScene(gameOverScene)
            
            
            self.reportLifetimeScore(matter: lifetime_score)
            self.reportSingleScore(matter: score)
        }
    }
}

func ==(lhs:Star, rhs:Star) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func ==(lhs:Matter, rhs:Matter) -> Bool {
    return lhs.hashValue == rhs.hashValue
}




