import SwiftUI;

struct ToDoEntry : Codable, Identifiable{
    var id: UUID = UUID();
    var todo: String;
    var done: Bool;
}

class ToDoList {
    static func saveToDo(lst: [ToDoEntry]) {
        if let encoded = try? JSONEncoder().encode(lst) {
            UserDefaults.standard.set(encoded, forKey: "todo-list")
        }
    }
    static func getToDo() -> [ToDoEntry] {
        let data = UserDefaults.standard.data(forKey: "todo-list")
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode([ToDoEntry].self, from: liveData) {
                return decoded;
            }
            print("Incorrect Data Type")
            return []
        } else {
            saveToDo(lst: [])
            return []
        }
    }
}
