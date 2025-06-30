import SwiftUI
import Supabase

class FastAPIClient {
    let fastAPIURL: URL
    let supabase: SupabaseClient;
    
    init(supabase: SupabaseClient) {
        self.fastAPIURL = URL(string: Config.apiBaseURL)!
        self.supabase = supabase
    }
    
    func sendAuthenticatedRequest<T: Encodable>(params: T, url: URL, method: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = try await supabase.auth.session.accessToken
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
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
