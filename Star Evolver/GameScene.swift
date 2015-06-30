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
    
    override func didMoveToView(view: SKView) {
        
        
        authenticateLocalPlayer()
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        self.removeAllChildren()
        self.removeAllActions()
        tempo = 0
        level = 1
        score = 0
        levelTime = 10
        stars = Set<Star>()
        self.backgroundColor = SKColor(red:127.0/256.0, green:120.0/256.0, blue:106.0/256.0, alpha:1.0)
        let center = CGPointMake(frame.midX, frame.midY)
        let zero = CGPointMake(0, 0)
        self.rootNode.position = center
        lifetime_score = NSUserDefaults.standardUserDefaults().integerForKey("lifetime_score")
        var starColor = SKColor.whiteColor()
        var insideColor = SKColor.lightGrayColor()
        if lifetime_score > 1000000 {
            starColor = SKColor.purpleColor()
            insideColor = SKColor.darkGrayColor()
        } else if lifetime_score > 100000 {
            starColor = SKColor.blueColor()
            insideColor = SKColor.cyanColor()
        } else if lifetime_score > 10000 {
            starColor = SKColor.redColor()
            insideColor = SKColor.orangeColor()
        } else if lifetime_score > 1000 {
            starColor = SKColor.yellowColor()
            insideColor = SKColor.darkGrayColor()
        }
        myStar = Star(position: zero, scene: self.rootNode, color:starColor, mass:2, setInsideColor: insideColor)
        lifetime_score = NSUserDefaults.standardUserDefaults().integerForKey("lifetime_score")
        let zoomOut = SKAction.scaleTo(0.2, duration: 0)
        myStar.runAction(zoomOut)
        
        
        matterCollected = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        matterCollected!.text = "Matter: " + String(score)
        matterCollected!.position = CGPoint(x: self.frame.midX, y: 520)
        matterCollected?.fontSize = 15
        self.addChild(matterCollected!)
        
        var ranTutorial = NSUserDefaults.standardUserDefaults().integerForKey("tutorial")
        if ranTutorial == 0 {
            tapToStart = true
            tutorial()
        } else {
            increaseTempo()
        }
        
        // handle zooming
        
        let zoomHandler = UIPinchGestureRecognizer(target: self, action: "handleZoom:")
        self.view?.addGestureRecognizer(zoomHandler)
        
        self.addChild(self.rootNode)
    }
    
    func handleZoom(sender:UIPinchGestureRecognizer) {
        println(sender.scale)
        if sender.scale < 1 {
            rootNode.xScale -= 0.01
            rootNode.yScale -= 0.01
        }
        if sender.scale > 1 {
            rootNode.xScale += 0.01
            rootNode.yScale += 0.01
        }
        
        println(rootNode.xScale)
        println(rootNode.yScale)
    }

    func authenticateLocalPlayer() {
        println("authing user")
        var localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler =  {(viewController:UIViewController!, error:NSError!) -> Void in
            if(error != nil) {
                println(error)
            }
            if ((viewController) != nil) {
                println("view controller launched")
                self.view!.window!.rootViewController!.presentViewController(viewController, animated: true, completion: {
                    self.loadAchievements()
                })
            } else {
                self.showBanner("Welcome Back " + GKLocalPlayer.localPlayer().alias, message: nil)
                self.loadAchievements()
            }
        }
        
    }
    
    func loadAchievements() {
        GKAchievement.loadAchievementsWithCompletionHandler { (loaded, error) -> Void in
            if error != nil {
                println(error)
                return
            }
            for one in loaded {
                if let oneAchievement = one as? GKAchievement {
                    self.achievements[oneAchievement.identifier] = oneAchievement
                }
            }
        }
    }
    
    func updatePercentComplete(award:GKAchievement, score:Int, divisor:Int, lastScore:Int, displayName:String) {
        award.percentComplete = Double(score * 100 / divisor)
        if lastScore != 0 {
            let lastPercentComplete = Double(lastScore * 100 / divisor)
            var not_filled = achievements[award.identifier] != nil && achievements[award.identifier]?.completed == nil
            if award.percentComplete >= 100.0 && lastPercentComplete < 100.0 && not_filled {
                println("need to show something")
                showBanner("Awarded " + displayName , message: nil)
            }
        }
    }
    
    func showBanner(title:String, message: String?) {
        GKNotificationBanner.showBannerWithTitle(title, message: message, completionHandler: nil)
    }
    
    
    func updateAchievements() {
        let tempLifetime = NSUserDefaults.standardUserDefaults().integerForKey("lifetime_score") + score
        let matter1 = GKAchievement(identifier: "matter_collected_1")
        updatePercentComplete(matter1, score: score, divisor: 5, lastScore: previousScore, displayName: "Matter Collected")
        let star_destroyer = GKAchievement(identifier: "star_destroyer")
        updatePercentComplete(star_destroyer, score: score, divisor: 100, lastScore: previousScore, displayName: "Star Destroyer")
        let sun_crusher = GKAchievement(identifier: "sun_crusher")
        updatePercentComplete(sun_crusher, score: score, divisor: 500, lastScore: previousScore, displayName: "Sun Crusher")
        let world_devourer = GKAchievement(identifier: "world_devourer")
        updatePercentComplete(world_devourer, score: score, divisor: 1000, lastScore: previousScore, displayName: "World Devourer")
        let white_dwarf = GKAchievement(identifier: "star_size_1")
        updatePercentComplete(white_dwarf, score: tempLifetime, divisor: 10, lastScore: previousLifetime, displayName: "White Dwarf")
        let yellow_star = GKAchievement(identifier: "yellow_star")
        updatePercentComplete(yellow_star, score: tempLifetime, divisor: 1000, lastScore: previousLifetime, displayName: "Yellow Star")
        let red_giant = GKAchievement(identifier: "red_giant")
        updatePercentComplete(red_giant, score: tempLifetime, divisor: 10000, lastScore: previousLifetime, displayName: "Red Giant")
        let blue_giant = GKAchievement(identifier: "blue_giant")
        updatePercentComplete(blue_giant, score: tempLifetime, divisor: 100000, lastScore: previousLifetime, displayName: "Blue Giant")
        let pulsar = GKAchievement(identifier: "pulsar")
        pulsar.percentComplete = 0.0
        if tempLifetime > 1000000 {
            pulsar.percentComplete = 100.0
        }
        let achieved = [matter1, star_destroyer, sun_crusher, world_devourer, white_dwarf, yellow_star, red_giant, blue_giant, pulsar]
        GKAchievement.reportAchievements(achieved, withCompletionHandler: nil)
        previousLifetime = tempLifetime
        previousScore = score
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        println("game center view finished")
    }
    
    
    func tutorial() {
        
        // move node in for 1 sec
        var randomPoint = CGPointMake(frame.midX, 0)
        var randomRed = CGFloat(drand48() + 0.5)
        var randomGreen = CGFloat(drand48() + 0.5)
        var randomBlue = CGFloat(drand48() + 0.5)
        var randomColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        var newStar = Star(position: randomPoint, scene: self.rootNode, color:randomColor, mass:0, setInsideColor: nil)
        stars.insert(newStar)
        let zoomOut = SKAction.scaleTo(0.2, duration: 0)
        newStar.runAction(zoomOut)
        let moveToCenter = SKAction.moveTo(CGPointMake(frame.midX, 100), duration: NSTimeInterval(1))
        newStar.runAction(moveToCenter)
        
        // show tap to destroy label
        tapToStartLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        tapToStartLabel!.text = "Tap To Destroy"
        tapToStartLabel!.position = CGPoint(x: self.frame.midX, y: 200)
        self.addChild(tapToStartLabel!)
        // show arrow
        
        arrow_path1 = UIBezierPath()
        arrow_path1?.moveToPoint(CGPointMake(self.frame.midX-50, 180))
        arrow_path1?.addLineToPoint(CGPointMake(self.frame.midX, 150))
        arrow_path1?.addLineToPoint(CGPointMake(self.frame.midX+50, 180))
        arrow_path1?.closePath()
        arrow1 = SKShapeNode(path: arrow_path1?.CGPath)
        arrow1?.fillColor = UIColor.darkGrayColor()
        self.addChild(arrow1!)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        if tapToStart && firstStarDestroyed {
            arrow2?.removeFromParent()
            instructionLabel?.removeFromParent()
            instructionLabel2?.removeFromParent()
            tapToStart = false
            increaseTempo()
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "tutorial")
        }
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self.rootNode)
            println("checking user touch at x: " + String(stringInterpolationSegment: location.x) + " y: " + String(stringInterpolationSegment: location.y))
            for star in stars {
                if star.hasLocation(location) {
                    println("user got star:" + String(star.hashValue));
                    
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
                        arrow_path2?.moveToPoint(CGPointMake(self.frame.midX-50, 380))
                        arrow_path2?.addLineToPoint(CGPointMake(self.frame.midX, 350))
                        arrow_path2?.addLineToPoint(CGPointMake(self.frame.midX+50, 380))
                        arrow_path2?.closePath()
                        arrow2 = SKShapeNode(path: arrow_path2?.CGPath)
                        arrow2?.fillColor = UIColor.darkGrayColor()
                        self.addChild(arrow2!)
                    }
                    
                    
                    var newMatter1 = matterPool.getMatter(location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: 0, dy: 50))
                    matter.insert(newMatter1)
                    var newMatter2 = matterPool.getMatter(location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: 50, dy: 0))
                    matter.insert(newMatter2)
                    var newMatter3 = matterPool.getMatter(location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: -50, dy: 0))
                    matter.insert(newMatter3)
                    var newMatter4 = matterPool.getMatter(location, scene: self.rootNode, color: star.color, radius: 5, vector:CGVector(dx: 0, dy: -50))
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
                    println("matter created")
                    star.remove()
                    stars.remove(star)
                }
            }
            
        }
    }
    
    
    func increaseTempo(){
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(levelTime) * Double(NSEC_PER_SEC) * 2))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.increaseTempo()
        }
        
        println("increasing tempo")
        tempo += 1
        if tempo > level {
            increaseLevel()
        }
    }
    
    func increaseLevel(){
        println("increasing level")
        tempo = 1
        level += 1
        levelTime *= 2
    }
    
    func reportSingleScore(matter:Int) {
        let score = GKScore(leaderboardIdentifier: "single_run_matter")
        score.value = Int64(matter)
        GKScore.reportScores([score], withCompletionHandler: { (error:NSError!) -> Void in
            println("sent single score" + String(matter))
            println(error)
        })
    }
    
    func reportLifetimeScore(matter:Int) {
        let score = GKScore(leaderboardIdentifier: "lifetime_matter")
        score.value = Int64(matter)
        GKScore.reportScores([score], withCompletionHandler: { (error:NSError!) -> Void in
            println("sent lifetime score:" + String(matter))
            println(error)
        })
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        
        let center = CGPointMake(0, 0)
        if stars.count < level && !tapToStart {
            println("need to generate new star")
            var randomX = CGFloat(Int(arc4random()) % Int(frame.width)) - frame.midX
            var randomY = CGFloat(Int(arc4random()) % 2 * Int(frame.height+200)) - 100 - frame.midY // Top or Bottom
            var randomSpeed = Float(arc4random()) % 10 / 5 + 2
            var randomPoint = CGPointMake(randomX, randomY)
            var randomRed = CGFloat(drand48() + 0.5)
            var randomGreen = CGFloat(drand48() + 0.5)
            var randomBlue = CGFloat(drand48() + 0.5)
            var randomColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
            var newStar = Star(position: randomPoint, scene: self.rootNode, color:randomColor, mass:0, setInsideColor: nil )
            stars.insert(newStar)
            let zoomOut = SKAction.scaleTo(0.2, duration: 0)
            newStar.runAction(zoomOut)
            let moveToCenter = SKAction.moveTo(center, duration: NSTimeInterval(randomSpeed))
            newStar.runAction(moveToCenter)
            println("new star generated, stars size: " + String(stars.count))
        }
        
        myStar.updateRadius()
        for star in stars {
            if star.distanceFrom(center) < star.radius + myStar.radius {
                println("hit center with star: " + String(star.hashValue))
                star.remove()
                stars.remove(star)
                self.runEnded()
            }
        }
        
        for piece in matter {
            if Int(piece.distanceFrom(center)) < Int(piece.radius) + Int(myStar.radius) {
                println("collected some matter")
                updateAchievements()
                matter.remove(piece)
                matterPool.returnMatter(piece)
                score+=1
                if score % 100 == 0 {
                    let grow = SKAction.scaleBy(1.10, duration: 2)
                    myStar.runAction(grow)
                }
                matterCollected!.text = "Matter: " + String(score)
            }
        }
    }

    func runEnded() {
        if let mainView = view {
            let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
            
            lifetime_score = NSUserDefaults.standardUserDefaults().integerForKey("lifetime_score") + score
            NSUserDefaults.standardUserDefaults().setInteger(lifetime_score, forKey: "lifetime_score")
            
            if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
                NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
            }
            
            gameOverScene.lifetime = lifetime_score
            gameOverScene.gameScore = score
            gameOverScene.highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
            mainView.presentScene(gameOverScene)
            
            
            self.reportLifetimeScore(lifetime_score)
            self.reportSingleScore(score)
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
    
    func getMatter(position:CGPoint, scene:SKNode, color:UIColor, radius:Int, vector:CGVector) -> Matter {
        var matter:Matter?
        if freeMatter.count > 0 {
            matter = freeMatter.first
            println("reusing matter" + String(stringInterpolationSegment: matter?.uniqueID))
            matter?.setChars(position, scene: scene, color: color)
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
        self.square = SKShapeNode(rectOfSize: CGSize(width: radius, height: radius))
        self.square.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        self.square.physicsBody!.linearDamping = 0.75
        self.square.physicsBody!.angularDamping = 0.75
        self.square.position = position
        self.square.strokeColor = color
        self.square.fillColor = color
        scene.addChild(self.square)
        
        self.uniqueID = last++
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
    
    func runAction(action: SKAction) {
        square.runAction(action)
    }
    
    var hashValue:Int {
        get {
            return uniqueID
        }
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
        self.field.enabled = true
        self.field.position = position
        scene.addChild(field)
        
        
        self.radius = 120
        
        self.circle = SKShapeNode(circleOfRadius: self.radius)
        self.circle.position = position
        self.circle.strokeColor = color
        self.circle.lineWidth = 5
        self.circle.fillColor = SKColor.clearColor()
        scene.addChild(self.circle)
        self.star = SKEmitterNode(fileNamed: "StarParticle")
        if setInsideColor != nil {
            self.star.particleColorSequence = nil
            self.star.particleColor = setInsideColor
        }
        self.star.position = position
        scene.addChild(self.star)
        let zoomIn = SKAction.scaleTo(2.0, duration: 0)
        self.star.runAction(zoomIn)
        self.uniqueID = last++
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
    
    func runAction(action: SKAction) {
        circle.runAction(action)
        star.runAction(action)
    }
    
    var hashValue : Int {
        get {
            return uniqueID
        }
    }
}