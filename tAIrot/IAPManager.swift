//
//  IAPManager.swift
//  The Seer
//
//  Created by Brandon Ramírez Casazza on 29/06/23.
//

import Foundation
import StoreKit
import Combine

class IAPManager: NSObject, ObservableObject, SKProductsRequestDelegate {
    static let shared = IAPManager()
    
    let annualSubscriptionProductID = "unlimited_predictions_lifetime"
    let monthlySubscriptionProductID = "unlimited_predictions_monthly"
    let individualPredictionProductID = "single_prediction"

    @Published var annualSubscription: SKProduct?
    @Published var monthlySubscription: SKProduct?
    @Published var individualPrediction: SKProduct?
    @Published var purchaseEvents = PassthroughSubject<String, Never>()
    @Published var purchasedPredictionCount = 0
    @Published var storeObserver = StoreObserver.shared

    private var transactionListener: Task<Void, Never>?

    @Published var onSinglePredictionPurchased: (() -> Void)?
    
    var isMonthlySubscriptionActive: Bool {
            return StoreObserver.shared.isMonthlySubscriptionActive
        }
    var isAnnualSubscriptionActive: Bool {
        return StoreObserver.shared.isAnnualSubscriptionActive
    }
    
    var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        print("Creating an instance of IAPManager.")
        SKPaymentQueue.default().add(storeObserver)
        startListeningForTransactions()
        
        // Load the saved count from UserDefaults
        purchasedPredictionCount = UserDefaults.standard.integer(forKey: "purchasedPredictionCount")
        
        onSinglePredictionPurchased = { [weak self] in
            DispatchQueue.main.async {  // Add this line
                self?.purchasedPredictionCount += 1
                print("Single prediction purchased, increasing purchasedPredictionCount")
                
                // Save the updated count to UserDefaults
                UserDefaults.standard.set(self?.purchasedPredictionCount, forKey: "purchasedPredictionCount")
            }
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(storeObserver)
        transactionListener?.cancel()
    }

    func fetchProducts() {
        let productIDs = Set([annualSubscriptionProductID, monthlySubscriptionProductID, individualPredictionProductID])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            if product.productIdentifier == annualSubscriptionProductID {
                DispatchQueue.main.async {
                    self.annualSubscription = product
                }
            } else if product.productIdentifier == monthlySubscriptionProductID {
                DispatchQueue.main.async {
                    self.monthlySubscription = product
                }
            } else if product.productIdentifier == individualPredictionProductID {
                DispatchQueue.main.async {
                    self.individualPrediction = product
                }
            }
        }
    }

    func buyProduct(_ product: SKProduct) {
        print("Initiating purchase for product: \(product.productIdentifier)")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    // Start listening for transaction updates
    // Start listening for transaction updates
    func startListeningForTransactions() {
        print("Starting to listen for transactions...")  // Add this line
        transactionListener = Task {
            for await result in Transaction.updates {
                print("Received transaction update.")  // Add this line
                switch result {
                case .unverified(_, let error):
                    // The local transaction verification failed, you should log or handle the error
                    print("Failed to verify transaction: \(error)")
                    print("Transaction type: unverified")
                case .verified(let transaction):
                    // The transaction was verified, you can now check the product id
                    print("Transaction type: verified")
                    print("Product ID: \(transaction.productID)") // Add this line
                    handleTransaction(transaction)
                }
            }
        }
    }
    
    // Add this function to handle restoring purchases
    func restorePurchases() {
        print("Initiating restoration of purchases.")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    @Sendable
    private func handleTransaction(_ transaction: Transaction) {
        // Check the product id of the transaction
        if transaction.productID == self.annualSubscriptionProductID || transaction.productID == self.monthlySubscriptionProductID {
            // Handle subscription transactions
            print("Subscription was purchased.")
        } else if transaction.productID == self.individualPredictionProductID {
            // Handle individual prediction transactions
            print("Individual prediction was purchased.")
            print("Calling onSinglePredictionPurchased closure.")
            onSinglePredictionPurchased?()
        }
    }
}





    







