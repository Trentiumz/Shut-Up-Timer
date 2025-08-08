import Foundation
import Combine
let roastMessages = [
    "Your brain called. It’s buffering.",
    "You studying or just opening tabs again?",
    "You’ve read the same sentence 4 times. Impressive.",
    "Netflix > GPA, huh?",
    "You studying or just scrolling through regrets?",
    "That textbook’s collecting more dust than data.",
    "This focus session? Sponsored by distractions.",
    "You’ve taken more breaks than breaths.",
    "At this point, your major is procrastination.",
    "Study harder, not barely.",
    "You’re 3 hours behind Daniel. Again.",
    "Bottom of the leaderboard and proud?",
    "Your friend’s IQ just lapped you.",
    "Even your focus score needs a tutor.",
    "You flexing or flopping today?",
    "You're losing to someone watching anime on 2x speed.",
    "Someone else just started working. Wanna catch up?",
    "Others are grinding. You’re... grazing?",
    "Your screen time beat your study time. Yikes.",
    "Your GPA's scared. And so are we.",
    "You're not behind. You're barely even in the race.",
    "Study? You mean scroll and pretend?",
    "You don’t need a tutor. You need an intervention.",
    "Your goals miss you. Call them back.",
    "This timer’s embarrassed to track you.",
    "Your future self is shaking.",
    "Your laptop's more productive in sleep mode.",
    "Motivation left the chat.",
    "You're speedrunning academic disappointment.",
    "Even AI gave up on you.",
    "You’ve been idle longer than your career.",
    "Still on break? You training for hibernation?",
    "Thought this was a focus app, not a nap tracker.",
    "Resting? You barely started.",
    "You’ve done less than a brick wall today.",
    "Your to-do list is aging like wine.",
    "Even your calendar gave up.",
    "You’ve ghosted your goals.",
    "Is this a focus session or a coma?",
    "You’ve accomplished nothing. Consistently.",
    "Scrolling again? Cool. So is your GPA.",
    "TikTok isn’t hiring.",
    "Your phone’s working harder than you.",
    "Instagram won’t help you pass.",
    "You tapped more than you typed today.",
    "Screen time > dream time?",
    "Put the phone down, scholar.",
    "You’re not a content creator. You’re just distracted.",
    "If swiping was a skill, you’d be top of the class.",
    "Your dopamine’s in debt.",
    "You said you’d start at 2. It’s 4.",
    "10-minute break turned 2-hour saga?",
    "Your habits are scared of commitment.",
    "You’re the red flag your calendar warned about.",
    "Missed another session? Consistency who?",
    "If stalling was a sport, you’d medal.",
    "You can't ghost your deadlines forever.",
    "Accountability left the chat.",
    "Time’s moving. You’re not.",
    "You’re avoiding more than just tasks.",
    "So brave of you to do nothing again today.",
    "A true hero. Saving zero progress.",
    "Don’t strain yourself doing the bare minimum.",
    "Rest easy, champ. You've earned...nothing.",
    "The grind chose someone else.",
    "Take a bow. That was peak avoidance.",
    "You’re really showing that desk who's boss.",
    "Wow. Such effort. Much wow.",
    "Inspirational. You almost opened the app.",
    "You’ll get 'em next semester.",
    "Ctrl + Z won’t save this term.",
    "Your GPA is in low power mode.",
    "This isn’t Hogwarts. Try real magic: studying.",
    "Focus spell failed. Try again.",
    "Your brain’s on airplane mode.",
    "You charging your phone more than your brain?",
    "This ain't the multiverse. Do your work.",
    "You skipped the side quest *and* the main one.",
    "That essay isn’t writing itself.",
    "Knowledge loading... still buffering.",
    "Someone else is chasing your dream harder.",
    "You wanted results, not excuses.",
    "You’re not tired. You’re just scared to start.",
    "Small wins > no wins. Start.",
    "You can't wish your way to success.",
    "Nothing changes if you don’t.",
    "Clarity comes from doing.",
    "Want better? Be better.",
    "It’s hard. But so is failing.",
    "You’re either building or breaking momentum.",
    "You study like a potato trying to do taxes.",
    "Your focus is held together by vibes.",
    "Even a goldfish’s attention span is better.",
    "If you studied as much as you scrolled...",
    "This is why aliens won’t talk to us.",
    "Your notes are starting to feel abandoned.",
    "Your last brain cell is on strike.",
    "If your progress was a stock, we’d short it.",
    "Study? You’re starring in “The Office” reruns.",
    "Your timer's been crying."
]

func getRandomRoast() -> String {
    return roastMessages.randomElement() ?? "No roast for you today. Lucky."
}

class RoastInformation: ObservableObject {
    @Published var lastCacheableTime: [RoastGenerator.RoastType:Date] {
        didSet {
            didChange.send(self)
        }
    }
    let didChange = PassthroughSubject<RoastInformation, Never>()
    private static let cacheableKey = "roast-information-cacheable"
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Codable
    private init(lastCacheableTime: [RoastGenerator.RoastType:Date] = [:]) {
        self.lastCacheableTime = lastCacheableTime
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // Loads posts from UserDefaults
    static func loadRoastInformation() -> RoastInformation {
        let data = UserDefaults.standard.data(forKey: RoastInformation.cacheableKey)
        if let data = data {
            if let decoded = try? JSONDecoder().decode([RoastGenerator.RoastType:Date].self, from: data) {
                return RoastInformation(lastCacheableTime: decoded)
            }
        }
        return RoastInformation()
    }
    
    func getLastCacheTime(type: RoastGenerator.RoastType) -> Date {
        return self.lastCacheableTime[type] ?? Date.distantPast
    }
    
    // Private: Save posts to UserDefaults
    func saveRoastInformation() {
        if let encoded = try? JSONEncoder().encode(self.lastCacheableTime) {
            UserDefaults.standard.set(encoded, forKey: RoastInformation.cacheableKey)
        }
    }
}
