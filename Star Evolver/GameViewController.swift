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

    private var presentedInitialScene = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Wait for layout so the scene gets the real screen size, not the storyboard's.
        guard !presentedInitialScene else { return }
        presentedInitialScene = true

        let scene = GameScene(size: view.bounds.size)

        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = false
        
        /* Match the scale mode used when restarting from the game over screen */
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
    }
}
