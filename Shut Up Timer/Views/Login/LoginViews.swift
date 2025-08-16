import SwiftUI
import Supabase
import AuthenticationServices

struct LoginView : View {
    enum LoginScreen {
        case general;
        case emailLogin;
        case emailRegister;
    }
    @EnvironmentObject var appRouter : AppRouter;
    @State private var curScreen = LoginScreen.general;
    var onLoggedIn: () -> Void;
    
    func handleLoginSuccess() {
        appRouter.path.removeLast();
        onLoggedIn();
    }
    
    func handleGiveUp() {
        appRouter.path.removeLast();
    }
    
    var body : some View {
        switch(curScreen) {
        case .general:
            GeneralLogin(
                onLoggedIn: handleLoginSuccess,
                emailLoginPressed: { curScreen = .emailLogin; },
                onBack: handleGiveUp)
        case .emailLogin:
            EmailLogin(
                onLoggedIn: handleLoginSuccess, registerButtonPressed: { curScreen = .emailRegister; },
                onBack: {curScreen = .general; })
        case .emailRegister:
            EmailRegister(
                onRegistered: handleLoginSuccess,
                onBack: { curScreen = .emailLogin; })
        }
    }
}

struct FadedBackground : View {
    var body : some View {
        ZStack {
            Background();
            Rectangle()
                .fill(.black)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Handles the "majority" of the login
/// NavigationStack uses LoginQueryScreen, which may (or may not) PUSH an email login on as well!
struct GeneralLogin : View {
    @EnvironmentObject var appRouter: AppRouter;
    @EnvironmentObject var credManager: CredManager;
    var onLoggedIn: () -> Void;
    var emailLoginPressed: () -> Void;
    var onBack: () -> Void;
    @State var errorMessage: String?;
    
    /// Handles Google OAuth login flow
    private func handleGoogleLogin() {
        Task {
            do {
                try await credManager.loginGoogle()
                onLoggedIn()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func handleAppleLogin(result: Result<ASAuthorization, any Error>) {
        Task {
            do {
                try await credManager.loginApple(result: result)
                onLoggedIn()
            } catch {
                errorMessage = "Error Signing in with Apple: \(error.localizedDescription)"
            }
        }
    }
    
    var body : some View {
        ZStack(alignment: .top) {
            FadedBackground()
            
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 400, height: 400)
                    .background(
                        ImageAssets.onboardingHello68
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 465.7317199707031, height: 456)
                            .clipped()
                    )
                Text("Log in now to share with your friends!")
                    .font(Font.custom("ArchitectsDaughter-Regular", size: 25))
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorTokens.shade700)
                    .frame(width: 280, height: 97, alignment: .top)
                    .offset(y: 150)
            }.offset(y: -270)
            
            VStack(spacing: 20) {
                Spacer()
                
                SignInWithAppleButton { request in
                  request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    handleAppleLogin(result: result)
                }
                .signInWithAppleButtonStyle(.white)
                .frame(width: 328, height: 74)
                .cornerRadius(30)
                
                OnboardingNextButton(text: "Sign In with Google", onSelect: handleGoogleLogin)
                OnboardingNextButton(text: "Sign In with Email", onSelect: emailLoginPressed)
                
                // Error messages
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Spacer()
            }
            
            VStack {
                BackButton(onPress: onBack)
                    .padding(.horizontal)
                Spacer();
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SmallLinedPaper : View {
    var body : some View {
        
    }
}

struct FieldLabel : View {
    var text: String;
    
    var body : some View {
        Text(text)
          .font(Font.custom("ArchitectsDaughter-Regular", size: 20))
          .foregroundColor(ColorTokens.shade100)
          .frame(maxWidth: .infinity, maxHeight: 33, alignment: .topLeading)
          .padding(.horizontal)
    }
}

struct FieldTextbox : View {
    var hint: String;
    var secure: Bool;
    @Binding var text: String;
    
    init(_ defaultText: String, _ text: Binding<String>, secure: Bool = false) {
        self.hint = defaultText;
        self._text = text;
        self.secure = secure;
    }
    
    var body : some View {
        ZStack {
            if text.isEmpty {
                Text(hint)
                    .font(Font.custom("ArchitectsDaughter-Regular", size: 20))
                    .foregroundColor(ColorTokens.shade300)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
            }
            
            Group {
                if self.secure {
                    SecureField("", text: _text)
                } else {
                    TextField("", text: _text)
                }
            }
            .textInputAutocapitalization(.never)
            .textFieldStyle(PlainTextFieldStyle())
            .foregroundStyle(ColorTokens.shade100)
            .background(.clear)
            .font(Font.custom("ArchitectsDaughter-Regular", size: 20))
            .padding(20)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .inset(by: 1)
                    .stroke(ColorTokens.shade100, lineWidth: 2)
            )
        }
    }
}

struct SmallLinedHeading : View {
    var text: String;
    var body : some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 400, height: 400)
                .background(
                    ImageAssets.onboardingHello68
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 478.1739196777344, height: 468)
                        .clipped()
                )
            Text(text)
                .font(Font.custom("ArchitectsDaughter-Regular", size: 25))
                .multilineTextAlignment(.center)
                .foregroundColor(ColorTokens.shade700)
                .frame(width: 200, height: 45.12397, alignment: .top)
                .offset(y: -20)
        }.offset(y: -320)
    }
}

/// Handles user login with email/password and Google authentication
/// 
/// This screen provides:
/// - Email and password input fields
/// - Google OAuth login option
/// - Registration navigation
/// - Error handling for invalid credentials and other issues
struct EmailLogin: View {
    /// Authentication and state management
    @EnvironmentObject var credManager: CredManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var showInvalidCredentials: Bool = false
    
    /// Navigation callbacks
    var onLoggedIn: () -> Void
    var registerButtonPressed: () -> Void
    var onBack: () -> Void
    
    /// Handles email/password login with error handling
    private func handleEmailLogin() {
        Task {
            do {
                try await credManager.loginEmail(email: email, password: password)
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
        ZStack(alignment: .top) {
            FadedBackground();
            SmallLinedHeading(text: "Email Login")
            
            VStack(spacing: 20) {
                Spacer();
                if showInvalidCredentials {
                    Text("Invalid email or password")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                VStack (spacing: 0) {
                    FieldLabel(text: "Email Address")
                    FieldTextbox("Enter Email Address", $email);
                }
                
                VStack(spacing: 0) {
                    FieldLabel(text: "Password")
                    FieldTextbox("Enter Password", $password, secure: true)
                }
                
                OnboardingNextButton(text: "Lock In", onSelect: handleEmailLogin)
                
                HStack {
                    Text("Don’t have an account?")
                      .frame(height: 33, alignment: .top)
                    Button(action: registerButtonPressed) {
                        Text("Sign Up")
                          .frame(height: 33, alignment: .top)
                    }
                }
                .font(Font.custom("ArchitectsDaughter-Regular", size: 20))
                .foregroundColor(ColorTokens.shade100)
                
                Spacer()
            }
            .padding(.horizontal, 40)
            
            VStack {
                BackButton(onPress: onBack)
                    .padding(.horizontal)
                Spacer();
            }
        }
    }
}

/// Handles user registration with validation
/// 
/// This screen provides:
/// - Email and password input fields
/// - Registration submission
/// - Login navigation
/// - Error handling for various registration issues
struct EmailRegister: View {
    /// Authentication and state management
    @EnvironmentObject var credManager: CredManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var retypedPassword: String = ""
    @State private var nickname: String = ""
    
    @State private var errorMessage: String? = nil
    @State private var showInvalidEmail: Bool = false
    @State private var showWeakPassword: Bool = false
    @State private var showEmailInUse: Bool = false
    @State private var showUnmatchedPasswords: Bool = false
    
    /// Navigation callbacks
    var onRegistered: () -> Void
    var onBack: () -> Void;
    
    /// Handles registration with validation and error handling
    private func handleRegister() {
        if retypedPassword != password {
            showUnmatchedPasswords = true;
            return;
        }
        Task {
            do {
                try await credManager.register(email: email, password: password)
                if credManager.loggedIn {
                    try await credManager.supabaseClient.rpc("change_username", params: ["new_username": nickname]).execute()
                }
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
        ZStack(alignment: .top) {
            FadedBackground();
            SmallLinedHeading(text: "Sign Up")
            
            VStack(spacing: 20) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50)
                Spacer()
                // Error messages
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if showUnmatchedPasswords {
                    Text("The passwords do not match.")
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
                
                VStack (spacing: 0) {
                    FieldLabel(text: "Email Address")
                    FieldTextbox("Enter Email Address", $email);
                }
                
                VStack (spacing: 0) {
                    FieldLabel(text: "Password")
                    FieldTextbox("Enter Password", $password, secure: true);
                }
                
                VStack (spacing: 0) {
                    FieldLabel(text: "Re-Typed Password")
                    FieldTextbox("Enter Password", $retypedPassword, secure: true);
                }
                
                VStack (spacing: 0) {
                    FieldLabel(text: "Nickname")
                    FieldTextbox("Enter Nickname", $nickname, secure: false);
                }
                
                OnboardingNextButton(text: "Lock In", onSelect: handleRegister)
                Spacer()
                
            }
            .padding()
            
            VStack {
                BackButton(onPress: onBack)
                    .padding(.horizontal)
                Spacer();
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 

#Preview {
    LoginView(onLoggedIn: {})
        .environmentObject(AppRouter())
        .environmentObject(CredManager(subscriptionManager: SubscriptionManager()))
    // EmailLogin(onLoggedIn: {}, registerButtonPressed: {})
    // EmailRegister(onRegistered: {}, onBack: {} )
}
