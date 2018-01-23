//
//  AppDelegate.swift
//  Example
//
//  Created by Aleksey Zgurskiy on 15.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import UIKit
import DataRaft
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
    var db = DataRaft()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        try! db.configure(type: .sqLite, modelName: "Example")
        return true
    }
}
