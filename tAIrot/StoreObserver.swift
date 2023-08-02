import StoreKit

class StoreObserver: NSObject, ObservableObject, SKPaymentTransactionObserver {
    
    @Published var isMonthlySubscriptionActive: Bool = UserDefaults.standard.bool(forKey: "hasMonthlySubscription")
    @Published var isAnnualSubscriptionActive: Bool = UserDefaults.standard.bool(forKey: "hasAnnualSubscription")
    
    @Published var alertMessage: String?
    
    static let shared = StoreObserver()

    private override init() {
        super.init()
        print("Initializing StoreObserver")
    }
        
    // This method is called when there are transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            for transaction in transactions {
                print("Processing transaction: \(transaction)")
                switch transaction.transactionState {
                case .purchasing:
                    // Ignore transactions in the purchasing state.
                    print("Transaction in purchasing state: \(transaction)")
                    continue
                case .purchased:
                    // Unlock the feature or content
                    print("Transaction in purchased state: \(transaction)")
                    handlePurchased(transaction: transaction, queue: queue)
                case .failed:
                    // Log any errors that occurred
                    print("Transaction in failed state: \(transaction), error: \(String(describing: transaction.error))")
                    handleFailed(transaction: transaction, queue: queue)
                case .restored:
                    // Restore the purchased content
                    print("Transaction in restored state: \(transaction)")
                    handleRestored(transaction: transaction, queue: queue)
                case .deferred:
                    // Handle deferred transactions
                    print("Transaction in deferred state: \(transaction)")
                @unknown default:
                    print("Transaction in unknown state: \(transaction.transactionState.rawValue)")
                }
            }
        }

    private func handlePurchased(transaction: SKPaymentTransaction, queue: SKPaymentQueue) {
        
        let iapManager = IAPManager.shared

      if transaction.payment.productIdentifier == "unlimited_predictions_monthly" {
        UserDefaults.standard.set(true, forKey: "hasMonthlySubscription")
          self.isMonthlySubscriptionActive = true
      }
        
      else if transaction.payment.productIdentifier == "unlimited_predictions_lifetime" {
        UserDefaults.standard.set(true, forKey: "hasAnnualSubscription")
          self.isAnnualSubscriptionActive = true
      }
        
      else if transaction.payment.productIdentifier == "single_prediction" {
        // Increment purchased prediction count
        print("Before increment: \(iapManager.purchasedPredictionCount)")
        iapManager.onSinglePredictionPurchased?()
        print("After increment: \(iapManager.purchasedPredictionCount)")
          
        // Save the updated count to UserDefaults
        UserDefaults.standard.set(iapManager.purchasedPredictionCount, forKey: "purchasedPredictionCount")
      }

      else {
        print("Unexpected product identifier: \(transaction.payment.productIdentifier)")
      }

      queue.finishTransaction(transaction)
        
        // Request a review after handling the transaction
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Wait 10 seconds before requesting a review
           if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
               SKStoreReviewController.requestReview(in: scene)
           }
       }
    }
    
    private func handleFailed(transaction: SKPaymentTransaction, queue: SKPaymentQueue) {
        if let error = transaction.error as? SKError {
            switch error.code {
            case .paymentCancelled:
                // Handle payment cancelled error
                print("Transaction cancelled: \(transaction)")
            default:
                // Handle other errors
                print("Transaction failed with error: \(error.localizedDescription)")
                self.alertMessage = NSLocalizedString("transaction_failed_message", comment: "") + " " + error.localizedDescription
            }
        }
        queue.finishTransaction(transaction)
    }

    private func handleRestored(transaction: SKPaymentTransaction, queue: SKPaymentQueue) {
        if transaction.original?.payment.productIdentifier == "unlimited_predictions_monthly" {
            UserDefaults.standard.set(true, forKey: "hasMonthlySubscription")
            self.isMonthlySubscriptionActive = true
            self.alertMessage = NSLocalizedString("monthly_subscription_restored_message", comment: "")
        } else if transaction.original?.payment.productIdentifier == "unlimited_predictions_lifetime" {
            UserDefaults.standard.set(true, forKey: "hasAnnualSubscription")
            self.isAnnualSubscriptionActive = true
            self.alertMessage = NSLocalizedString("annual_subscription_restored_message", comment: "")
        }
        queue.finishTransaction(transaction)
    }
}






