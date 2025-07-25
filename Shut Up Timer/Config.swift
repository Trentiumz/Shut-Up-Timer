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
        return "https://b608cd0e567f.ngrok-free.app"
#else
        return "https://shutuptimer.trentium.ca/"
#endif
    }()
    
    static let supabaseURL: String = {
#if DEBUG
        return "https://0c8e9e89de5e.ngrok-free.app/"
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
}
