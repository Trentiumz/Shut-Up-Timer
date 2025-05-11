import SwiftUI;

struct ToDoEntry : Codable, Equatable, Identifiable{
    var id: UUID = UUID();
    var todo: String;
    var active: Bool = true;
}

class ToDoList : Codable, Equatable, ObservableObject {
    @Published var lst: [ToDoEntry];
    
    init(lst: [ToDoEntry]) {
        self.lst = lst;
    }
    
    static func == (l: ToDoList, r: ToDoList) -> Bool {
        return l.lst == r.lst;
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case lst;
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        lst = try container.decode([ToDoEntry].self, forKey: .lst);
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self);
        try container.encode(lst, forKey: .lst);
    }
    
    func uuidToEntry(_ uuid: UUID) -> ToDoEntry? {
        return lst.first { $0.id == uuid }
    }
}

class ToDoLoader {
    private static var defaultList = ToDoList(lst: [])
    
    static func saveToDo(todo: ToDoList) {
        if let encoded = try? JSONEncoder().encode(todo) {
            UserDefaults.standard.set(encoded, forKey: "todo-list")
        }
    }
    static func getToDo() -> ToDoList {
        let data = UserDefaults.standard.data(forKey: "todo-list")
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(ToDoList.self, from: liveData) {
                return decoded;
            }
            print("Incorrect Data Type")
            return defaultList
        } else {
            saveToDo(todo: defaultList)
            return defaultList
        }
    }
}
