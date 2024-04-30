//
//  RecentExpensesView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 19.04.2024.
//

import Foundation
import SwiftUI

struct RecentExpensesView: View {
    var body: some View {
        NavigationView {
            ScrollView{
                
                VStack(alignment: .leading, spacing: 10){
                    PeelEffect {
                        RecentExpensesCell()
                    } onDelete: {
                        print("deleted")
                    }
                    .padding(.horizontal, 20)
                    PeelEffect {
                        RecentExpensesCell()
                    } onDelete: {
                        print("deleted")
                    }
                    .padding(.horizontal, 20)
                    PeelEffect {
                        RecentExpensesCell()
                    } onDelete: {
                        print("deleted")
                    }
                    .padding(.horizontal, 20)
                    PeelEffect {
                        RecentExpensesCell()
                    } onDelete: {
                        print("deleted")
                    }
                    .padding(.horizontal, 20)

                }
                .padding(.top, 15)
                
            }
            .navigationTitle("Son Harcamalarım")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
