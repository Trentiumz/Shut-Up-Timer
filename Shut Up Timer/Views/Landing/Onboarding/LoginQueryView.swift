import SwiftUI;

enum LoginQuerySelection {
    case study;
    case login;
}

struct LoginQueryPoster : View{
    var body : some View {
        ZStack(alignment: .top) {
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 380, height: 300)
                    .background(
                        ImageAssets.onboardingHello68Big
                            .resizable()
                            .frame(width: 400, height: 400)
                            .offset(x: 0, y: -80),
                        alignment: .top
                    )
                VStack {
                    Text("Shut Up Timer")
                      .font(Font.custom("ArchitectsDaughter-Regular", size: 40))
                      .foregroundColor(ColorTokens.shade700)
                      .frame(width: 270, alignment: .topLeading)
                    Text("Get cooked or get to studying.")
                      .font(Font.custom("ArchitectsDaughter-Regular", size: 18))
                      .multilineTextAlignment(.center)
                      .foregroundColor(ColorTokens.shade700)
                      .frame(width: 261.00003, alignment: .top)
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 195, height: 110)
                      .background(
                        ImageAssets.onboardingHello70
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                          .frame(width: 195, height: 195)
                          .clipped()
                          .offset(y: -50),
                        alignment: .top
                      ).clipped()
                }.offset(x: 20)
            }
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 143, height: 40)
                .background(ColorTokens.shade300)
        }
    }
}

struct LoginQueryView : View {
    var onNext: (LoginQuerySelection) -> Void;
    
    func selectScreen(selection: LoginQuerySelection) {
        onNext(selection);
    }
    
    var body: some View {
        ZStack {
            Background()
            VStack(spacing: 20) {
                Spacer();
                LoginQueryPoster();
                
                Spacer()
                OnboardingNextButton(text: "Study", onSelect: {
                    onNext(.study)
                })
                OnboardingNextButton(text: "Log In", onSelect: {
                    onNext(.login)
                })
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginQueryView(onNext: {val in })
}
