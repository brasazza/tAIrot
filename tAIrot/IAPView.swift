import SwiftUI
import StoreKit

struct IAPView: View {
    @EnvironmentObject var iapManager: IAPManager
    @EnvironmentObject var storeObserver: StoreObserver
    @Binding var isShowingIAPView: Bool
    @State private var isAnimating: Bool = false
    @State private var showingAlert = false

    let monthlySubscriptionID = "unlimited_predictions_monthly"

    var body: some View {
        ZStack {
            // Background image
            Image("wizard test 29")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
                )

            VStack {
                Text(NSLocalizedString("Unlock Unlimited\nPredictions!", comment: ""))
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: Color.black, radius: 10, x: 0, y: 0)
                    .shadow(color: .black, radius: 10)
                    .multilineTextAlignment(.center)
                    .padding(.top, UIScreen.main.bounds.height < 668 ? 100 : 60)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.9 : 1.0)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                    }

                Spacer()

                // "Restore Purchases" button
                Button(action: {
                    impactFeedback()
                    iapManager.restorePurchases()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.white)
                        Text(NSLocalizedString("Restore Purchases", comment: ""))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                    }
                }
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .padding(.bottom, 2)

                VStack {
                    HStack (spacing: 10) {
                        if let annualSubscription = iapManager.annualSubscription {
                            ProductView(product: annualSubscription, action: {
                                iapManager.buyProduct(annualSubscription)
                            }, isPurchased: iapManager.storeObserver.isAnnualSubscriptionActive)
                        }

                        if let monthlySubscription = iapManager.monthlySubscription {
                            ProductView(product: monthlySubscription, action: {
                                iapManager.buyProduct(monthlySubscription)
                            }, isPurchased: iapManager.storeObserver.isMonthlySubscriptionActive)
                        }

                        if let individualPrediction = iapManager.individualPrediction {
                            ProductView(product: individualPrediction, action: {
                                iapManager.buyProduct(individualPrediction)
                            }, isPurchased: false)  // Individual predictions are always purchasable
                        }
                    }
                    .frame(height: 160)  // Set a fixed height for the HStack
            
                    // Terms and Conditions link
                    Link(destination: URL(string: "https://theseer.app/#terms")!) {
                        Text(NSLocalizedString("Terms and Conditions", comment: ""))
                            .font(.headline)
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .padding(.vertical, 0.2)
                    }

                    // Privacy Policy link
                    Link(destination: URL(string: "https://theseer.app/#privacy")!) {
                        Text(NSLocalizedString("Privacy Policy", comment: ""))
                            .font(.headline)
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .padding(.vertical, 0.2)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)  // Make the VStack take up all available horizontal space
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.bottom, 90) // Add bottom padding to the inner VStack
                .onAppear {
                    iapManager.fetchProducts()
                    print("IAPView appeared. alertMessage: \(iapManager.storeObserver.alertMessage ?? "nil")")
                }
                .onDisappear {
                    isShowingIAPView = false
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text(NSLocalizedString("notification_title", comment: "")),
                        message: Text(iapManager.storeObserver.alertMessage ?? ""),
                        dismissButton: .default(Text(NSLocalizedString("ok", comment: "")), action: {
                            iapManager.storeObserver.alertMessage = nil
                        })
                    )
                }
                .onReceive(iapManager.storeObserver.$alertMessage) { newMessage in
                    print("Received new alert message: \(newMessage ?? "nil")")
                    if let newMessage = newMessage,
                       !newMessage.isEmpty,
                       newMessage != NSLocalizedString("ok", comment: ""),
                       newMessage != NSLocalizedString("notification_title", comment: "") {
                        showingAlert = true
                    }
                }
            }
        }
    }
}

    struct ProductView: View {
        let product: SKProduct
        let action: () -> Void
        let isPurchased: Bool
        @State private var monthlyAnimating: Bool = false
        let monthlySubscriptionID = "unlimited_predictions_monthly"

        var body: some View {
            Button(action: {
                if !isPurchased {
                    impactFeedback()
                    action()
                }
            }) {
                VStack {
                    Text(isPurchased ? NSLocalizedString("You have an active subscription!", comment: "") : String(format: NSLocalizedString("Buy %@ for %@", comment: ""), product.localizedTitle, product.priceFormatter()))
                            .font(.headline)
                            .foregroundColor(isPurchased ? .gray : .white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isPurchased ? Color.gray : Color.gray, lineWidth:  isPurchased ? 1 : 1) // Reintroduce the purple stroke
                    .shadow(color: Color.white.opacity(0.5), radius: 5, x: -5, y: -5) // Light shadow
                    .shadow(color: Color.black.opacity(0.99), radius: 5, x: 5, y: 5) // Dark shadow
            )
            .aspectRatio(3/4 , contentMode: .fit)
            .cornerRadius(10)
            .modifier(Shake(animatableData: monthlyAnimating ? CGFloat.pi * 2 * 5 : 0)) // Shake effect
            .onAppear {
                if product.productIdentifier == monthlySubscriptionID && !isPurchased {
                    Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
                        withAnimation(Animation.easeInOut(duration: 0.4).repeatCount(4, autoreverses: false)) {
                            monthlyAnimating.toggle()
                        }
                    }
                }
            }
        }
            .frame(width: 120, height: 200)
            .disabled(isPurchased)
            .background(Color.clear)
            .presentationDragIndicator(.visible)
        }
    }


    struct Shake: GeometryEffect {
        var amount: CGFloat = 4
        var shakesPerUnit = 2
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
