//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 9.08.2024.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class AddExpenseViewModel: ObservableObject {
    @Published var userCategories: [CategoryModel] = []
    @Published var isLoading: Bool = false
    init() {
        getUserCategories()
    }
    
    func getUserCategories(completion: (() -> Void)? = nil) {
        isLoading = true
        Services.shared.getUserCategories { categories, error in
            if var categories = categories {
                // Accounts without saved categories would crash the picker, fall back to the defaults
                if categories.isEmpty {
                    categories = Defaults.shared.categories
                }
                Defaults.shared.userCategories = categories
                self.userCategories = categories
                self.isLoading = false// options dizisini güncelle
                completion?()
            } else {
                self.getUserCategories()
                print(error?.localizedDescription ?? "Unknown error")
            }
        }
    }

}
