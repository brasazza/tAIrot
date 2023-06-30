//
//  IAPManager.swift
//  The Seer
//
//  Created by Brandon Ramírez Casazza on 29/06/23.
//

import Foundation
import StoreKit

class IAPManager: ObservableObject {
    let annualSubscriptionProductID = "unlimited_predictions_lifetime"
    let monthlySubscriptionProductID = "unlimited_predictions_monthly"
    let individualPredictionProductID = "single_prediction"

    @Published var annualSubscription: Product?
    @Published var monthlySubscription: Product?
    @Published var individualPrediction: Product?

    private var transactionListener: Task<Void, Never>?

    init() {
        startListeningForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    func fetchProducts() async throws {
        let productIDs = Set([annualSubscriptionProductID, monthlySubscriptionProductID, individualPredictionProductID])
        let products = try await Product.products(for: productIDs)
        
        for product in products {
            if product.id == annualSubscriptionProductID {
                self.annualSubscription = product
            } else if product.id == monthlySubscriptionProductID {
                self.monthlySubscription = product
            } else if product.id == individualPredictionProductID {
                self.individualPrediction = product
            }
        }
    }

    func buyProduct(_ product: Product) async throws {
        let result = try await product.purchase()
        // Handle the result of purchase here.
    }

    // Start listening for transaction updates
    func startListeningForTransactions() {
        transactionListener = Task {
            for await result in Transaction.updates {
                switch result {
                case .unverified(_, let error):
                    // The local transaction verification failed, you should log or handle the error
                    print("Failed to verify transaction: \(error)")
                case .verified(let transaction):
                    // The transaction was verified, you can now check the product id
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
        }
    }
}




