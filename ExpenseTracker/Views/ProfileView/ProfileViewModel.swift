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
    
    init(){
        fetchData()
    }
    
    func fetchData(){
        if let currentUserMail = Auth.auth().currentUser?.email {
           email = currentUserMail
        }
        else {
            print("no current user")
        }
        
    }
    
}
