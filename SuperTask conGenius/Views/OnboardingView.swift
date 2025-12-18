//
//  OnboardingView.swift
//  Task conGenius
//
//  Created on Dec 18, 2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        if index < viewModel.pages.count - 1 {
                            // Regular onboarding pages
                            OnboardingPageView(page: page)
                                .tag(index)
                        } else {
                            // Customization page
                            CustomizationPageView(viewModel: viewModel)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentPage)
                
                // Custom Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.currentPage ? Color.appPrimary : Color.gray.opacity(0.3))
                            .frame(width: index == viewModel.currentPage ? 10 : 8, height: index == viewModel.currentPage ? 10 : 8)
                            .animation(.spring(), value: viewModel.currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            viewModel.previousPage()
                        }) {
                            Text("Back")
                                .secondaryButtonStyle()
                        }
                        .transition(.move(edge: .leading))
                    }
                    
                    Button(action: {
                        if viewModel.isLastPage {
                            completeOnboarding()
                        } else {
                            viewModel.nextPage()
                        }
                    }) {
                        Text(viewModel.isLastPage ? "Get Started" : "Next")
                            .primaryButtonStyle()
                    }
                    .disabled(!viewModel.canProceed)
                    .opacity(viewModel.canProceed ? 1 : 0.6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        viewModel.completeOnboarding()
        hasCompletedOnboarding = true
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 100, weight: .thin))
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Description
            Text(page.description)
                .font(.system(size: 18, weight: .regular, design: .default))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .lineSpacing(8)
            
            Spacer()
        }
    }
}

struct CustomizationPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Icon
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80, weight: .thin))
                    .foregroundColor(.purple)
                    .padding(.top, 40)
                
                // Title
                Text("Let's Personalize")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                
                VStack(spacing: 24) {
                    // Username
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What should we call you?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                        
                        TextField("Your name", text: $viewModel.username)
                            .textFieldStyle(.plain)
                            .font(.system(size: 17, design: .rounded))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Default Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Task Category")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                        
                        Picker("Category", selection: $viewModel.selectedDefaultCategory) {
                            ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Default Priority
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Task Priority")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                        
                        Picker("Priority", selection: $viewModel.selectedDefaultPriority) {
                            ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue)
                                    .tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Notifications Toggle
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.appPrimary)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Notifications")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            Text("Get reminded about your tasks")
                                .font(.system(size: 13))
                                .foregroundColor(.appTextSecondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.notificationsEnabled)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
}

