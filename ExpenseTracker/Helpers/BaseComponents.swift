//
//  BaseComponents.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 26.03.2024.
//

import Foundation
import SwiftUI

struct PickerView: View {
    @State private var selectedOption = 0
    let options: [String]
    
    var body: some View {
        VStack {
            Picker(selection: $selectedOption, label: Text("")) {
                ForEach(0..<options.count) { index in
                    Text(options[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // Change picker style as needed
            
        }
        .padding()
    }
}


struct CustomTextFieldNumber: View {
    @State private var inputValue = ""
    
    var body: some View {
        VStack {
            TextField("Harcadığınız para miktarı", text: $inputValue)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(Color.black, lineWidth: 1)
                )
                .keyboardType(.numberPad)
                .textFieldStyle(PlainTextFieldStyle()) // Optionally remove default styling
            
            // Other content here...
        }
        .padding(.trailing, 20)
        .frame(height: 90)
    }
}

