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
            
            VStack(spacing: 24) {
                // Header with image and message
                HStack(spacing: 16) {
                    Image(uiImage: FormattedImages.Image166)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, height: 200)
                    
                    VStack {
                        Text("Want to get started? Buy me a bubble tea.")
                            .font(FontTokens.architectsDaughter(size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(ColorTokens.shade100)
                            .multilineTextAlignment(.leading)
                        
                        Text("you're not gonna sacrifice your gpa for tapioca... right?")
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(ColorTokens.shade200)
                            .multilineTextAlignment(.leading)
                    }
                }
                .layoutPriority(-1)
                
                // Subscription options in rounded rectangle
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        // Header with reload button
                            HStack {
                                Spacer()
                                if subscriptionManager.productsLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                        .foregroundColor(ColorTokens.shade600)
                                        .padding(.trailing, 16)
                                        .padding(.top, 16)
                                } else {
                                    Button(action: {
                                        Task {
                                            await subscriptionManager.restorePurchases()
                                        }
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.title2)
                                            .foregroundColor(ColorTokens.shade600)
                                    }
                                    .padding(.trailing, 16)
                                    .padding(.top, 16)
                                }
                            }
                        
                        // Subscription options
                        VStack(spacing: 12) {
                            if subscriptionManager.isLoading {
                                ProgressView("Loading subscription options...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .foregroundColor(ColorTokens.shade600)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(subscriptionManager.availableProducts, id: \.id) { product in
                                    SubscriptionOptionCard(
                                        product: product,
                                        isSelected: selectedProduct?.id == product.id,
                                        isCurrentSubscription: subscriptionManager.currentSubscription?.id == product.id
                                    ) {
                                        withAnimation {
                                            selectedProduct = product
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if let selectedProduct = selectedProduct {
                            Button(action: {
                                Task {
                                    await subscriptionManager.purchase(selectedProduct)
                                }
                            }) {
                                HStack {
                                    if subscriptionManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Subscribe Now")
                                            .font(FontTokens.architectsDaughter(size: 24))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(ColorTokens.red300)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding()
                            .disabled(subscriptionManager.isLoading)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorTokens.brown500)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 4)
                        )
                )
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

struct SubscriptionOptionCard: View {
    let product: Product
    let isSelected: Bool
    let isCurrentSubscription: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? ColorTokens.red300 : ColorTokens.shade300, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(ColorTokens.red300)
                            .frame(width: 12, height: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(FontTokens.architectsDaughter(size: 18))
                            .foregroundColor(ColorTokens.shade700)
                        
                        if isCurrentSubscription {
                            Text("CURRENT")
                                .font(FontTokens.architectsDaughter(size: 18))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(ColorTokens.red300)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                    
                    Text(product.description)
                        .font(FontTokens.architectsDaughter(size: 16))
                        .foregroundColor(ColorTokens.shade600)
                        .multilineTextAlignment(.leading)
                    
                    Text(product.displayPrice)
                        .font(FontTokens.architectsDaughter(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(ColorTokens.red300)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ColorTokens.red300 : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCurrentSubscription)
    }
}

struct SubscriptionPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionPurchaseView()
            .environmentObject(SubscriptionManager())
            .environmentObject(AppRouter())
    }
}


