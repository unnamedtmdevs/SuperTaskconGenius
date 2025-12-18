//
//  AutomationViewModel.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import Foundation
import Combine

class AutomationViewModel: ObservableObject {
    @Published var automationRules: [AutomationRule] = []
    @Published var templates: [TaskTemplate] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let automationService = AutomationService.shared
    private let taskService = TaskService.shared
    
    init() {
        // Subscribe to service updates
        automationService.$automationRules
            .assign(to: &$automationRules)
        
        taskService.$templates
            .assign(to: &$templates)
    }
    
    var activeRules: [AutomationRule] {
        automationRules.filter { $0.isActive }
    }
    
    var inactiveRules: [AutomationRule] {
        automationRules.filter { !$0.isActive }
    }
    
    // MARK: - Automation Rules
    
    func addRule(name: String, triggerType: AutomationRule.TriggerType, actionType: AutomationRule.ActionType, conditions: [String: String]) {
        let rule = AutomationRule(
            name: name,
            triggerType: triggerType,
            actionType: actionType,
            conditions: conditions
        )
        automationService.addRule(rule)
    }
    
    func deleteRule(_ rule: AutomationRule) {
        automationService.deleteRule(rule)
    }
    
    func toggleRuleActive(_ rule: AutomationRule) {
        automationService.toggleRuleActive(rule)
    }
    
    // MARK: - Templates
    
    func addTemplate(name: String, title: String, description: String, priority: Task.TaskPriority, category: Task.TaskCategory, tags: [String], isRecurring: Bool, interval: TaskTemplate.RecurringInterval?) {
        let template = TaskTemplate(
            name: name,
            templateTitle: title,
            templateDescription: description,
            defaultPriority: priority,
            defaultCategory: category,
            defaultTags: tags,
            isRecurring: isRecurring,
            recurringInterval: interval
        )
        taskService.addTemplate(template)
    }
    
    func deleteTemplate(_ template: TaskTemplate) {
        taskService.deleteTemplate(template)
    }
    
    func createTaskFromTemplate(_ template: TaskTemplate) {
        taskService.createTaskFromTemplate(template)
    }
    
    // MARK: - Quick Rule Helpers
    
    func createDailyReminderRule(time: String, title: String, message: String) {
        let conditions: [String: String] = [
            "time": time,
            "notificationTitle": title,
            "notificationBody": message
        ]
        
        addRule(
            name: "Daily Reminder: \(title)",
            triggerType: .timeOfDay,
            actionType: .sendNotification,
            conditions: conditions
        )
    }
    
    func createWeeklyTaskRule(day: Int, taskTitle: String, taskDescription: String, category: Task.TaskCategory) {
        let conditions: [String: String] = [
            "day": String(day),
            "taskTitle": taskTitle,
            "taskDescription": taskDescription,
            "category": category.rawValue
        ]
        
        addRule(
            name: "Weekly Task: \(taskTitle)",
            triggerType: .dayOfWeek,
            actionType: .createTask,
            conditions: conditions
        )
    }
    
    func createCompletionRewardRule(title: String, message: String) {
        let conditions: [String: String] = [
            "notificationTitle": title,
            "notificationBody": message
        ]
        
        addRule(
            name: "Completion Reward",
            triggerType: .taskCompletion,
            actionType: .sendNotification,
            conditions: conditions
        )
    }
}

