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
    var matterCollected: SKLabelNode?
    var arrow_path1: UIBezierPath?
    var arrow_path2: UIBezierPath?
    var arrow1: SKShapeNode?
    var arrow2: SKShapeNode?
    var previousLifetime = 0
    var previousScore = 0
    var achievements = [String:GKAchievement]()
    var rootNode = SKNode()
    
    override func didMove(to view: SKView) {
//        authenticateLocalPlayer()
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.removeAllChildren()
        self.removeAllActions()
        tempo = 0
        level = 1
        score = 0
        levelTime = 10
        stars = Set<Star>()
        self.backgroundColor = SKColor(red:127.0/256.0, green:120.0/256.0, blue:106.0/256.0, alpha:1.0)
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
        matterCollected!.position = CGPoint(x: self.frame.midX, y: 520)
        matterCollected?.fontSize = 15
        self.addChild(matterCollected!)
//
//        let ranTutorial = UserDefaults.standard.integer(forKey:"tutorial")
//        if ranTutorial == 0 {
//            tapToStart = true
//            tutorial()
//        } else {
//            increaseTempo()
//        }
        
        // handle zooming
        
        let zoomHandler = UIPinchGestureRecognizer(target: self, action: #selector(handleZoom(sender:)))
        self.view?.addGestureRecognizer(zoomHandler)
        
        self.addChild(self.rootNode)
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

    func authenticateLocalPlayer() {
        print("authing user")
        let localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler =  {(viewController:UIViewController!, error:Error!) -> Void in
            if(error != nil) {
                print(error ?? "no error")
            }
            if ((viewController) != nil) {
                print("view controller launched")
                self.view!.window!.rootViewController!.present(viewController, animated: true, completion: {
                    self.loadAchievements()
                })
            } else {
                self.showBanner(title: "Welcome Back " + GKLocalPlayer.local.alias, message: nil)
                self.loadAchievements()
            }
        }
        
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
        GKAchievement.report(achieved, withCompletionHandler: nil)
        previousLifetime = tempLifetime
        previousScore = score
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        print("game center view finished")
    }
    
    
    func tutorial() {
        
        // move node in for 1 sec
        let randomPoint = CGPoint(x: frame.midX, y: 0)
        let randomRed = CGFloat(drand48() + 0.5)
        let randomGreen = CGFloat(drand48() + 0.5)
        let randomBlue = CGFloat(drand48() + 0.5)
        let randomColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        let newStar = Star(position: randomPoint, scene: self.rootNode, color:randomColor, mass:0, setInsideColor: nil)
        stars.insert(newStar)
        let zoomOut = SKAction.scale(by: 0.2, duration: 0)
        newStar.run(action: zoomOut)
        let moveToCenter = SKAction.move(to: CGPoint(x: frame.midX, y: 100), duration: TimeInterval(1))
        newStar.run(action: moveToCenter)
        
        // show tap to destroy label
        tapToStartLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        tapToStartLabel!.text = "Tap To Destroy"
        tapToStartLabel!.position = CGPoint(x: self.frame.midX, y: 200)
        self.addChild(tapToStartLabel!)
        // show arrow
        
        arrow_path1 = UIBezierPath()
        arrow_path1?.move(to: CGPoint(x: self.frame.midX-50, y: 180))
        arrow_path1?.addLine(to: CGPoint(x: self.frame.midX, y: 150))
        arrow_path1?.addLine(to: CGPoint(x: self.frame.midX+50, y: 180))
        arrow_path1?.close()
        arrow1 = SKShapeNode(path: arrow_path1!.cgPath)
        arrow1?.fillColor = UIColor.darkGray
        self.addChild(arrow1!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if tapToStart && firstStarDestroyed {
            arrow2?.removeFromParent()
            instructionLabel?.removeFromParent()
            instructionLabel2?.removeFromParent()
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
                        instructionLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
                        instructionLabel!.text = "Collect Matter"
                        instructionLabel!.position = CGPoint(x: self.frame.midX, y: 150)
                        self.addChild(instructionLabel!)
                        instructionLabel2 = SKLabelNode(fontNamed: "Optima-ExtraBlack")
                        instructionLabel2!.text = "Protect Your Star"
                        instructionLabel2!.position = CGPoint(x: self.frame.midX, y: 400)
                        self.addChild(instructionLabel2!)
                        arrow_path2 = UIBezierPath()
                        arrow_path2?.move(to: CGPoint(x: self.frame.midX-50, y: 380))
                        arrow_path2?.addLine(to: CGPoint(x: self.frame.midX, y: 350))
                        arrow_path2?.addLine(to: CGPoint(x: self.frame.midX+50, y: 380))
                        arrow_path2?.close()
                        arrow2 = SKShapeNode(path: arrow_path2!.cgPath)
                        arrow2?.fillColor = UIColor.darkGray
                        self.addChild(arrow2!)
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
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + Double(levelTime) * 2) {
            self.increaseTempo()
        }
        
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
        let score = GKScore(leaderboardIdentifier: "single_run_matter")
        score.value = Int64(matter)
        GKScore.report([score], withCompletionHandler: { (error:Error!) -> Void in
            print("sent single score" + String(matter))
            print(error ?? "no error")
        })
    }
    
    func reportLifetimeScore(matter:Int) {
        let score = GKScore(leaderboardIdentifier: "lifetime_matter")
        score.value = Int64(matter)
        GKScore.report([score], withCompletionHandler: { (error:Error!) -> Void in
            print("sent lifetime score:" + String(matter))
            print(error ?? "no error")
        })
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


var last = 0

class MatterPool {
    var freeMatter = Set<Matter>()
    
    init() {
    }
    
    func getMatter(position: CGPoint, scene:SKNode, color:UIColor, radius:Int, vector:CGVector) -> Matter {
        var matter:Matter?
        if freeMatter.count > 0 {
            matter = freeMatter.first
            print("reusing matter" + String(describing: matter?.uniqueID))
            matter?.setChars(position: position, scene: scene, color: color)
            matter!.square.physicsBody?.applyForce(vector)
            freeMatter.remove(matter!)
        } else {
            matter = Matter(position: position, scene: scene, color: color)
            matter!.square.physicsBody?.applyForce(vector)
        }
        return matter!
    }
    
    func returnMatter(usedMatter: Matter) {
        usedMatter.remove()
        freeMatter.insert(usedMatter)
    }
}

class Matter : Hashable {
    let square: SKShapeNode
    let radius = 5.0
    let uniqueID: Int
    
    init(position: CGPoint, scene: SKNode, color: UIColor) {
        self.square = SKShapeNode(rectOf: CGSize(width: radius, height: radius))
        self.square.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        self.square.physicsBody!.linearDamping = 0.75
        self.square.physicsBody!.angularDamping = 0.75
        self.square.position = position
        self.square.strokeColor = color
        self.square.fillColor = color
        scene.addChild(self.square)
        
        self.uniqueID = last
        last+=1
    }
    
    func setChars(position: CGPoint, scene: SKNode, color: UIColor) {
        self.square.physicsBody!.linearDamping = 0.75
        self.square.physicsBody!.angularDamping = 0.75
        self.square.position = position
        self.square.strokeColor = color
        self.square.fillColor = color
        scene.addChild(self.square)
    }
    
    func distanceFrom(location: CGPoint) -> CGFloat {
        let xDist = CGFloat(location.x - square.frame.midX);
        let yDist = CGFloat(location.y - square.frame.midY);
        let distance = CGFloat(sqrt((xDist * xDist) + (yDist * yDist)));
        return distance
    }
    
    func remove() {
        square.removeFromParent()
        square.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
    }
    
    func run(action: SKAction) {
        square.run(action)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.uniqueID)
    }
}


class Star : Hashable {
    let circle: SKShapeNode
    let star: SKEmitterNode
    var radius: CGFloat
    let field: SKFieldNode
    let uniqueID: Int
    var color: UIColor
    
    init(position: CGPoint, scene: SKNode, color: UIColor, mass: Int, setInsideColor: UIColor?) {
        self.color = color
        
        self.field = SKFieldNode.radialGravityField()
        self.field.strength = Float(mass)
        self.field.isEnabled = true
        self.field.position = position
        scene.addChild(field)
        
        
        self.radius = 120
        
        self.circle = SKShapeNode(circleOfRadius: self.radius)
        self.circle.position = position
        self.circle.strokeColor = color
        self.circle.lineWidth = 5
        self.circle.fillColor = SKColor.clear
        scene.addChild(self.circle)
        self.star = SKEmitterNode(fileNamed: "StarParticle")!
        if setInsideColor != nil {
            self.star.particleColorSequence = nil
            self.star.particleColor = setInsideColor ?? .black
        }
        self.star.position = position
        scene.addChild(self.star)
        let zoomIn = SKAction.scale(by: 2.0, duration: 0)
        self.star.run(zoomIn)
        self.uniqueID = last
        last += 1
    }
    
    func hasLocation(location: CGPoint) -> Bool {
        radius = circle.frame.width/2
        let xDist = CGFloat(location.x - circle.frame.midX);
        let yDist = CGFloat(location.y - circle.frame.midY);
        let distance = CGFloat(sqrt((xDist * xDist) + (yDist * yDist)));
        
        if distance < radius {
            return true
        }
        
        return false
    }
    
    func distanceFrom(location: CGPoint) -> CGFloat {
        radius = circle.frame.width/2
        let xDist = CGFloat(location.x - circle.frame.midX);
        let yDist = CGFloat(location.y - circle.frame.midY);
        let distance = CGFloat(sqrt((xDist * xDist) + (yDist * yDist)));
        return distance
    }
    
    func remove() {
        star.removeFromParent()
        circle.removeFromParent()
    }
    
    func updateRadius() {
        radius = circle.frame.width/2
    }
    
    func run(action: SKAction) {
        circle.run(action)
        star.run(action)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.uniqueID)
    }
}
