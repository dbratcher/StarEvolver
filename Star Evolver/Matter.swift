//
//  Matter.swift
//  Star Evolver
//
//  Created by Drew Bratcher on 2/16/20.
//  Copyright © 2020 Drew Bratcher. All rights reserved.
//

import SpriteKit
import UIKit

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
