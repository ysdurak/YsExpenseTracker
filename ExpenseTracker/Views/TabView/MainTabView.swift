//
//  MainTabView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 26.03.2024.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]) var expense: FetchedResults<Expense>
    @StateObject var appModel: AppViewModel = .init()
    @StateObject var authViewModel = AuthViewModel()
    @State private var isKeyboardVisible = false
    @State private var showSignInView = false
    @Namespace var animation
    
    @Environment (\.managedObjectContext) var managedObjContext
    @Environment (\.dismiss) var dismiss
    
    init(){
        UITabBar.appearance().isHidden = true
    }
    var body: some View {
        ZStack{
            if authViewModel.isLoading {
                VStack{
                    ProgressView("Yükleniyor...")
                }
            }
            else {
                TabView(selection: $appModel.currentTab) {
                    
                    HomeScreen()
                        .environmentObject(appModel)
                        .tag(Tab.home)
                        .setUpTab()
                    
                    RecentExpensesView()
                        .tag(Tab.cart)
                        .setUpTab()
                    
                    AddExpenseAndIncome()
                        .tag(Tab.addSomething)
                        .setUpTab()
                        .environmentObject(authViewModel)

                    ProfileScreen()
                        .environmentObject(authViewModel)
                        .tag(Tab.profile)
                        .setUpTab()
                }
                
                CustomTabBar(currentTab: $appModel.currentTab, animation: animation)
                    .offset(y: UIScreen.main.bounds.height / 2 - 50)
            }

        }
        .onAppear {
            authViewModel.checkAuthentication()
        }
        .fullScreenCover(isPresented: Binding(
            get: { !authViewModel.isAuthenticated },
            set: { authViewModel.isAuthenticated = !$0 }
        )) {
            LoginScreen()
                .environmentObject(authViewModel)
        }
    }
}
    
    class AppViewModel: ObservableObject {
        // MARK: Properties
        @Published var currentTab: Tab = .home
    }
    
    extension View{
        @ViewBuilder
        func setUpTab()->some View{
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

