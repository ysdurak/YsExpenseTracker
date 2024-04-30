//
//  MainTabView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 26.03.2024.
//

import Foundation
import SwiftUI

struct MainTabView {
    @StateObject var appModel: AppViewModel = .init()
    @Namespace var animation
    init(){
        UITabBar.appearance().isHidden = true
    }
    var body: some View {
        TabView(selection: $appModel.currentTab) {
            
            HomeScreen()
                .environmentObject(appModel)
                .tag(Tab.home)
                .setUpTab()
            
            Text("Cart")
                .tag(Tab.cart)
                .setUpTab()
            
            Text("Favourite")
                .tag(Tab.favourite)
                .setUpTab()
            
            Text("Profile")
                .tag(Tab.profile)
                .setUpTab()
        }
        .overlay(alignment: .bottom) {
            CustomTabBar(currentTab: $appModel.currentTab, animation: animation)
                .offset(y: 0)
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
            .background{
                Color("BG")
                    .ignoresSafeArea()
            }
    }
}
