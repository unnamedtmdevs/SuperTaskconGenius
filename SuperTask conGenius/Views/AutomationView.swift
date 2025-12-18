//
//  AutomationView.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import SwiftUI

struct AutomationView: View {
    @StateObject private var viewModel = AutomationViewModel()
    @State private var showingAddRule = false
    @State private var showingAddTemplate = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segment Control
                    Picker("", selection: $selectedTab) {
                        Text("Rules").tag(0)
                        Text("Templates").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content
                    if selectedTab == 0 {
                        AutomationRulesView(viewModel: viewModel, showingAddRule: $showingAddRule)
                    } else {
                        TemplatesView(viewModel: viewModel, showingAddTemplate: $showingAddTemplate)
                    }
                }
            }
            .navigationTitle("Automation")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == 0 {
                            showingAddRule = true
                        } else {
                            showingAddTemplate = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appPrimary)
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showingAddRule) {
                AddAutomationRuleView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddTemplateView(viewModel: viewModel)
            }
        }
    }
}

struct AutomationRulesView: View {
    @ObservedObject var viewModel: AutomationViewModel
    @Binding var showingAddRule: Bool
    
    var body: some View {
        if viewModel.automationRules.isEmpty {
            EmptyStateView(
                icon: "gearshape.2",
                title: "No Automation Rules",
                message: "Create rules to automate your tasks and get notifications"
            )
        } else {
            List {
                if !viewModel.activeRules.isEmpty {
                    Section(header: Text("Active Rules")) {
                        ForEach(viewModel.activeRules) { rule in
                            AutomationRuleRow(rule: rule, viewModel: viewModel)
                        }
                    }
                }
                
                if !viewModel.inactiveRules.isEmpty {
                    Section(header: Text("Inactive Rules")) {
                        ForEach(viewModel.inactiveRules) { rule in
                            AutomationRuleRow(rule: rule, viewModel: viewModel)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
    }
}

struct AutomationRuleRow: View {
    let rule: AutomationRule
    @ObservedObject var viewModel: AutomationViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: rule.actionType.icon)
                .foregroundColor(rule.isActive ? .appPrimary : .gray)
                .font(.system(size: 24))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                
                HStack(spacing: 4) {
                    Text(rule.triggerType.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                    
                    Text("→")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                    
                    Text(rule.actionType.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { rule.isActive },
                set: { _ in viewModel.toggleRuleActive(rule) }
            ))
            .labelsHidden()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deleteRule(rule)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct TemplatesView: View {
    @ObservedObject var viewModel: AutomationViewModel
    @Binding var showingAddTemplate: Bool
    
    var body: some View {
        if viewModel.templates.isEmpty {
            EmptyStateView(
                icon: "doc.text.fill.badge.plus",
                title: "No Templates",
                message: "Create templates for tasks you frequently create"
            )
        } else {
            List {
                ForEach(viewModel.templates) { template in
                    TemplateRow(template: template, viewModel: viewModel)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
    }
}

struct TemplateRow: View {
    let template: TaskTemplate
    @ObservedObject var viewModel: AutomationViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: template.defaultCategory.icon)
                .foregroundColor(template.defaultPriority.color)
                .font(.system(size: 24))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                
                HStack(spacing: 6) {
                    Text(template.defaultCategory.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                    
                    Text("•")
                        .foregroundColor(.appTextSecondary)
                    
                    Text(template.defaultPriority.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(template.defaultPriority.color)
                    
                    if template.isRecurring {
                        Text("•")
                            .foregroundColor(.appTextSecondary)
                        
                        Text(template.recurringInterval?.rawValue ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.createTaskFromTemplate(template)
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.appPrimary)
                    .font(.system(size: 24))
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deleteTemplate(template)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddAutomationRuleView: View {
    @ObservedObject var viewModel: AutomationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var ruleName = ""
    @State private var triggerType: AutomationRule.TriggerType = .timeOfDay
    @State private var actionType: AutomationRule.ActionType = .sendNotification
    @State private var selectedTime = Date()
    @State private var selectedDay = 1
    @State private var notificationTitle = ""
    @State private var notificationBody = ""
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedCategory: Task.TaskCategory = .personal
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Rule Information")) {
                        TextField("Rule Name", text: $ruleName)
                    }
                    
                    Section(header: Text("Trigger")) {
                        Picker("When", selection: $triggerType) {
                            ForEach(AutomationRule.TriggerType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        
                        if triggerType == .timeOfDay {
                            DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        } else if triggerType == .dayOfWeek {
                            Picker("Day", selection: $selectedDay) {
                                Text("Sunday").tag(1)
                                Text("Monday").tag(2)
                                Text("Tuesday").tag(3)
                                Text("Wednesday").tag(4)
                                Text("Thursday").tag(5)
                                Text("Friday").tag(6)
                                Text("Saturday").tag(7)
                            }
                        }
                    }
                    
                    Section(header: Text("Action")) {
                        Picker("Then", selection: $actionType) {
                            ForEach(AutomationRule.ActionType.allCases, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                }
                                .tag(type)
                            }
                        }
                        
                        if actionType == .sendNotification {
                            TextField("Notification Title", text: $notificationTitle)
                            TextField("Notification Message", text: $notificationBody, axis: .vertical)
                                .lineLimit(2...4)
                        } else if actionType == .createTask {
                            TextField("Task Title", text: $taskTitle)
                            TextField("Task Description", text: $taskDescription, axis: .vertical)
                                .lineLimit(2...4)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                    Label(category.rawValue, systemImage: category.icon).tag(category)
                                }
                            }
                        } else if actionType == .changeCategory {
                            Picker("Target Category", selection: $selectedCategory) {
                                ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                    Label(category.rawValue, systemImage: category.icon).tag(category)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Automation Rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRule()
                    }
                    .disabled(ruleName.isEmpty)
                    .bold()
                }
            }
        }
    }
    
    private func saveRule() {
        var conditions: [String: String] = [:]
        
        switch triggerType {
        case .timeOfDay:
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            conditions["time"] = formatter.string(from: selectedTime)
        case .dayOfWeek:
            conditions["day"] = String(selectedDay)
        default:
            break
        }
        
        switch actionType {
        case .sendNotification:
            conditions["notificationTitle"] = notificationTitle
            conditions["notificationBody"] = notificationBody
        case .createTask:
            conditions["taskTitle"] = taskTitle
            conditions["taskDescription"] = taskDescription
            conditions["category"] = selectedCategory.rawValue
        case .changeCategory:
            conditions["toCategory"] = selectedCategory.rawValue
        default:
            break
        }
        
        viewModel.addRule(
            name: ruleName,
            triggerType: triggerType,
            actionType: actionType,
            conditions: conditions
        )
        
        dismiss()
    }
}

struct AddTemplateView: View {
    @ObservedObject var viewModel: AutomationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateName = ""
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var priority: Task.TaskPriority = .medium
    @State private var category: Task.TaskCategory = .personal
    @State private var tags = ""
    @State private var isRecurring = false
    @State private var recurringInterval: TaskTemplate.RecurringInterval = .daily
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Template Information")) {
                        TextField("Template Name", text: $templateName)
                        TextField("Task Title", text: $taskTitle)
                        TextField("Task Description", text: $taskDescription, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    
                    Section(header: Text("Default Values")) {
                        Picker("Priority", selection: $priority) {
                            ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        
                        Picker("Category", selection: $category) {
                            ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon).tag(category)
                            }
                        }
                        
                        TextField("Tags (comma-separated)", text: $tags)
                    }
                    
                    Section(header: Text("Recurring")) {
                        Toggle("Is Recurring", isOn: $isRecurring)
                        
                        if isRecurring {
                            Picker("Interval", selection: $recurringInterval) {
                                ForEach(TaskTemplate.RecurringInterval.allCases, id: \.self) { interval in
                                    Text(interval.rawValue).tag(interval)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(templateName.isEmpty || taskTitle.isEmpty)
                    .bold()
                }
            }
        }
    }
    
    private func saveTemplate() {
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        viewModel.addTemplate(
            name: templateName,
            title: taskTitle,
            description: taskDescription,
            priority: priority,
            category: category,
            tags: tagArray,
            isRecurring: isRecurring,
            interval: isRecurring ? recurringInterval : nil
        )
        
        dismiss()
    }
}

#Preview {
    AutomationView()
}

