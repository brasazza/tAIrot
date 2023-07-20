import SwiftUI
import StoreKit

struct IAPView: View {
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
        ZStack {
            // Background image
            Image("IAPSeer")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
                )

            VStack {
                Spacer()

                if let annualSubscription = iapManager.annualSubscription {
                    ProductView(product: annualSubscription, action: {
                        iapManager.buyProduct(annualSubscription)
                    })
                }

                if let monthlySubscription = iapManager.monthlySubscription {
                    ProductView(product: monthlySubscription, action: {
                        iapManager.buyProduct(monthlySubscription)
                    })
                }

                if let individualPrediction = iapManager.individualPrediction {
                    ProductView(product: individualPrediction, action: {
                        iapManager.buyProduct(individualPrediction)
                    })
                }
            }
            .onAppear {
                iapManager.fetchProducts()
            }
        }
    }
}

struct ProductView: View {
    let product: SKProduct
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Buy \(product.localizedTitle) for \(product.priceFormatter())")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .frame(width: 400)
                .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(60)
        }
        .padding(.bottom, 20) // Add some padding at the bottom
    }
}

extension SKProduct {
    func priceFormatter() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? ""
    }
}

func printTransactions() {
    for transaction in SKPaymentQueue.default().transactions {
        print("Product ID: \(transaction.payment.productIdentifier)")
        print("Transaction state: \(transaction.transactionState.rawValue)")
    }
}

func finishTransactions() {
    for transaction in SKPaymentQueue.default().transactions {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}



