//
//  AppDelegate.swift
//  Example
//
//  Created by Aleksey Zgurskiy on 15.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import UIKit
import DataRaft

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.rootViewController?.view.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        return true
    }
}
