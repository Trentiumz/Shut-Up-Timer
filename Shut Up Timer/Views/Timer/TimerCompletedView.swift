import SwiftUI

struct TimerCompletedView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var todoList: ToDoListV2
    private var session: SessionEntry;
    
    init(session: SessionEntry) {
        self.session = session;
    }
    
    private var iqChangeString: String {
        let iqChange = session.iqChange;
        if iqChange >= 0 {
            return String(format: "IQ\n+%.2f", iqChange)
        } else {
            return String(format: "IQ\n%.2f", iqChange)
        }
    }
    private var timeLockedString: String {
        let timeLocked = session.timeLocked;
        return String(format: "Time\n%.2f H", timeLocked / 3600)
    }
    private var topCategoriesString: String {
        let topCategories = Array(session.sortedCategories.prefix(2))
        let categoryStrings = topCategories.map { todoList.uuidToEntry($0.todoID)?.todo ?? "Unknown" }.joined(separator: "\n")
        return "Categories\n\(categoryStrings)"
    }
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Spacer()
                    .frame(maxHeight: 30)
                Text("Not too Bad.")
                    .font(FontTokens.architectsDaughter(size: 50))
                    .foregroundColor(ColorTokens.shade100)
                    .frame(width: 328, height: 47, alignment: .topLeading)
                Spacer()
                    .frame(maxHeight: 50)
                
                FormattedImages.AnimatedMadMother(width: 300)
                
                Spacer()
                    .frame(maxHeight: 50)
                
                HStack {
                    InfoBox(iqChangeString)
                    InfoBox(timeLockedString)
                    InfoBox(topCategoriesString)
                }
                
                Spacer()
                OnboardingNextButton(text: "Keep Roasting", onSelect: { router.toHome() })
                
                Spacer()
                    .frame(maxHeight: 50)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Full-screen view
            .background(.black.opacity(0.1))
        }
    }
    
    struct InfoBox : View {
        private var text: String;
        init(_ text: String) {
            self.text = text;
        }
        
        var body : some View {
            ZStack(alignment: .bottom) {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 114, height: 120)
                  .background(Color(red: 0.51, green: 0.16, blue: 0.17))
                  .cornerRadius(20)
                  .overlay(
                    RoundedRectangle(cornerRadius: 20)
                      .inset(by: 1)
                      .stroke(.black, lineWidth: 2)
                  )
                
                ZStack {
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 100, height: 80)
                      .background(.white)
                      .cornerRadius(20)
                      .overlay(
                        RoundedRectangle(cornerRadius: 20)
                          .inset(by: 1)
                          .stroke(.black, lineWidth: 2)
                      )
                    Text(text)
                        .font(FontTokens.architectsDaughter(size: 25))
                        .multilineTextAlignment(.center)
                        .lineSpacing(0)
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.5)
                        .frame(width: 80, height: 80)
                }.padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    TimerCompletedView(session: SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 0, plannedTime: 0, success: true))
}
