enum AppRoute : Hashable{
    case home
    case timer
    case timerCompleted(seconds: Int)
    case timerFailed(seconds: Int)
}
