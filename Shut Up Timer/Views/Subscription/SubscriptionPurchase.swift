import SwiftUI
import StoreKit

struct SubscriptionPurchaseView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var router: AppRouter
    
    @State private var selectedProduct: Product?
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 22) {
                SubscriptionHeaderCard()
                
                // Subscription options (no container box)
                VStack(spacing: 12) {
                    if subscriptionManager.isLoading {
                        ProgressView("Loading subscription options...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(ColorTokens.shade600)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(subscriptionManager.availableProducts, id: \.id) { product in
                            let isAnnual = product.displayName.lowercased().contains("year") || product.displayName.lowercased().contains("annual")
                            let title = isAnnual ? "Academic Weapon (\(product.displayPrice)/yr)" : "Study Session (\(product.displayPrice)/month)"
                            let subtitle = isAnnual ? "Includes all features, billed annually" : "Includes all features, billed monthly"
                            SubscriptionChoiceButton(
                                title: title,
                                subtitle: subtitle,
                                introOffer: product.subscription?.introductoryOffer,
                                selected: selectedProduct?.id == product.id,
                                onTap: { withAnimation { selectedProduct = product } }
                            )
                        }
                    }
                }
                
                // Action button
                if let selectedProduct = selectedProduct {
                    PopQuizPrimaryButton(title: "Start the Grind!", action: {
                        Task { await subscriptionManager.purchase(selectedProduct) }
                    })
                    .disabled(subscriptionManager.isLoading)
                    .padding(.bottom)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundStyle(ColorTokens.shade100)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        
                        Spacer()
                        Spacer()
                            .frame(maxWidth: 150)
                        Spacer()
                        
                        Link("Privacy Policy", destination: URL(string: "https://www.termsfeed.com/live/697db344-9dd5-430c-9d0d-0df752b8464e")!)
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundStyle(ColorTokens.shade100)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                subscriptionManager.clearError()
            }
        } message: {
            Text(subscriptionManager.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: subscriptionManager.errorMessage) { errorMessage in
            showingError = errorMessage != nil
        }
        .onAppear {
            // Load products if not already loaded
            if subscriptionManager.availableProducts.isEmpty {
                Task {
                    await subscriptionManager.loadProducts()
                }
            }
        }
    }
}

// MARK: - Choice button styled like Pop Quiz buttons with a radio dot
struct SubscriptionChoiceButton: View {
    let title: String
    let subtitle: String?
    let introOffer: Product.SubscriptionOffer?
    let selected: Bool
    let onTap: () -> Void
    
    private let height: CGFloat = 66
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(FontTokens.architectsDaughter(size: 12))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    if let introOffer = introOffer {
                        if introOffer.paymentMode == .freeTrial {
                            Text("INTRO OFFER: Free for \(introOffer.period)")
                                .font(FontTokens.architectsDaughter(size: 12))
                                .foregroundStyle(Color.green)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
                .padding(.vertical, 3)
                
                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(selected ? ColorTokens.red300 : ColorTokens.gray800)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .stroke(.white, lineWidth: 2)
            )
            .shadow(color: .white.opacity(0.8), radius: 3, x: 0, y: 4)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

struct SubscriptionPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionPurchaseView()
            .environmentObject(SubscriptionManager())
            .environmentObject(AppRouter())
    }
}


// MARK: - Custom header that mimics Pop Quiz look (without using PopQuizCard)
struct SubscriptionHeaderCard: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Failure-style banner reused as a container top, but with "Barely Passing"
            
            Group {
                // Lined paper background with slight rotation
                let paper = FormattedImages.Image134
                Image(uiImage: paper)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(2))
            }
            .overlay(
                HStack {
                    Spacer()
                    ZStack(alignment: .top) {
                        Image(uiImage: FormattedImages.Image180)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 7)
                            .offset(y: -8)
                            .allowsHitTesting(false)
                        
                        VStack(spacing: 0) {
                            Text("BARELY")
                                .font(FontTokens.architectsDaughter(size: 15))
                                .foregroundStyle(.white)
                            Text("PASSING")
                                .font(FontTokens.architectsDaughter(size: 34))
                                .foregroundStyle(.white)
                                .padding(.top, -10)
                        }
                        .frame(height: 60, alignment: .top)
                        .padding(.top, 1)
                    }
                    Spacer()
                }
                    .padding(.top, -40),
                alignment: .top
            )
            .overlay(
                // Content: text on left, image with polaroid overlay on right
                VStack {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Swap one boba for")
                                .font(FontTokens.architectsDaughter(size: 18))
                                .foregroundColor(ColorTokens.shade700)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            Text("UNSTOPPABLE")
                                .font(FontTokens.architectsDaughter(size: 44))
                                .foregroundColor(ColorTokens.shade700)
                                .minimumScaleFactor(0.4)
                                .lineLimit(1)
                            Text("productivity.")
                                .font(FontTokens.architectsDaughter(size: 18))
                                .foregroundColor(ColorTokens.shade700)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                            
                            Spacer()
                                .frame(maxHeight: 20)
                            
                            Button(action: {
                                Task {
                                    await subscriptionManager.restorePurchases()
                                }
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 48)
                        
                        Group {
                            Image(uiImage: FormattedImages.Image188)
                                .resizable()
                                .frame(width: 140, height: 230)
                        }
                        .frame(width: 100, height: 160, alignment: .leading)
                        .overlay(
                            // Polaroid overlay with black inner content
                            FormattedImages.PolaroidBG(innerContent: {
                                Color.black
                            }, width: 50)
                            .rotationEffect(Angle(degrees: 12))
                            .offset(x: 20, y: 110)
                            .allowsHitTesting(false),
                            alignment: .topLeading
                        )
                    }
                }
                    .padding(.top, 30)
                    .padding(.bottom, 15)
            )
            .padding(.vertical, 18)
            .padding(.top, 20)
            .padding(.trailing, 24)
        }
    }
}


