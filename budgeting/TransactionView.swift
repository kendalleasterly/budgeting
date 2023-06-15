//
//  TransactionView.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/10/23.
//

import SwiftUI

struct TransactionView: View {
    
    @ObservedObject var model = TransactionModel()
    @State var biggestSize: CGSize = .zero
    @State var selectedCategory = "transportation"
    let calendar = Calendar.current
    
    @State var categoriesDict: [String:[String:Any]] = [//comes from firebase, key is used for sorting by category
        "transportation":[
            "emoji": "🚗",
            "name": "Transportation",
            "amount_spent": 120.23],
        "payment":[
            "emoji": "💸",
            "name": "Payment",
            "amount_spent": 253.67],
        "food":[
            "emoji": "🍟",
            "name": "Food",
            "amount_spent": 87.35]
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
                            selectedCategory: $selectedCategory, model: model
                        )
                    }
                }.padding(16)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack {
                    
                    if let txns = model.transactions {
                        ForEach(getWeeks(), id:\.self.timeIntervalSince1970) {week in
                            WeekGroupSubView(
                                sunday: week,
                                allTxns: txns[selectedCategory]!
                            )
                        }
                    }
                    
                }
            }
        }.onAppear {
            
            model.getRecentTransactions {
                calculateTotalSpentForEach()
            }
        }
    }
}

extension TransactionView {
    
    func calculateTotalSpentForEach() -> Void {
        
        let today = calendar.date(byAdding: .day, value: -15, to: Date())!
        let (startDate, _) = getFinancialRangeFor(today)
        print(startDate)
        
        model.transactions?.forEach({ (key: String, txns: [Transaction]) in
            
            var total:Float = 0
            
            txns.forEach { txn in
                
                if (txn.date > startDate && txn.date < Date()) {
                    total+=txn.amount
                }
            }
            
            if var txnDict = categoriesDict[key] {
                txnDict["amount_spent"] = round(total * 100) / 100
                categoriesDict[key]! = txnDict
            }
        })
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "M/d"
        
        return formatter.string(from: date)
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
        
        let today = calendar.date(byAdding: .day, value: -15, to: Date())!
        var weeks = [Date]()
        
        let (startOfRange, endOfRange) = getFinancialRangeFor(today)
        
        if (startOfRange.timeIntervalSince1970 > today.timeIntervalSince1970) {
            //we are before the current financial month
            let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: today)!
            
            let (previousStart, previousEnd) = getFinancialRangeFor(lastMonthDate)
            
            weeks = loadAllWeeksInRange(previousStart, previousEnd)
            
        } else if (endOfRange.timeIntervalSince1970 < today.timeIntervalSince1970) {
            //we are after the current financial month, get just this week
            weeks = [endOfRange]
            
        } else {
            //            we are within the current financial month
            weeks = loadAllWeeksInRange(startOfRange, endOfRange)
        }
        
        return weeks.sorted {date1, date2 in
            return date1  > date2
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
