import Combine
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentSubscription: Product? = nil
    @Published var originalTransactionId: UInt64? = nil {
        didSet {
            self.transactionIdUpdate.send(originalTransactionId)
        }
    }
    @Published var availableProducts: [Product] = []
    @Published var isLoading: Bool = false
    @Published var productsLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Product Identifiers
    private let monthlyProductId = "monthly_access_1"
    private let yearlyProductId = "yearly_access_1"
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>? = nil
    private var productsLoaded = false
    private var initializationTask: Task<Void, Never>? = nil
    
    let transactionIdUpdate = PassthroughSubject<UInt64?, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        updateListenerTask = listenForTransactions()
        initializationTask = Task {
            isLoading = true
            // Then load products for purchase options
            await loadProducts()
            // Check subscription status first for faster response
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
        cancellables.removeAll()
    }
    
    // MARK: - Public Methods
    
    /// Load available products from the App Store
    func loadProducts() async {
        await MainActor.run {
            self.productsLoading = true
        }
        errorMessage = nil
        
        do {
            let productIds = Set([monthlyProductId, yearlyProductId])
            let products = try await Product.products(for: productIds)
            
            await MainActor.run {
                self.availableProducts = products.sorted { $0.price < $1.price }
                self.productsLoaded = true
                self.productsLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                self.productsLoading = false
            }
        }
    }

    /// Returns the original transaction ID after initial loading completes
    func getTransactionId() async -> UInt64? {
        if let initializationTask {
            _ = await initializationTask.value
        }
        return originalTransactionId
    }
    
    /// Purchase a subscription product
    func purchase(_ product: Product) async -> Bool {
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check whether the transaction is verified
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    // Deliver content to the user
                    self.updateStateForVerifiedTransaction(for: transaction)
                    return true
                    
                case .unverified(_, let error):
                    await MainActor.run {
                        self.errorMessage = "Transaction verification failed: \(error.localizedDescription)"
                    }
                    return false
                }
                
            case .userCancelled:
                return false
                
            case .pending:
                await MainActor.run {
                    self.errorMessage = "Purchase is pending approval"
                }
                return false
                
            @unknown default:
                await MainActor.run {
                    self.errorMessage = "Unknown purchase result"
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Purchase failed: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    /// Check if user is subscribed to any product
    func updateSubscriptionStatus() async {
        isLoading = true
        print("updating subscription status")
        
        // Check for any active subscription
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Check if this is one of our subscription products
                if transaction.productID == monthlyProductId || transaction.productID == yearlyProductId {
                    // Find the corresponding product
                    if let product = availableProducts.first(where: { $0.id == transaction.productID }) {
                        await MainActor.run {
                            print("verified subscription")
                            self.currentSubscription = product
                            self.originalTransactionId = transaction.originalID
                            self.isLoading = false
                        }
                        return
                    }
                }
                
            case .unverified(_, let error):
                print("Transaction verification failed: \(error)")
            }
        }
        
        // No active subscription found
        await MainActor.run {
            print("couldn't find verified subscription")
            self.isLoading = false
        }
    }
    
    /// Restore purchases
    func restorePurchases() async -> Bool {
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await loadProducts()
            await updateSubscriptionStatus()
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // Deliver content to the user
                    await transaction.finish()
                    await self.updateStateForVerifiedTransaction(for: transaction)
                    
                case .unverified(_, let error):
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func updateStateForVerifiedTransaction(for transaction: Transaction) {
        self.currentSubscription = self.availableProducts.first { product in product.id == transaction.productID}
        if self.currentSubscription != nil {
            self.originalTransactionId = transaction.originalID
        }
    }
    
    // MARK: - Helper Methods
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}
