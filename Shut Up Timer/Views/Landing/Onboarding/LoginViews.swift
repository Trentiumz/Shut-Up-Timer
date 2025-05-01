import SwiftUI
import Supabase

struct LoginView: View {
    enum LoginState {
        case login
        case register
    }
    
    @EnvironmentObject var appRouter: AppRouter
    @State private var currentState: LoginState = .login
    var onLoggedIn: () -> Void
    
    var body: some View {
        switch currentState {
        case .login:
            LoginScreen(
                onLoggedIn: {
                    appRouter.path.removeLast()
                    onLoggedIn()
                },
                onRegister: {
                    withAnimation {
                        currentState = .register
                    }
                }
            )
        case .register:
            RegisterScreen(
                onRegistered: {
                    appRouter.path.removeLast()
                    onLoggedIn()
                },
                onLogin: {
                    withAnimation {
                        currentState = .login
                    }
                }
            )
        }
    }
}

/// Handles user login with email/password and Google authentication
/// 
/// This screen provides:
/// - Email and password input fields
/// - Google OAuth login option
/// - Registration navigation
/// - Error handling for invalid credentials and other issues
struct LoginScreen: View {
    /// Authentication and state management
    @EnvironmentObject var credManager: CredManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var showInvalidCredentials: Bool = false
    
    /// Navigation callbacks
    var onLoggedIn: () -> Void
    var onRegister: () -> Void
    
    /// Handles Google OAuth login flow
    private func handleGoogleLogin() {
        Task {
            do {
                try await credManager.supabaseClient.auth.signInWithOAuth(
                    provider: .google,
                    redirectTo: URL(string: "shut-up-timer://login-callback")
                )
                onLoggedIn()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Handles email/password login with error handling
    private func handleEmailLogin() {
        Task {
            do {
                try await credManager.supabaseClient.auth.signIn(
                    email: email,
                    password: password
                )
                onLoggedIn()
            } catch {
                if error.localizedDescription.contains("Invalid login credentials") {
                    showInvalidCredentials = true
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 200)
                .cornerRadius(10)
            
            Text("Login")
                .font(.title2)
                .fontWeight(.bold)
            
            // Error messages
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if showInvalidCredentials {
                Text("Invalid email or password")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Input fields
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Action buttons
            OnboardingSelector(text: "Login with Email", onPress: handleEmailLogin)
            OnboardingSelector(text: "Login with Google", onPress: handleGoogleLogin)
            OnboardingSelector(text: "Register", onPress: onRegister)
        }
        .padding()
    }
}

/// Handles user registration with validation
/// 
/// This screen provides:
/// - Email and password input fields
/// - Registration submission
/// - Login navigation
/// - Error handling for various registration issues
struct RegisterScreen: View {
    /// Authentication and state management
    @EnvironmentObject var credManager: CredManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var showInvalidEmail: Bool = false
    @State private var showWeakPassword: Bool = false
    @State private var showEmailInUse: Bool = false
    
    /// Navigation callbacks
    var onRegistered: () -> Void
    var onLogin: () -> Void
    
    /// Handles registration with validation and error handling
    private func handleRegister() {
        Task {
            do {
                try await credManager.supabaseClient.auth.signUp(
                    email: email,
                    password: password
                )
                onRegistered()
            } catch {
                showInvalidEmail = false
                showWeakPassword = false
                showEmailInUse = false
                
                if error.localizedDescription.contains("Invalid email") {
                    showInvalidEmail = true
                } else if error.localizedDescription.contains("Password should be at least") {
                    showWeakPassword = true
                } else if error.localizedDescription.contains("User already registered") {
                    showEmailInUse = true
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 200)
                .cornerRadius(10)
            
            Text("Register")
                .font(.title2)
                .fontWeight(.bold)
            
            // Error messages
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if showInvalidEmail {
                Text("Please enter a valid email address")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if showWeakPassword {
                Text("Password must be at least 6 characters")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if showEmailInUse {
                Text("This email is already registered")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Input fields
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Action buttons
            OnboardingSelector(text: "Register", onPress: handleRegister)
            OnboardingSelector(text: "Back to Login", onPress: onLogin)
        }
        .padding()
    }
} 
