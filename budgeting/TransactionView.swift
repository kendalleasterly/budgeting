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
    
    let categoriesDict = [//comes from firebase, key is used for sorting by category
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
                                txns: txns[selectedCategory]!
                            )
                        }
                    }
                    
                }
            }
            
            Spacer()
        }.onAppear {
            
            model.getRecentTransactions()
        }
    }
}


struct CategorySubView: View {
    
    var categoryDict: [String: String]
    var categoryKey: String
    @Binding var biggestSize: CGSize
    @Binding var selectedCategory: String
    var model: TransactionModel
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
    
    var sunday: Date
    var txns: [Transaction]
    let calendar = Calendar.current
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack {
                Text(getWeekDescription(sunday))
                Spacer()
                HStack(spacing: 0) {
                    Text("$240.98")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                    
                    Text("/190.98")
                        .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                        .font(.caption)
                }
                
            }
            
            VStack(spacing: 16) {
                ForEach(getTxnsFromCurrentWeek()) { txn in
                    Text(txn.id.suffix(4) + ":" + txn.name)
                }
            }
            
        }.carded()
            .padding(.horizontal, 16)
    }
    
    func getTxnsFromCurrentWeek() -> [Transaction] {
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: sunday)!
        
        var txnsInCurrentWeek = [Transaction]()
        
        txns.forEach { txn in
            if (txn.date > sunday && txn.date < endOfWeek) {
                txnsInCurrentWeek.append(txn)
            }
        }
        
        return txnsInCurrentWeek
    }
    
    func getWeekDescription(_ week: Date) -> String {
        
        let differenceComponents = calendar.dateComponents([.day], from: week, to: Date())
        
        if let days = differenceComponents.day {
            if days < 7 {
                return "This Week"
            } else if days < 14 {
                return "Last Week"
            }
        }
        
        let nextSunday = calendar.date(byAdding: .day, value: 7, to: sunday)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        
        return formatter.string(from: sunday) + " - " + formatter.string(from: nextSunday)
        
    }
}

extension TransactionView {
    
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
        
        let calendar = Calendar.current
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
