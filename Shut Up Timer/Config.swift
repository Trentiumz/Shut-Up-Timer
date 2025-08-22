import Foundation
struct Config {
    enum ConfigType {
        case debug
        case release
    }
    
    static let curConfig: ConfigType = {
#if DEBUG
        return .debug
#else
        return .release
#endif
    }()
    
    
    static let apiBaseURL: String = {
#if DEBUG
        return "https://b679595002c4.ngrok-free.app"
#else
        return "https://shutuptimer.trentium.ca/"
#endif
    }()
    
    static let supabaseURL: String = {
#if DEBUG
        return "https://8f2c57ade7d3.ngrok-free.app"
#else
        return "https://oullomxexthybhywbgpr.supabase.co"
#endif
    }()
    
    static let supabaseANON: String = {
#if DEBUG
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
#else
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91bGxvbXhleHRoeWJoeXdiZ3ByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3NTYwMDYsImV4cCI6MjA2MTMzMjAwNn0.ox6uLdxPQ57WsBACWC2iVhn0akPUWBcQxTTAQ39kwdE"
#endif
    }()
    
    static let useDebugSubscription: Bool = {
#if DEBUG
        return false
#else
        return false
#endif
    }()
    
    static let debugSubscriptionString: String = {
#if DEBUG
        return "shut-up-timer-debug-182739"
#else
        return ""
#endif
    }()
    
    static let catchphraseBufferTime: TimeInterval = {
#if DEBUG
        return 300 // 5 minutes
#else
        return 1800
#endif
    }()
}
