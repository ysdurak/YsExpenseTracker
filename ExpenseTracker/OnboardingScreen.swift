//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 25.03.2024.
//

import SwiftUI
import SwiftData

struct OnboardingScreen: View {
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(spacing: 10){
                    Spacer()
                    Image("money")
                        .resizable()
                        .frame(width: 250, height: 230)
                    Text("Paranızı yönetmenin en kolay yolu")
                        .font(.headline)
                    Text("Track Me ile hemen başla !")
                    Spacer()
                    NavigationLink(destination: MainTabView().navigationBarBackButtonHidden(true)) {
                        Text("Devam Et")
                            .font(.title)
                        
                    }
                    
                    
                    
                }
            }
        }
    }
}


#Preview {
    OnboardingScreen()
}
