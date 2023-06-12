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
    
    @Published var transactions = [Transaction]()
    
    func getRecentTransactions() {
        
        let serverURL = "http://localhost:8000/plaid"
        
        let requestParameters = [
            "access_token":"access-sandbox-cb7df117-ea4c-42c5-aaaf-36ae8ab8ba58"
        ]
        
        AF.request(serverURL + "/transactions", method: .post, parameters: requestParameters, encoder: JSONParameterEncoder.default).responseData { response in
            
            switch response.result {
                case .success(let data):
                    let json = JSON(data).dictionaryValue
                    
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
                        
                        let transactionObject = Transaction(name: name, amount: amount, id: id, date: date, city: "", region: "", pending: isPending, category: category)
                        
                        txns.append(transactionObject)
                    }
                    
                    self.transactions = txns
                    debugPrint(self.transactions)
                
                case .failure(let error):
                    print("error")
                    debugPrint(error)
            }
            
            
            
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
    
}
