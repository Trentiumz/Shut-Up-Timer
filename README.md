# Shut-Up-Timer
Shut up timer is an iOS app made for people who want a more humorous (and aggressive) approach to studying

### Project Structure
📦 MyApp/
├── Models/
├── ViewModels/
├── Views/
│   └── Landing/

* Models: Holds common & global models for data storage and commonly required items (e.g. todo list, settings, leaderboard entries)
* ViewModels: Holds any large models used for a specific view (e.g. Timer)
* Views: A list of views & Screens
* Landing: The views for the home page
  * AccountView, DisappointmentView, FriendInvite, HomeView, Leaderboard are the 5 options at the home screen
  * TopBarView is a common Topbar for each view
  * Onboarding is a view that is used for first-timer users to select their starting settings
* **AppRoute** is the controller for the entire app, hosting the models used by each view and handling state transitions
* **ContentView** is the app home
