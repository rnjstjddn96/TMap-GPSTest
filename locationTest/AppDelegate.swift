//
//  AppDelegate.swift
//  locationTest
//
//  Created by imf-mini-3 on 2020/11/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let rootViewController = ViewController()
        let navi = UINavigationController(rootViewController: rootViewController)
//        navi.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
        return true

    }

    // MARK: UISceneSession Lifecycle



}

