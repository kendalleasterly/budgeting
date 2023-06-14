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
                
                VStack {
                    ForEach(getWeeks(), id:\.self.timeIntervalSince1970) {week in
                        WeekGroupSubView(weekTitle: "", sunday: week)
                    }
                }
                
            }
            
            Spacer()
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
            selectedCategory = categoryKey
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                Text(categoryDict["emoji"]!)
                    .font(.largeTitle)
                    .fontWeight(.regular)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoryDict["name"]!.prefix(16))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(selectedCategory == categoryKey ? .white : .primaryLabel)
                    
                    Text(categoryDict["amount_spent"]!)
                        .font(.callout)
                        .foregroundColor(selectedCategory == categoryKey ? .white : Color(uiColor: UIColor.tertiaryLabel))
                }
                
            }.fixedSize().saveSize(in: $currentSize)
                .onAppear {
                    if (currentSize.width > biggestSize.width) {
                        biggestSize = currentSize
                    }
                }
                .frame(width: max(biggestSize.width, currentSize.height), height: max(biggestSize.width, currentSize.height), alignment: .leading)
                .carded(bgColor: selectedCategory == categoryKey ? .appColor : .white)
            
        }
    }
}

struct WeekGroupSubView: View {
    
    var weekTitle: String
    var sunday: Date
    
    var body: some View {
        Text(String(sunday.description))
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
    
    func getFinancialRangeFor(_ month: Date) -> (Date, Date) {
        let calendar = Calendar.current
        
        let startOfMonthComponents = calendar.dateComponents([.year, .month], from: month)
        let startOfMonth = calendar.date(from: startOfMonthComponents)!
        
        let startOfMonthWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var startOfRange = calendar.date(byAdding: .day, value: -(startOfMonthWeekday - 1), to: startOfMonth)! //assumes first week is in the majority until proven otherwise
        
        if (startOfMonthWeekday > 4) { //the first week is in the minority
            
            startOfRange = calendar.date(byAdding: .day, value: 7, to: startOfRange)!
        }
        
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let endOfMonthWeekday = calendar.component(.weekday, from: endOfMonth)
        
        var endOfRange = calendar.date(byAdding: .day, value: (7 - endOfMonthWeekday) + 1, to: endOfMonth)!
        
        if (endOfMonthWeekday <= 3 ) {
            endOfRange = calendar.date(byAdding: .day, value: -7, to: endOfRange)!
        }
        
        return (startOfRange, endOfRange)
        
    }

    func getWeeks() -> [Date] {
        
        let calendar = Calendar.current
        let today = Date()
        
        let (startOfRange, endOfRange) = getFinancialRangeFor(today)
        
        if (startOfRange.timeIntervalSince1970 > today.timeIntervalSince1970) {
            //we are before the current financial month
            let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: today)!
            
            let (previousStart, previousEnd) = getFinancialRangeFor(lastMonthDate)
            
            return loadAllWeeksInRange(previousStart, previousEnd)
            
        } else if (endOfRange.timeIntervalSince1970 < today.timeIntervalSince1970) {
            //we are after the current financial month, get just this week
            return [endOfRange]
            
        } else {
//            we are within the current financial month
            return loadAllWeeksInRange(startOfRange, endOfRange)
        }
    }
    
    func loadAllWeeksInRange(_ startDate: Date, _ endDate: Date) -> [Date] {
        //each date passed out of this function is the sunday of the week. it represents the entire week.
        
        let calendar = Calendar.current
        
        var sundayIndex = startDate
        
        var weeks = [Date]()
        
        while (sundayIndex.timeIntervalSince1970 < Date().timeIntervalSince1970) {
            weeks.append(sundayIndex)
            sundayIndex = calendar.date(byAdding: .day, value: 7, to: sundayIndex)!
            
        }
        
        return weeks
        
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
