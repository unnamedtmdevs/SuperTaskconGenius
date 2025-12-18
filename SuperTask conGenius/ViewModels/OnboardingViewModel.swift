//
//  OnboardingViewModel.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var username: String = ""
    @Published var selectedDefaultCategory: Task.TaskCategory = .personal
    @Published var selectedDefaultPriority: Task.TaskPriority = .medium
    @Published var notificationsEnabled: Bool = true
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Task conGenius",
            description: "Your intelligent task management companion that helps you stay organized and productive",
            imageName: "checkmark.circle.fill",
            color: Color.appPrimary
        ),
        OnboardingPage(
            title: "Smart Task Management",
            description: "Create, organize, and prioritize your tasks with intuitive categories and priorities",
            imageName: "list.bullet.circle.fill",
            color: Color.blue
        ),
        OnboardingPage(
            title: "Powerful Automation",
            description: "Set up automation rules to streamline your workflow and save time",
            imageName: "gearshape.2.fill",
            color: Color.orange
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Get insights into your productivity with detailed statistics and completion trends",
            imageName: "chart.bar.fill",
            color: Color.green
        ),
        OnboardingPage(
            title: "Let's Get Started",
            description: "Customize your experience to match your workflow",
            imageName: "person.circle.fill",
            color: Color.purple
        )
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    var canProceed: Bool {
        if isLastPage {
            return !username.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return true
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    func completeOnboarding() {
        // Create user profile
        var profile = UserProfile()
        profile.username = username
        profile.preferences.defaultTaskCategory = selectedDefaultCategory
        profile.preferences.defaultTaskPriority = selectedDefaultPriority
        profile.preferences.notificationsEnabled = notificationsEnabled
        
        // Save profile
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "user_profile")
        }
        
        // Request notification permission if enabled
        if notificationsEnabled {
            AutomationService.shared.requestNotificationPermission()
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

