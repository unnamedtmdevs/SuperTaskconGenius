//
//  TaskListView.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var showingFilters = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    // Statistics Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Active",
                                value: "\(viewModel.activeTasks.count)",
                                icon: "list.bullet",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Completed",
                                value: "\(viewModel.completedTasks.count)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Overdue",
                                value: "\(viewModel.overdueTasks.count)",
                                icon: "exclamationmark.triangle.fill",
                                color: .appPrimary
                            )
                            
                            StatCard(
                                title: "Today",
                                value: "\(viewModel.todayTasks.count)",
                                icon: "calendar",
                                color: .orange
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    
                    // Task List
                    if viewModel.filteredAndSortedTasks.isEmpty {
                        EmptyStateView(
                            icon: "checkmark.circle",
                            title: viewModel.searchText.isEmpty ? "No Tasks Yet" : "No Results",
                            message: viewModel.searchText.isEmpty ? "Tap + to create your first task" : "Try a different search term"
                        )
                    } else {
                        List {
                            ForEach(viewModel.filteredAndSortedTasks) { task in
                                TaskRow(task: task) {
                                    viewModel.toggleCompletion(task)
                                } onTap: {
                                    selectedTask = task
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let task = viewModel.filteredAndSortedTasks[index]
                                    viewModel.deleteTask(task)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.appPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appPrimary)
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task, viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilters) {
                FiltersView(viewModel: viewModel)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search tasks...", text: $text)
                .font(.system(size: 16, design: .rounded))
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(width: 100)
        .padding()
        .cardStyle()
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Completion Button
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .appSuccess : task.priority.color)
                        .font(.system(size: 24))
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                        .strikethrough(task.isCompleted)
                    
                    // Description
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(2)
                    }
                    
                    // Tags & Info
                    HStack(spacing: 8) {
                        // Category
                        Label(task.category.rawValue, systemImage: task.category.icon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        
                        // Due Date
                        if let dueDate = task.dueDate {
                            Text("•")
                                .foregroundColor(.appTextSecondary)
                            
                            Text(dueDate, style: .date)
                                .font(.system(size: 12))
                                .foregroundColor(task.isOverdue ? .appError : .appTextSecondary)
                        }
                        
                        Spacer()
                        
                        // Priority Badge
                        if task.priority == .high || task.priority == .urgent {
                            Text(task.priority.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(task.priority.color)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.3))
                    .font(.system(size: 14))
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .thin))
                .foregroundColor(.gray.opacity(0.4))
            
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.TaskPriority = .medium
    @State private var category: Task.TaskCategory = .personal
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var tags: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            
                            TextField("Enter task title", text: $title)
                                .font(.system(size: 17, design: .rounded))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            
                            TextField("Enter description (optional)", text: $description, axis: .vertical)
                                .font(.system(size: 17, design: .rounded))
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            
                            Picker("Priority", selection: $priority) {
                                ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                                    Text(priority.rawValue).tag(priority)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            
                            Picker("Category", selection: $category) {
                                ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                    Label(category.rawValue, systemImage: category.icon).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Due Date
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $hasDueDate) {
                                Text("Set Due Date")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                            }
                            
                            if hasDueDate {
                                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.graphical)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags (comma-separated)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            
                            TextField("work, important, urgent", text: $tags)
                                .font(.system(size: 17, design: .rounded))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .bold()
                }
            }
        }
    }
    
    private func saveTask() {
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        viewModel.addTask(
            title: title,
            description: description,
            priority: priority,
            category: category,
            dueDate: hasDueDate ? dueDate : nil,
            tags: tagArray
        )
        
        dismiss()
    }
}

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedTask: Task
    
    init(task: Task, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        _editedTask = State(initialValue: task)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Status Section
                        HStack {
                            Button(action: {
                                viewModel.toggleCompletion(task)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 28))
                                    Text(task.isCompleted ? "Completed" : "Mark Complete")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(task.isCompleted ? .appSuccess : .appPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        
                        // Task Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text(task.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.appTextPrimary)
                            
                            if !task.description.isEmpty {
                                Text(task.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.appTextSecondary)
                            }
                            
                            Divider()
                            
                            // Details Grid
                            VStack(spacing: 12) {
                                DetailRow(icon: task.category.icon, label: "Category", value: task.category.rawValue)
                                DetailRow(icon: "flag.fill", label: "Priority", value: task.priority.rawValue, valueColor: task.priority.color)
                                
                                if let dueDate = task.dueDate {
                                    DetailRow(icon: "calendar", label: "Due Date", value: dueDate.formatted(date: .long, time: .shortened), valueColor: task.isOverdue ? .appError : nil)
                                }
                                
                                DetailRow(icon: "clock", label: "Created", value: task.createdAt.formatted(date: .abbreviated, time: .shortened))
                                
                                if let completedAt = task.completedAt {
                                    DetailRow(icon: "checkmark.circle", label: "Completed", value: completedAt.formatted(date: .abbreviated, time: .shortened))
                                }
                            }
                            
                            // Tags
                            if !task.tags.isEmpty {
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tags")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    FlowLayout(spacing: 8) {
                                        ForEach(task.tags, id: \.self) { tag in
                                            Text(tag)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.appPrimary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.appPrimary.opacity(0.1))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .cardStyle()
                        
                        // Delete Button
                        Button(action: {
                            viewModel.deleteTask(task)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Task")
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color?
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(valueColor ?? .appTextPrimary)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

struct FiltersView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                List {
                    Section {
                        Toggle("Show Completed Tasks", isOn: $viewModel.showCompletedTasks)
                    }
                    
                    Section(header: Text("Sort By")) {
                        Picker("Sort Order", selection: $viewModel.sortOrder) {
                            ForEach(UserProfile.UserPreferences.SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    
                    Section(header: Text("Filter by Category")) {
                        Button(action: {
                            viewModel.selectedCategory = nil
                        }) {
                            HStack {
                                Text("All Categories")
                                Spacer()
                                if viewModel.selectedCategory == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.appPrimary)
                                }
                            }
                        }
                        
                        ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                            Button(action: {
                                viewModel.selectedCategory = category
                            }) {
                                HStack {
                                    Label(category.rawValue, systemImage: category.icon)
                                    Spacer()
                                    if viewModel.selectedCategory == category {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.appPrimary)
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.savePreferences()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    TaskListView()
}

