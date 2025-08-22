import SwiftUI
import Supabase

class FastAPIClient {
    let fastAPIURL: URL
    let supabase: SupabaseClient
    let subscriptionManager: SubscriptionManager
    
    init(supabase: SupabaseClient, subscriptionManager: SubscriptionManager) {
        self.fastAPIURL = URL(string: Config.apiBaseURL)!
        self.supabase = supabase
        self.subscriptionManager = subscriptionManager
    }
    
    func sendAuthenticatedRequest<T: Encodable>(params: T, url: URL, method: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = try await supabase.auth.session.accessToken
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(params)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                return data
            }
        }
        print("API Error: \(response)")
        do {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(description: errorResponse.error)
            }
        }
        throw APIError.serverError(description: "Server Error")
    }
    
    func sendAuthenticatedGetRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let token = try await supabase.auth.session.accessToken
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                return data
            }
        }
        print("API Error: \(response)")
        do {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(description: errorResponse.error)
            }
        }
        throw APIError.serverError(description: "Server Error")
    }
    
    func sendAuthSubRequest(params: [String: Any], url: URL, method: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = try await supabase.auth.session.accessToken
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Add originalTransactionId to params if available
        var requestParams = params
        if let originalTransactionId = await subscriptionManager.getTransactionId() {
            requestParams["originalTransactionId"] = Config.useDebugSubscription ? Config.debugSubscriptionString : "\(originalTransactionId)"
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestParams)
        print(requestParams)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                return data
            }
        }
        print("API Error: \(response)")
        do {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(description: errorResponse.error)
            }
        }
        throw APIError.serverError(description: "Server Error")
    }
    
    struct AddFeedbackParams: Encodable {
        let stars: Int?
        let feedback: String?
    }
    func addFeedback(_ params: AddFeedbackParams) async -> Bool {
        do {
            _ = try await sendAuthenticatedRequest(params: params, url: fastAPIURL.appendingPathComponent("add-feedback"), method: "POST")
            return true;
        } catch {
            print("Error adding feedback: \(error)")
            return false;
        }
    }
    
    struct SendFriendRequestParams: Encodable {
        let receiver_friend_code: String
    }
    func sendFriendRequest(_ params: SendFriendRequestParams) async throws -> Void {
        _ = try await sendAuthenticatedRequest(params: params, url: fastAPIURL.appendingPathComponent("send-friend-request"), method: "POST")
    }
    
    struct VerifySubscriptionResponse: Codable {
        let is_subscribed: Bool
    }
    
    func verifySubscription() async -> Bool {
        do {
            guard await subscriptionManager.getTransactionId() != nil else {
                return false
            }
            
            let data = try await sendAuthSubRequest(
                params: [:],
                url: fastAPIURL.appendingPathComponent("verify-subscription"),
                method: "POST"
            )
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(VerifySubscriptionResponse.self, from: data)
            return response.is_subscribed
        } catch {
            print("Error verifying subscription: \(error)")
            return false
        }
    }
    
    struct LinkSubscriptionResponse: Decodable {
        let success: Bool
    }
    func linkSubscription() async throws -> Bool{
        print("linking subscription...")
        do {
            guard await subscriptionManager.getTransactionId() != nil else {
                print("No subscriptions, cannot link subscriptions")
                return false
            }
            
            let data = try await sendAuthSubRequest(
                params: [:],
                url: fastAPIURL.appendingPathComponent("link-subscription"),
                method: "POST"
            )
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(LinkSubscriptionResponse.self, from: data)
            print("linked subscription: \(response.success)")
            return response.success
        } catch {
            print("Error linking subscription: \(error)")
            return false
        }
    }
}

enum APIError: Error, LocalizedError {
    case networkError
    case decodingError
    case serverError(description: String)
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let description):
            return "\(description)"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}

struct ErrorResponse: Codable {
    let error: String
}
