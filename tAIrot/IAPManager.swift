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
    let annualSubscriptionProductID = "unlimited_predictions_lifetime"
    let monthlySubscriptionProductID = "unlimited_predictions_monthly"
    let individualPredictionProductID = "single_prediction"

    @Published var annualSubscription: SKProduct?
    @Published var monthlySubscription: SKProduct?
    @Published var individualPrediction: SKProduct?
    @Published var purchaseEvents = PassthroughSubject<String, Never>()

    private var transactionListener: Task<Void, Never>?
    private let storeObserver = StoreObserver()
    
    var onSinglePredictionPurchased: (() -> Void)?

    override init() {
        super.init()
        SKPaymentQueue.default().add(storeObserver)
        startListeningForTransactions()
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
    func startListeningForTransactions() {
        transactionListener = Task {
            for await result in Transaction.updates {
                switch result {
                case .unverified(_, let error):
                    // The local transaction verification failed, you should log or handle the error
                    print("Failed to verify transaction: \(error)")
                    print("Transaction type: unverified")
                case .verified(let transaction):
                    // The transaction was verified, you can now check the product id
                    print("Transaction type: verified")
                    handleTransaction(transaction)
                }
            }
        }
    }

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


    








