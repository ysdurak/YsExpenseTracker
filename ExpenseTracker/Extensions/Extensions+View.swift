//
//  Extensions+View.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 10.08.2024.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            self.hideKeyboard()
        }
    }
}
