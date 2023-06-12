//
//  TransactionView.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/10/23.
//

import SwiftUI

struct TransactionView: View {
    
    @ObservedObject var transactionModel = TransactionModel()
    
    var body: some View {
        
        VStack {
            Button("get transactions") {
                transactionModel.getRecentTransactions()
            }
            
            ForEach(transactionModel.transactions) { txn in
                HStack {
                    Text(txn.name)
                    Spacer()
                    Text(formatDate(txn.date))
                    Spacer()
                    Text(String(txn.amount))
                }
                
            }
        }
    }
}

extension TransactionView {
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM dd"
        
        return formatter.string(from: date)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
