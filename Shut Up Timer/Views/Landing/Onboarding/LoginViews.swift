import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject var credManager: CredManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    var onLoggedIn: () -> Void
    var onRegister: () -> Void
    
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
    
    private func handleEmailLogin() {
        Task {
            do {
                try await credManager.supabaseClient.auth.signIn(
                    email: email,
                    password: password
                )
                onLoggedIn()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 200)
                .cornerRadius(10)
            
            Text("Login")
                .font(.title2)
                .fontWeight(.bold)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            OnboardingSelector(text: "Login with Email", onPress: handleEmailLogin)
            OnboardingSelector(text: "Login with Google", onPress: handleGoogleLogin)
            OnboardingSelector(text: "Register", onPress: onRegister)
        }
        .padding()
    }
}

struct RegisterView: View {
    @EnvironmentObject var credManager: CredManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    var onRegistered: () -> Void
    var onLogin: () -> Void
    
    private func handleRegister() {
        Task {
            do {
                try await credManager.supabaseClient.auth.signUp(
                    email: email,
                    password: password
                )
                onRegistered()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 200)
                .cornerRadius(10)
            
            Text("Register")
                .font(.title2)
                .fontWeight(.bold)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            OnboardingSelector(text: "Register", onPress: handleRegister)
            OnboardingSelector(text: "Back to Login", onPress: onLogin)
        }
        .padding()
    }
} 
