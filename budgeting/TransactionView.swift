//
//  TransactionView.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/10/23.
//

import SwiftUI

struct TransactionView: View {
    
    @ObservedObject var transactionModel = TransactionModel()
    @State var biggestSize: CGSize = .zero
    @State var selectedCategory = "transportation"
    
    let categoriesDict = [
        "transportation":[
            "emoji": "🚗",
            "name": "Transportation",
            "amount_spent": "$120.23"],
        "shopping":[
            "emoji": "🛒",
            "name": "Shopping",
            "amount_spent": "$253.67"],
        "food":[
            "emoji": "🍟",
            "name": "Food",
            "amount_spent": "$87.35"]
    ]
    
    var body: some View {
        
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    
                    ForEach(Array(categoriesDict.keys), id:\.self) { categoryKey in
                        CategorySubView(
                            categoryDict: categoriesDict[categoryKey]!,
                            categoryKey: categoryKey,
                            biggestSize: $biggestSize,
                            selectedCategory: $selectedCategory
                        )
                    }
                }.padding(16)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                
                
                
            }
            
            Spacer()
        }.onAppear {
            getWeeks()
        }
    }
}


struct CategorySubView: View {
    
    var categoryDict: [String: String]
    var categoryKey: String
    @Binding var biggestSize: CGSize
    @Binding var selectedCategory: String
    @State var currentSize: CGSize = .zero
    
    var body: some View {
        Button {
            
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                Text(categoryDict["emoji"]!)
                    .font(.largeTitle)
                    .fontWeight(.regular)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoryDict["name"]!)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(selectedCategory == categoryKey ? .white : .primaryLabel)
                    
                    Text(categoryDict["amount_spent"]!)
                        .font(.callout)
                        .foregroundColor(selectedCategory == categoryKey ? .white : Color(uiColor: UIColor.tertiaryLabel))
                }
                
            }.saveSize(in: $currentSize)
                .onAppear {
                    if (currentSize.width > biggestSize.width) {
                        biggestSize = currentSize
                    }
                }.fixedSize()
                .frame(width: biggestSize.width, height: biggestSize.width, alignment: .leading)
                .carded(bgColor: selectedCategory == categoryKey ? .appColor : .white)
            
        }
    }
}

struct WeekGroupSubView {
    
    var weekTitle: String
    
    var body: some View {
        Text(weekTitle)
    }
}

extension TransactionView {
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM dd"
        
        return formatter.string(from: date)
    }
    
    func getTxnsIn(_ category: Category) -> [Transaction] {
        
        var categoryString = ""
        var txnArray = [Transaction]()
        
        switch category {
        case .food:
            categoryString = "Food and Drink"
        case .payment:
            categoryString = "Payment"
        case .transportation:
            categoryString = "Travel"
        }
        
        for txn in transactionModel.transactions {
            
            if txn.category.starts(with: categoryString) {
                txnArray.append(txn)
            }
        }
        
        return txnArray
    }
    
//    func getWeeks() -> [String] {
    func getWeeks() -> () {
        
        let calendar = Calendar.current
        
        let startOfMonthComponents = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: startOfMonthComponents)!
        
        let startOfMonthWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var currentSunday = calendar.date(byAdding: .day, value: -(startOfMonthWeekday - 1), to: startOfMonth)!
        
        if (startOfMonthWeekday > 4) {
            currentSunday = calendar.date(byAdding: .day, value: 7, to: currentSunday)!
        }
        
        var weekDescriptions = [String]()
        
        while (currentSunday.timeIntervalSince1970 <= Date().timeIntervalSince1970) {
            let currentWeekOfMonth = calendar.component(.weekOfMonth, from: Date())
            print(currentWeekOfMonth)
        currentSunday = calendar.date(byAdding: .day, value: 7, to: currentSunday)!n
        }
        
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
