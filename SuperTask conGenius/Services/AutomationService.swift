//
//  AutomationService.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation
import Combine
import UserNotifications

class AutomationService: ObservableObject {
    static let shared = AutomationService()
    
    @Published var automationRules: [AutomationRule] = []
    
    private let rulesKey = "automation_rules"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadRules()
        setupAutomationObservers()
    }
    
    // MARK: - Rule Operations
    
    func addRule(_ rule: AutomationRule) {
        automationRules.append(rule)
        saveRules()
    }
    
    func updateRule(_ rule: AutomationRule) {
        if let index = automationRules.firstIndex(where: { $0.id == rule.id }) {
            automationRules[index] = rule
            saveRules()
        }
    }
    
    func deleteRule(_ rule: AutomationRule) {
        automationRules.removeAll { $0.id == rule.id }
        saveRules()
    }
    
    func toggleRuleActive(_ rule: AutomationRule) {
        if let index = automationRules.firstIndex(where: { $0.id == rule.id }) {
            automationRules[index].isActive.toggle()
            saveRules()
        }
    }
    
    // MARK: - Automation Logic
    
    private func setupAutomationObservers() {
        // Observe task changes
        TaskService.shared.$tasks
            .sink { [weak self] tasks in
                self?.checkAutomationRules(for: tasks)
            }
            .store(in: &cancellables)
        
        // Setup time-based checks
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkTimeBasedRules()
            }
            .store(in: &cancellables)
    }
    
    private func checkAutomationRules(for tasks: [Task]) {
        let activeRules = automationRules.filter { $0.isActive }
        
        for rule in activeRules {
            switch rule.triggerType {
            case .taskCompletion:
                checkTaskCompletionRules(rule, tasks: tasks)
            case .categoryBased:
                checkCategoryBasedRules(rule, tasks: tasks)
            default:
                break
            }
        }
    }
    
    private func checkTimeBasedRules() {
        let activeRules = automationRules.filter { $0.isActive }
        let calendar = Calendar.current
        let now = Date()
        
        for rule in activeRules {
            switch rule.triggerType {
            case .timeOfDay:
                if let timeString = rule.conditions["time"],
                   let targetTime = parseTime(timeString) {
                    let currentHour = calendar.component(.hour, from: now)
                    let currentMinute = calendar.component(.minute, from: now)
                    
                    if currentHour == targetTime.hour && currentMinute == targetTime.minute {
                        executeRule(rule)
                    }
                }
            case .dayOfWeek:
                if let dayString = rule.conditions["day"],
                   let targetDay = Int(dayString) {
                    let currentDay = calendar.component(.weekday, from: now)
                    if currentDay == targetDay {
                        executeRule(rule)
                    }
                }
            default:
                break
            }
        }
    }
    
    private func checkTaskCompletionRules(_ rule: AutomationRule, tasks: [Task]) {
        let recentlyCompleted = tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return Date().timeIntervalSince(completedAt) < 60 // Completed in last minute
        }
        
        if !recentlyCompleted.isEmpty {
            executeRule(rule)
        }
    }
    
    private func checkCategoryBasedRules(_ rule: AutomationRule, tasks: [Task]) {
        if let categoryString = rule.conditions["category"],
           let category = Task.TaskCategory(rawValue: categoryString) {
            let categoryTasks = tasks.filter { $0.category == category && !$0.isCompleted }
            
            if categoryTasks.count > 0 {
                executeRule(rule)
            }
        }
    }
    
    private func executeRule(_ rule: AutomationRule) {
        switch rule.actionType {
        case .createTask:
            createAutomatedTask(from: rule)
        case .sendNotification:
            sendNotification(from: rule)
        case .markComplete:
            markTasksComplete(from: rule)
        case .changeCategory:
            changeTaskCategory(from: rule)
        }
    }
    
    private func createAutomatedTask(from rule: AutomationRule) {
        let taskTitle = rule.conditions["taskTitle"] ?? "Automated Task"
        let taskDescription = rule.conditions["taskDescription"] ?? "Created by automation rule: \(rule.name)"
        
        let task = Task(
            title: taskTitle,
            description: taskDescription,
            priority: .medium,
            category: .personal,
            automationRuleId: rule.id
        )
        
        TaskService.shared.addTask(task)
    }
    
    private func sendNotification(from rule: AutomationRule) {
        let content = UNMutableNotificationContent()
        content.title = rule.conditions["notificationTitle"] ?? "Task conGenius"
        content.body = rule.conditions["notificationBody"] ?? "Automation rule triggered: \(rule.name)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: rule.id.uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func markTasksComplete(from rule: AutomationRule) {
        if let categoryString = rule.conditions["targetCategory"],
           let category = Task.TaskCategory(rawValue: categoryString) {
            let tasks = TaskService.shared.tasks.filter { 
                $0.category == category && !$0.isCompleted 
            }
            
            for task in tasks {
                TaskService.shared.toggleTaskCompletion(task)
            }
        }
    }
    
    private func changeTaskCategory(from rule: AutomationRule) {
        if let fromCategoryString = rule.conditions["fromCategory"],
           let toCategoryString = rule.conditions["toCategory"],
           let fromCategory = Task.TaskCategory(rawValue: fromCategoryString),
           let toCategory = Task.TaskCategory(rawValue: toCategoryString) {
            
            var tasks = TaskService.shared.tasks.filter { $0.category == fromCategory }
            
            for i in 0..<tasks.count {
                tasks[i].category = toCategory
                TaskService.shared.updateTask(tasks[i])
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseTime(_ timeString: String) -> (hour: Int, minute: Int)? {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        return (hour, minute)
    }
    
    // MARK: - Persistence
    
    private func saveRules() {
        if let encoded = try? JSONEncoder().encode(automationRules) {
            UserDefaults.standard.set(encoded, forKey: rulesKey)
        }
    }
    
    private func loadRules() {
        if let data = UserDefaults.standard.data(forKey: rulesKey),
           let decoded = try? JSONDecoder().decode([AutomationRule].self, from: data) {
            automationRules = decoded
        } else {
            createDefaultRules()
        }
    }
    
    private func createDefaultRules() {
        automationRules = [
            AutomationRule(
                name: "Morning Tasks Creator",
                triggerType: .timeOfDay,
                actionType: .sendNotification,
                conditions: [
                    "time": "09:00",
                    "notificationTitle": "Good Morning!",
                    "notificationBody": "Time to review your tasks for today"
                ]
            ),
            AutomationRule(
                name: "Task Completion Congratulations",
                triggerType: .taskCompletion,
                actionType: .sendNotification,
                conditions: [
                    "notificationTitle": "Great Job!",
                    "notificationBody": "You've completed a task. Keep up the good work!"
                ]
            )
        ]
        saveRules()
    }
    
    // MARK: - Notification Permission
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

