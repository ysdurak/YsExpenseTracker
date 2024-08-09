//
//  AddExpenseAndIncome.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 9.08.2024.
//

import Foundation

import SwiftUI
struct AddExpenseAndIncome: View {
    @State private var selectedView: ViewType = .expense
    
    var body: some View {
        VStack(spacing: 16) {
            Picker(selection: $selectedView, label: Text("")) {
                Text("Gider")
                    .customFont(.medium, 13)
                    .foregroundColor(.orange)
                    .tag(ViewType.expense)
                
                Text("Gelir")
                    .customFont(.medium, 13)
                    .foregroundColor(.green)
                    .tag(ViewType.income)
            }
            .pickerStyle(SegmentedPickerStyle()) 
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .padding(.horizontal)
            
            if selectedView == .expense {
                AddExpenseView()
            } else {
                AddIncomeScreen()
            }
            
            Spacer()
        }
        .padding(.top)
    }
}

enum ViewType {
    case expense
    case income
}

#Preview {
    AddExpenseAndIncome()
}
