//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 25.03.2024.
//

import Foundation
import SwiftUI
import Charts

struct HomeScreen: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]) var expense: FetchedResults<Expense>
    @Environment(\.colorScheme) var scheme
    @State var sampleAnalytics: [AnimatedGraphData]
    @State var plotWidth: CGFloat = 0
    @State var currentActiveItem: AnimatedGraphData?
    @State var currentTab: String = "Weekly"
    
    
    func getTotalValue() -> Double {
        var totalValue: Double = 0.0
        for item in sampleAnalytics {
            totalValue = totalValue + item.value
        }
        return totalValue
    }
    
    var body: some View {
        ScrollView{
            VStack{
                VStack(alignment: .leading, spacing: 12){
                    HStack{
                        Text("Harcamalar")
                            .fontWeight(.semibold)
                        Spacer()
                        Picker("", selection: $currentTab) {
                            Text("Haftalık")
                                .tag("Weekly")
                            Text("Aylık")
                                .tag("Monthly")
                            Text("Yıllık")
                                .tag("Year")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading, 20)
                        
                    }
                    
                    
                    Text(getTotalValue().stringFormat + " TL")
                        .font(.largeTitle.bold())
                    
                    AnimatedChart()
                    
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill((scheme == .dark ? Color.black : Color.white).shadow(.drop(radius: 2)))
                }
                
                VStack{
                    HStack{
                        Text("Harcama Özetim")
                            .customFont(.regular, 24)
                        Spacer()
                    }
                    
                    HStack{
                        ExpenseSummary(
                            imageName: "arrowtriangle.up.circle",
                            title: "Aylık Gelirlerim",
                            valueText: "10.380 TL",
                            bgColor: .green.opacity(
                                0.3
                            )
                        )
                        Spacer()
                            .frame(width: 10)
                        ExpenseSummary(
                            imageName: "arrowtriangle.down.circle",
                            title: "Aylık Giderlerim",
                            valueText: "- 3800 TL",
                            bgColor: .red.opacity(
                                0.3
                            )
                        )
                    }
                }
                .padding(.top, 10)
                
                VStack{
                    HStack{
                        Text("Son Harcamalarım")
                            .customFont(.regular, 24)
                        Spacer()
                        Text("Tümü")
                            .customFont(.semiBold, 15)
                            .underline()
                        
                        
                    }
                    ExpenseCell(imageName: "internaldrive", category: "Teknoloji", amount: "-1800 TL")
                    ExpenseCell(imageName: "server.rack", category: "Abonelikler", amount: "-782 TL")
                    ExpenseCell(imageName: "cart", category: "Market", amount: "-300 TL")
                }
                .padding(.top, 10)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            // MARK: Simply Updating Values For Segmented Tabs
            .onChange(of: currentTab) { newValue in
                sampleAnalytics = AnimatedGraphDataManager.generateSampleAnalytics(from: expense, timeRange: .weekly)
                if currentTab == "Weekly" {
                    sampleAnalytics = AnimatedGraphDataManager.generateSampleAnalytics(from: expense, timeRange: .weekly)
                } else if currentTab == "Monthly" {
                    sampleAnalytics = AnimatedGraphDataManager.generateSampleAnalytics(from: expense, timeRange: .monthly)
                } else if currentTab == "Year" {
                    sampleAnalytics = AnimatedGraphDataManager.generateSampleAnalytics(from: expense, timeRange: .weekly)
                }
                
                animateGraph(fromChange: true)
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart()->some View{
        let max = sampleAnalytics.max { item1, item2 in
            return item2.value > item1.value
        }?.value ?? 0
        
        Chart{
            ForEach(sampleAnalytics){item in
                    BarMark(
                        x: .value("Hour", item.date,unit: .day),
                        y: .value("Views", item.animate ? item.value : 0)
                    )
                    .foregroundStyle(Color.orange.gradient)
                
                // MARK: Rule Mark For Currently Dragging Item
                if let currentActiveItem,currentActiveItem.id == item.id{
                    RuleMark(x: .value("Tarih", currentActiveItem.date))
                    // Dotted Style
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                    // MARK: Setting In Middle Of Each Bars
                        .offset(x: (plotWidth / CGFloat(sampleAnalytics.count)) / 2)
                        .annotation(position: .top){
                            VStack(alignment: .leading, spacing: 6){
                                Text("Harcanan")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(currentActiveItem.value.stringFormat)
                                    .font(.title3.bold())
                            }
                            .padding(.horizontal,10)
                            .padding(.vertical,4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill((scheme == .dark ? Color.black : Color.white).shadow(.drop(radius: 2)))
                            }
                        }
                }
            }
        }
        // MARK: Customizing Y-Axis Length
        .chartYScale(domain: 0...(max + 100))
        .chartOverlay(content: { proxy in
            GeometryReader{innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged{value in
                                // MARK: Getting Current Location
                                let location = value.location
                                // Don't Forgot to Include the perfect Data Type
                                if let date: Date = proxy.value(atX: location.x){
                                    // Extracting Hour
                                    let calendar = Calendar.current
                                    let date = calendar.component(.day, from: date)
                                    if let currentItem = sampleAnalytics.first(where: { item in
                                        calendar.component(.day, from: item.date) == date
                                    }){
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotAreaSize.width
                                    }
                                }
                            }
                            .onEnded{value in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .frame(height: 250)
        .onAppear {
            animateGraph()
        }
    }
    
    // MARK: Animating Graph
    func animateGraph(fromChange: Bool = false){
        for (index,_) in sampleAnalytics.enumerated(){
            // For Some Reason Delay is Not Working
            // Using Dispatch Queue Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ? .easeInOut(duration: 0.6) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
                    sampleAnalytics[index].animate = true
                }
            }
        }
    }
    
}
