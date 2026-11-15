//
//  GameViewController.swift
//  Star Evolver
//
//  Created by Drew Bratcher on 4/25/15.
//  Copyright (c) 2015 Drew Bratcher. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        return SKScene(fileNamed: file)
    }
}

class GameViewController: UIViewController {

    private var presentedInitialScene = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticateGameCenter()
    }

    /// Sign in to Game Center once per launch. GameKit shows its own
    /// "Welcome back" banner, or hands us a sign-in screen to present.
    private func authenticateGameCenter() {
        guard GKLocalPlayer.local.authenticateHandler == nil else { return }
        GKLocalPlayer.local.authenticateHandler = { [weak self] signInController, error in
            if let signInController = signInController {
                self?.present(signInController, animated: true)
            } else if let error = error {
                print("Game Center sign-in failed: \(error.localizedDescription)")
            }
        }
    }

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
