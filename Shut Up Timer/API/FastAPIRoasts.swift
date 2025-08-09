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
    
    func sendRoastInformation(_ roastInformation: RoastGenerator.RoastInformation) async throws -> Bool {
        do {
            let _ = try await sendAuthenticatedRequest(
                params: roastInformation,
                url: fastAPIURL.appendingPathComponent("receive-roast-data"),
                method: "POST"
            )
            
            print("Successfully sent roast information to backend")
            return true
        } catch {
            print("Error sending roast information: \(error)")
            return false
        }
    }
    
    struct GenerateBeckonMessagesResponse: Decodable {
        let roasts: [String]
        let title: String
    }
    
    func generateBeckonMessages(roastFeatures: RoastGenerator.RoastFeatures) async throws -> (messages: [String], title: String)? {
        do {
            guard await subscriptionManager.originalTransactionId != nil else {
                print("Cannot generate beckon messages, no subscription")
                return nil
            }
            
            var params: [String: Any] = ["features": roastFeatures.features]
            
            if let recentRoasts = roastFeatures.recentRoasts {
                params["recentRoasts"] = recentRoasts
            }
            
            let data = try await sendAuthSubRequest(
                params: params,
                url: fastAPIURL.appendingPathComponent("generate-beckon-messages"),
                method: "POST"
            )
            
            print("beckon messages response: \(data)")
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(GenerateBeckonMessagesResponse.self, from: data)
            return (messages: response.roasts, title: response.title)
        } catch {
            print("Error generating beckon messages: \(error)")
            return nil
        }
    }
}
