import SwiftUI;

struct ToDoEntry : Codable, Equatable, Identifiable{
    var id: UUID = UUID();
    var todo: String;
    var active: Bool = true;
    var completed: Bool = false;
}

class ToDoList : Codable, Equatable, ObservableObject {
    @Published var lst: [ToDoEntry] {
        didSet {
            self.onUpdate(self);
        }
    }
    var onUpdate: (_: ToDoList) -> Void = {val in };
    
    init(lst: [ToDoEntry], onUpdate: (@escaping (ToDoList) -> Void) = {val in }) {
        self.lst = lst;
        self.onUpdate = onUpdate;
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
        onUpdate = {val in }
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
    
    static func saveToDo(todo: ToDoList) {
        if let encoded = try? JSONEncoder().encode(todo) {
            UserDefaults.standard.set(encoded, forKey: "todo-list")
        }
    }
    
    static func getToDo(onUpdate: @escaping (ToDoList) -> Void = {val in }) -> ToDoList {
        let data = UserDefaults.standard.data(forKey: "todo-list")
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(ToDoList.self, from: liveData) {
                decoded.onUpdate = onUpdate;
                return decoded;
            }
            print("Incorrect Data Type (todo list), got \(liveData)")
            let defaultList = ToDoList(lst: [], onUpdate: onUpdate);
            return defaultList;
        } else {
            let defaultList =  ToDoList(lst: [], onUpdate: onUpdate);
            saveToDo(todo: defaultList)
            return defaultList;
        }
    }
}
