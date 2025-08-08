import Foundation

extension FastAPIClient {
    fileprivate enum CommentEndpoint: String {
        case roast = "generate-roast"
        case catchphrase = "generate-catchphrase"
    }
    
    struct GenerateCommentResponse: Decodable {
        let roast: String
    }
    
    fileprivate func generateComment(endpoint: CommentEndpoint, roastFeatures: RoastGenerator.RoastFeatures) async throws -> String? {
        do {
            guard await subscriptionManager.originalTransactionId != nil else {
                print("Cannot generate roast, no subscription")
                return nil
            }
            
            var params: [String: Any] = ["features": roastFeatures.features]
            
            if let recentRoasts = roastFeatures.recentRoasts {
                params["recentRoasts"] = recentRoasts
            }
            
            let data = try await sendAuthSubRequest(
                params: params,
                url: fastAPIURL.appendingPathComponent(endpoint.rawValue),
                method: "POST"
            )
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(GenerateCommentResponse.self, from: data)
            return response.roast
        } catch {
            print("Error generating roast: \(error)")
            return nil
        }
    }
    
    func generateRoast(roastFeatures: RoastGenerator.RoastFeatures) async throws -> String? {
        return try await generateComment(endpoint: .roast, roastFeatures: roastFeatures)
    }
    
    func generateCatchphrase(roastFeatures: RoastGenerator.RoastFeatures) async throws -> String? {
        return try await generateComment(endpoint: .catchphrase, roastFeatures: roastFeatures)
    }
}
