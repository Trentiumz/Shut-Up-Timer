import SwiftUI;
// TODO: Fix the other questions
// - Bottom Selector go next button should be further up, and there should be a space between the options, similar to Q3
// - Slide to the right instead of left
// - Smoother transition
// - Back button doesn't work :(
// - Fix dimensions so it works on iphone x

struct SelectorList : View {
    let options: [(String, String, String)];
    let nextText: String;
    let onSelect: (String) -> Void;
    @State var selectedOption: String = "none";
    
    var body : some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.0) { (option, text, selectedText) in
                OnboardingSelector(
                    text: text,
                    selectedText: selectedText,
                    isSelected: selectedOption == option,
                    onSelect: {
                        selectedOption = option
                    })
            }
            Spacer()
            OnboardingNextButton(text: nextText, onSelect: {
                if options.contains(where: { elem in
                    elem.0 == selectedOption;
                }) {
                    onSelect(selectedOption);
                }
            })
            Spacer()
                .frame(maxHeight: 40)
        }
    }
}

struct OnboardingQ1: View {
    let onPress: (String) -> Void
    let onPrevious: () -> Void
    
    private let options = [
        ("1-3 hours", "1-3 hours", "Okay, you still have hope."),
        ("4-6 hours", "4-6 hours", "So mid."),
        ("7-9 hours", "7-9 hours", "Are you... proud of that?"),
        ("10+ hours", "10+ hours", "We're judging. So is your mom")]
    private let doneText = "I'm done."
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                BackButton(onPress: onPrevious);
                Spacer()
                LinedPaper(text: "Be honest with me... What's your daily screen time?", iconAlignment: .bottomTrailing, imageHeight: 280)
                    .offset(y: -10)
                Rectangle().fill(.clear).frame(height: 40)
                Spacer()
                SelectorList(options: options, nextText: doneText, onSelect: onPress)
                Spacer()
            }
        }
        .background(ColorTokens.shade300)
    }
}

struct OnboardingQ2: View {
    let onPress: (String) -> Void
    let onPrevious: () -> Void
    
    private let options = [
        ("friends", "Friends", "Friends"),
        ("Social Media", "Social Media", "Social Media"),
        ("App Store", "App Store", "App Store"),
        ("Other", "Other", "Other")]
    private let doneText = "Hurry, lah!"
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                BackButton(onPress: onPrevious);
                Spacer()
                LinedPaper(text: "How did you hear about this app?", iconAlignment: .bottomTrailing, imageHeight: 280)
                    .offset(y: -10)
                Rectangle().fill(.clear).frame(height: 40)
                Spacer()
                SelectorList(options: options, nextText: doneText, onSelect: onPress)
            }
        }
        .background(ColorTokens.shade300)
    }
}

struct OnboardingQ3: View {
    let onPress: (String) -> Void
    let onPrevious: () -> Void
    
    private let options = [
        ("low", "Lightly Grilled Mode", "\"Oh, you’re trying your best. Congrats.\""),
        ("med", "Savage Mode", "\"So you opened TikTok again? Good luck explaining that to future-you.\""),
        ("high", "Asian Parent Mode", "\"You study like this and still expect results? Tsk.\"")
        ]
    private let doneText = "Start moving!"
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                BackButton(onPress: onPrevious);
                Spacer()
                LinedPaper(text: "You want motivation? Or humiliation?", iconAlignment: .bottomTrailing, imageHeight: 180)
                    .offset(y: -10)
                Spacer()
                    .frame(maxHeight: 100)
                SelectorList(options: options, nextText: doneText, onSelect: onPress)
            }
        }
        .background(ColorTokens.shade300)
    }
}

struct OnboardingQ4: View {
    let onPress: (String) -> Void
    let onPrevious: () -> Void
    
    private let options = [
        ("easy", "Strict", "Monitors screen + phone checks"),
        ("medium", "Unforgiving", "One swipe and you're done"),
        ("asian", "Asian Household", "Full lockdown. Pray.")
        ]
    private let doneText = "Almost there..."
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                BackButton(onPress: onPrevious);
                Spacer();
                LinedPaper(text: "How hard do you want me to be?", iconAlignment: .bottomTrailing, imageHeight: 280)
                    .offset(y: -10)
                Rectangle().fill(.clear).frame(height: 40)
                Spacer()
                SelectorList(options: options, nextText: doneText, onSelect: onPress)
            }
        }
        .background(ColorTokens.shade300)
    }
}

#Preview {
    OnboardingQ3(onPress: {val in print("Selected \(val)")}, onPrevious: {print("Going previous...")})
}
