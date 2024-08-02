//
//  RegisterScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation


final class RegisterScreenViewModel: ObservableObject {
    @Published var email: String? = ""
    @Published var password: String? = ""
}
