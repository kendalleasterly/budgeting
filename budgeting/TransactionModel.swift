//
//  TransactionModel.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/10/23.
//

import Foundation
import SwiftyJSON
import Alamofire

class TransactionModel: ObservableObject {
    
    @Published var transactions: [String: [Transaction]]?
    let catogories = ["transportation":"Travel", "food":"Food and Drink", "payment": "Payment"]
    
    func getRecentTransactions(resolve: @escaping () -> Void) {
        
        let serverURL = "https://flexitrackr-d76ba95d2033.herokuapp.com/plaid"
        
        let requestParameters = [
            "access_token":"access-sandbox-cb7df117-ea4c-42c5-aaaf-36ae8ab8ba58"
        ]
        
        AF.request(serverURL + "/transactions", method: .post, parameters: requestParameters, encoder: JSONParameterEncoder.default).responseData { response in
            
            if let error = response.error {
                print("error")
                debugPrint(error)
            } else {
                
                let json = JSON(response.data!).dictionaryValue
                
                var txns = [Transaction]()
                    
                let latestTransactions = json["latest_transactions"]!.arrayValue
                for txn in latestTransactions {
                    let amount = txn["amount"].floatValue
                    let name = txn["name"].stringValue
                    let id = txn["transaction_id"].stringValue
                    let isPending = txn["pending"].boolValue
                    
                    let categoryArray = txn["category"].arrayValue
                    let category = categoryArray[0].stringValue + " - " + categoryArray[1].stringValue
                    
                    var date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let dateString = txn["date"].stringValue
                    if let dateObject = dateFormatter.date(from: dateString) {
                        date = dateObject
                    }
                    
                    let transactionObject = Transaction(name: name, amount: amount, id: id, date: date, city: "", region: "", pending: isPending, category: category, emoji: self.getEmojiFor(categoryArray[1].stringValue))
                    
                    txns.append(transactionObject)
                    
                }
                
            self.transactions = self.sortTransactionsByCategory(txns: txns)
            resolve()
            }
        }
        
    }
    
    func sortTransactionsByCategory(txns: [Transaction]) -> [String:[Transaction]] {
        
        var txnsByCategory = [String:[Transaction]]()
        
        catogories.forEach { (key: String, searchTerm: String) in
    
            var txnArray = [Transaction]()
            
            for txn in txns {
                
                if txn.category.starts(with: searchTerm) {
                    txnArray.append(txn)
                }
            }
            
            txnsByCategory[key] = txnArray
        }
        
        return txnsByCategory
    }
    
    func getEmojiFor(_ subCategory: String) -> String{
        
        switch subCategory {
        case "Restaurants":
            return "🍽️"
        case "Taxi":
            return "🚕"
        case "Airlines and Aviation":
            return "✈️"
        case "Credit Card":
            return "💳"
        default:
            return "💵"
        }
    }
    
}

struct Transaction: Identifiable {
    var name: String //use Merchant name unless it is null, then use name
    var amount: Float
    var id: String
    var date: Date //should use authorization date, because that is when the user origanally made the purchase
    var city: String
    var region: String
    var pending: Bool
    var category: String
    var emoji: String
    
}
