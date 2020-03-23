//
//  Star.swift
//  Star Evolver
//
//  Created by Drew Bratcher on 2/16/20.
//  Copyright © 2020 Drew Bratcher. All rights reserved.
//

import SpriteKit

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
