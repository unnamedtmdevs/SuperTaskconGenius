//
//  TaskViewModel.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation
import Combine
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Task.TaskCategory?
    @Published var showCompletedTasks: Bool = true
    @Published var sortOrder: UserProfile.UserPreferences.SortOrder = .dueDate
    
    private var cancellables = Set<AnyCancellable>()
    private let taskService = TaskService.shared
    
    init() {
        // Subscribe to TaskService updates
        taskService.$tasks
            .assign(to: &$tasks)
        
        // Load user preferences
        loadPreferences()
    }
    
    var filteredAndSortedTasks: [Task] {
        var result = tasks
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by completion status
        if !showCompletedTasks {
            result = result.filter { !$0.isCompleted }
        }
        
        // Sort
        result = taskService.sortedTasks(result, by: sortOrder)
        
        return result
    }
    
    var activeTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    var overdueTasks: [Task] {
        tasks.filter { $0.isOverdue }
    }
    
    var todayTasks: [Task] {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDateInToday(dueDate)
        }
    }
    
    var upcomingTasks: [Task] {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate > Date() && !Calendar.current.isDateInToday(dueDate)
        }
    }
    
    func tasksByCategory(_ category: Task.TaskCategory) -> [Task] {
        tasks.filter { $0.category == category && !$0.isCompleted }
    }
    
    func addTask(title: String, description: String, priority: Task.TaskPriority, category: Task.TaskCategory, dueDate: Date?, tags: [String] = []) {
        let task = Task(
            title: title,
            description: description,
            priority: priority,
            category: category,
            dueDate: dueDate,
            tags: tags
        )
        taskService.addTask(task)
    }
    
    func updateTask(_ task: Task) {
        taskService.updateTask(task)
    }
    
    func deleteTask(_ task: Task) {
        taskService.deleteTask(task)
    }
    
    func toggleCompletion(_ task: Task) {
        taskService.toggleTaskCompletion(task)
    }
    
    func deleteCompletedTasks() {
        taskService.deleteCompletedTasks()
    }
    
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "user_profile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            showCompletedTasks = profile.preferences.showCompletedTasks
            sortOrder = profile.preferences.sortOrder
        }
    }
    
    func savePreferences() {
        if var profile = loadUserProfile() {
            profile.preferences.showCompletedTasks = showCompletedTasks
            profile.preferences.sortOrder = sortOrder
            saveUserProfile(profile)
        }
    }
    
    private func loadUserProfile() -> UserProfile? {
        if let data = UserDefaults.standard.data(forKey: "user_profile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return nil
    }
    
    private func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "user_profile")
        }
    }
}

