//
//  AppDelegate.swift
//  AnimalMatch
//
//  Created by Jordan Doczy on 11/23/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let font = UIFont(name: "ChalkboardSE-Light", size: 16) {
            UISegmentedControl.appearance().setTitleTextAttributes([.font: font], for: .normal)
        }
        return true
    }
}
