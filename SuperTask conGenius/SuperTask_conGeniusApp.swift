//
//  SuperTask_conGeniusApp.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import SwiftUI

@main
struct SuperTask_conGeniusApp: App {
    init() {
        // Configure app appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchCheckView()
                .preferredColorScheme(getColorScheme())
        }
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.appTextPrimary),
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.appTextPrimary),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.appCardBackground)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // Configure table view appearance
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableView.appearance().separatorStyle = .none
    }
    
    private func getColorScheme() -> ColorScheme? {
        if let data = UserDefaults.standard.data(forKey: "user_profile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            switch profile.preferences.theme {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return nil
            }
        }
        return nil
    }
}
