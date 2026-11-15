//
//  AppDelegate.swift
//  Star Evolver
//
//  Created by Drew Bratcher on 4/25/15.
//  Copyright (c) 2015 Drew Bratcher. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

/// Scene lifecycle is required on current iOS. The window and root view
/// controller come from Main.storyboard via the scene manifest in Info.plist.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
}
