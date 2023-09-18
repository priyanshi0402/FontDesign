//
//  IAPHelper.swift
//  ScannerProVision
//
//  Created by Netra Technosys on 01/02/21.
//

import Foundation
import SwiftyStoreKit
import UIKit

let shared_secret = "f1ab31b448374cb0b3485d47292ff201"
let weekly_id = "com.fontdesigns.iOSPro"

//Monthly
var weekly_price : String {
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.synchronize()
    if let price = defaults?.value(forKey: "\(weekly_id)_price") as? String {
        return price
    }
    return "5.99 USD"
}

var is_purchased_weekly : Bool {
    let defaults = UserDefaults(suiteName: groupID)
    if let bool = defaults?.value(forKey: "\(weekly_id)_purchased") as? Bool {
        return bool
    }
    defaults?.setValue(false, forKey: "\(weekly_id)_purchased")
    defaults?.synchronize()
    
    return false
}

func setWeeklyPurchased(bool: Bool) {
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.setValue(bool, forKey: "\(weekly_id)_purchased")
    defaults?.synchronize()
}

var is_purchased : Bool {
    if is_purchased_weekly {
        return true
    }
    return false
}

//Date
var iap_start_date : Date? {
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.synchronize()
    if let dateStr = defaults?.value(forKey: "iap_start_date") as? String {
        return convertStringToDate(str: dateStr)
    }
    return nil
}

var iap_expiry_date : Date? {
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.synchronize()
    if let dateStr = defaults?.value(forKey: "iap_expiry_date") as? String {
        return convertStringToDate(str: dateStr)
    }
    return nil
}

func setIAPStartDate(date: Date) {
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.setValue(convertDateToString(date: date), forKey: "iap_start_date")
    defaults?.synchronize()
}

func setIAPExpiryDate(date: Date) {
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.setValue(convertDateToString(date: date), forKey: "iap_expiry_date")
    defaults?.synchronize()
}

func convertDateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy h:mm a"
    let myString = formatter.string(from: date)
    let yourDate = formatter.date(from: myString)
    formatter.dateFormat = "dd-MM-yyyy h:mm a"
    let myStringafd = formatter.string(from: yourDate!)
    return myStringafd
}

func convertStringToDate(str: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy h:mm a"
    return dateFormatter.date(from: str)!
}

//IAPHelper
struct IAPHelper {
    
    //Get plan details
    static func retrieveProductsInfo(completion: @escaping (Bool) -> Void ) {
        
        SwiftyStoreKit.retrieveProductsInfo([weekly_id]) { result in
            if result.retrievedProducts.count > 0 {
                for res in result.retrievedProducts {
                    let priceString = res.localizedPrice!
                    print("Product: \(res.localizedDescription), fullprice: \(priceString), price: \(res.price), currencySymbol \(res.priceLocale.currencySymbol ?? ""), currencyCode \(res.priceLocale.currencyCode ?? "")")
                    let defaults = UserDefaults(suiteName: groupID)
                    defaults?.setValue(priceString, forKey: "\(res.productIdentifier)_price")
                    defaults?.synchronize()
                    
                }
                completion(true)
            } else if result.invalidProductIDs.count > 0 {
                for id in result.invalidProductIDs {
                    print("Invalid product identifier: \(id)")
                }
                completion(false)
            } else {
                print("Error: \(String(describing: result.error))")
                completion(false)
            }
        }
        
    }
    
    //Do subcription
    static func doSubscription(productId : String, completion: @escaping (String?, PurchaseDetails?, Bool) -> Void ) {
        
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                completion(nil, purchase, true)
            case .error(let error):
                var strMessage : String = ""
                switch error.code {
                case .unknown:
                    strMessage = "Unknown error. Please contact support."
                    print("Unknown error. Please contact support.")
                    
                case .clientInvalid:
                    strMessage = "Not allowed to make the payment."
                    print("Not allowed to make the payment.")
                    
                case .paymentCancelled:
                    strMessage = "Payment have been cancelled."
                    print("Payment have been cancelled.")
                    
                case .paymentInvalid:
                    strMessage = "The purchase identifier was invalid."
                    print("The purchase identifier was invalid.")
                    
                case .paymentNotAllowed:
                    strMessage = "The device is not allowed to make the payment."
                    print("The device is not allowed to make the payment.")
                    
                case .storeProductNotAvailable:
                    strMessage = "The product is not available in the current storefront."
                    print("The product is not available in the current storefront.")
                    
                case .cloudServicePermissionDenied:
                    strMessage = "Access to cloud service information is not allowed."
                    print("Access to cloud service information is not allowed.")
                    
                case .cloudServiceNetworkConnectionFailed:
                    strMessage = "Could not connect to the network."
                    print("Could not connect to the network.")
                    
                case .cloudServiceRevoked:
                    strMessage = "User has revoked permission to use this cloud service."
                    print("User has revoked permission to use this cloud service.")
                    
                default:
                    strMessage = error.localizedDescription
                    print((error as NSError).localizedDescription)
                }
                
                completion(strMessage, nil, false)
            }
            
        }
        
    }
    
    //Check purchase status
    static func checkPurchaseStatus(productId : String, completion: @escaping (String?, Date?, Bool) -> Void ) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: shared_secret)
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productId, inReceipt: receipt)
                
                switch purchaseResult {
                    
                case .purchased(let expiryDate, _):
                    print("\(productId) is valid until \(expiryDate).")
                    completion(nil, expiryDate, true)
                    
                case .expired(let expiryDate, _):
                    let dateStr = convertDateToString(date: expiryDate)
                    print("\(productId) is expired since \(dateStr)")
                    completion("Your Subscription is expired since \(dateStr).", expiryDate, false)
                    
                case .notPurchased:
                    print("\(productId) is not Purchased")
                    completion("It seems that You have not Subscribed to any Plan.", nil, false)
                    
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(error.localizedDescription, nil, false)
                
            }
            
        }
    }
    
    //Restore
    static func restorePurchase(completion: @escaping (String?, String?, Date?, Bool) -> Void ) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: shared_secret)
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            switch result {
            case .success(let receipt):
                
                let iapIds = [weekly_id]
                
                for productId in iapIds {
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productId, inReceipt: receipt)
                    
                    switch purchaseResult {
                        
                    case .purchased(let expiryDate, _):
                        print("\(productId) is valid until \(expiryDate)")
                        completion(nil, productId, expiryDate, true)
                        return
                        
                    case .expired(let expiryDate, _):
                        print("\(productId) is expired since \(expiryDate)")
                        
                    case .notPurchased:
                        print("\(productId) is not Purchased")
                        
                    }
                }
                
                completion("It seems that You have not Subscribed to any Plan.", nil, nil, false)
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(error.localizedDescription, nil, nil, false)
                
            }
            
        }
    }
}
