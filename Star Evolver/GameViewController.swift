//
//  GameViewController.swift
//  Star Evolver
//
//  Created by Drew Bratcher on 4/25/15.
//  Copyright (c) 2015 Drew Bratcher. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        return SKScene(fileNamed: file)
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)

        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = false
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFit
        
        skView.presentScene(scene)
    }
}
