import SwiftUI
import StoreKit

struct IAPView: View {
    @EnvironmentObject var iapManager: IAPManager
    @Binding var isShowingIAPView: Bool  
    let monthlySubscriptionID = "unlimited_predictions_monthly"

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

            Text(NSLocalizedString("Get Unlimited Predictions!", comment: ""))
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: Color.black, radius: 10, x: 0, y: 0)
                .shadow(color: .black, radius: 10)
                .offset(y: -290)
                .multilineTextAlignment(.center)
                .zIndex(1)
            
            VStack {
                Spacer()

                if let annualSubscription = iapManager.annualSubscription {
                    ProductView(product: annualSubscription, action: {
                        iapManager.buyProduct(annualSubscription)
                    }, shake: false)
                }

                if let monthlySubscription = iapManager.monthlySubscription {
                    ProductView(product: monthlySubscription, action: {
                        iapManager.buyProduct(monthlySubscription)
                    }, shake: monthlySubscription.productIdentifier == monthlySubscriptionID)
                }

                if let individualPrediction = iapManager.individualPrediction {
                    ProductView(product: individualPrediction, action: {
                        iapManager.buyProduct(individualPrediction)
                    }, shake: false)
                }
            }
            .padding(.bottom)
            .padding(.bottom)
            .onAppear {
                iapManager.fetchProducts()
            }
            .onDisappear {
                isShowingIAPView = false
            }
        }
    }
}

struct ProductView: View {
    let product: SKProduct
    let action: () -> Void
    let shake: Bool
    @State private var shakeEffect = false

    var body: some View {
        Button(action: action) {
            Text("Buy \(product.localizedTitle) for \(product.priceFormatter())")
                .font(.title2)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 5)
                .padding()
                .frame(width: 370)
                .background(LinearGradient(gradient: Gradient(colors: [ Color(red: 50/255, green: 6/255, blue: 71/255).opacity(0.7),
                    Color(red: 150/255, green: 15/255, blue: 255/255).opacity(0.7),
                    Color(red: 148/255, green: 62/255, blue: 244/255).opacity(0.7),
                    Color(red: 150/255, green: 15/255, blue: 255/255).opacity(0.7),
                    Color(red: 50/255, green: 6/255, blue: 71/255).opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
)
                .cornerRadius(60)
                .shadow(color: .purple, radius: 15)
                .modifier(Shake(animatableData: shake && shakeEffect ? CGFloat(0) : CGFloat(1)))
        }
        .padding(.bottom)
        .onAppear() {
            if shake {
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                    withAnimation(.default) {
                        self.shakeEffect.toggle()
                    }
                }
            }
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 5
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
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


