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
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            print("API Error: \(response)")
            throw APIError.serverError
        }
        
        return data
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
}

enum APIError: Error, LocalizedError {
    case networkError
    case decodingError
    case serverError
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .decodingError:
            return "Failed to decode response"
        case .serverError:
            return "Server error"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}
