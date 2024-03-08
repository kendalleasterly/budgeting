//
//  TransactionSubViews.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/14/23.
//

import SwiftUI

struct CategorySubView: View {
    
    var categoryDict: [String: Any]
    var categoryKey: String
    @Binding var biggestSize: CGSize
    @Binding var selectedCategory: String
    var model: TransactionModel
    @State var currentSize: CGSize = .zero
    
    var body: some View {
        Button {
            withAnimation {
                selectedCategory = categoryKey
            }
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                Text(categoryDict["emoji"] as? String ?? "🤨")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text((categoryDict["name"] as? String ?? "").prefix(16))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(selectedCategory == categoryKey ? .white : .primaryLabel)
                    
                    Text("$" + String(formatDollarAmount(amount: categoryDict["amount_spent"] as? Float ?? 0 )))
                        .font(.callout)
                        .foregroundColor(selectedCategory == categoryKey ? .white : .tertiaryLabel)
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
    var allTxns: [Transaction]
    let calendar = Calendar.current
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack {
                Text(getWeekDescription(sunday))
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondaryLabel)
                Spacer()
                HStack(spacing: 0) {
                    Text("$" + getTotalSpent())
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                    
                    Text("/190.98")
                        .foregroundColor(.secondaryLabel)
                        .font(.caption)
                }
            }
            
            VStack(spacing: 16) {
                ForEach(getTxnsFromCurrentWeek()) { txn in
                    TransactionSubView(transaction: txn)
                }
            }
        }.carded()
            .padding(.horizontal, 16)
    }
    
    func getTotalSpent() -> String {
        
        var total: Float = 0
        
        getTxnsFromCurrentWeek().forEach { txn in
            total+=txn.amount
        }
        
        return formatDollarAmount(amount: total)
    }
    
    func getTxnsFromCurrentWeek() -> [Transaction] {
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: sunday)!
        var txnsInCurrentWeek = [Transaction]()
        
        allTxns.forEach { txn in
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
        
        let nextSunday = calendar.date(byAdding: .day, value: 6, to: sunday)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        
        return formatter.string(from: sunday) + " - " + formatter.string(from: nextSunday)
        
    }
}

struct TransactionSubView: View {
    
    let transaction: Transaction
    
    var body: some View {
        
        HStack(spacing: 16) {
            Text(transaction.emoji)
                .font(.title2)
                .frame(width: 32, height: 32)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.secondaryBackground))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .lineLimit(1)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(formatDate(transaction.date))
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.secondaryLabel)
            }
            
            Spacer()
            
            Text("$" + formatDollarAmount(amount: transaction.amount))
                .font(.body)
                .fontWeight(.medium)
                
        }.carded(px: 8, py: 12, customShadow: true)
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.05)), radius:1, x:0, y:1)
    }
    
    func formatDate(_ date: Date) -> String {
        
        let calendar = Calendar.current
        let differenceComponents = calendar.dateComponents([.day], from: date, to: Date())
        
        switch differenceComponents.day! {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        default:
            
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            let formattedDate =  formatter.string(from: date)
            
            return formattedDate
        }
    }
    
}
