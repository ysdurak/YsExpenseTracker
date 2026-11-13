//
//  ProfileViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import SwiftUI
import Firebase

final class ProfileViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var displayName: String = ""
    
    init(){
        fetchData()
    }
    
    func fetchData(){
        if let user = Auth.auth().currentUser {
            email = user.email ?? ""
            // Fall back to the part of the e-mail before "@" when no display name is set.
            displayName = user.displayName ?? email.components(separatedBy: "@").first?.capitalized ?? ""
        }
        else {
            print("no current user")
        }
        
    }
    
}
