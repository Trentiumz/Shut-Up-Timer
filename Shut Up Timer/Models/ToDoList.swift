import SwiftUI
import Combine

class ToDoLoader {
    
    static func saveToDo(todo: ToDoListV2) {
        if let encoded = try? JSONEncoder().encode(todo) {
            UserDefaults.standard.set(encoded, forKey: "todo-list")
        }
    }
    
    static func getToDoV1() throws -> ToDoListV1 {
        let data = UserDefaults.standard.data(forKey: "todo-list")
        if let liveData = data, let decodedV1 = try? JSONDecoder().decode(ToDoListV1.self, from: liveData) {
            return decodedV1
        } else {
            throw NSError(domain: "ToDoLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode ToDoListV1"])
        }
    }
    
    static func getToDoV2() throws -> ToDoListV2 {
        let data = UserDefaults.standard.data(forKey: "todo-list")
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(ToDoListV2.self, from: liveData) {
                return decoded
            }
            // Try V1 and migrate
            if let decodedV1 = try? getToDoV1() {
                let migrated = ToDoListV2.migrate(fromV1: decodedV1)
                saveToDo(todo: migrated)
                return migrated
            }
            throw NSError(domain: "ToDoLoader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode ToDoListV2 and migrate from V1"])
        } else {
            throw NSError(domain: "ToDoLoader", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data found for todo-list"])
        }
    }
    
    static func getToDo() -> ToDoListV2 {
        do {
            return try getToDoV2()
        } catch {
            print("Error in loading todo list \(error)")
            let defaultList = ToDoListV2(activeLst: [])
            saveToDo(todo: defaultList)
            return defaultList
        }
    }
}

class ToDoEntryV2: ObservableObject, Codable, Equatable, Identifiable, Hashable {
    @Published var id: UUID {
        didSet {
            didChange.send(self)
        }
    }
    @Published var todo: String {
        didSet {
            didChange.send(self)
        }
    }
    @Published var completed: Bool {
        didSet {
            didChange.send(self)
        }
    }
    
    let didChange = PassthroughSubject<ToDoEntryV2, Never>()
    
    init(id: UUID = UUID(), todo: String, completed: Bool = false) {
        self.id = id
        self.todo = todo
        self.completed = completed
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case todo
        case completed
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        todo = try container.decode(String.self, forKey: .todo)
        completed = try container.decode(Bool.self, forKey: .completed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(todo, forKey: .todo)
        try container.encode(completed, forKey: .completed)
    }
    
    // MARK: - Equatable
    static func == (lhs: ToDoEntryV2, rhs: ToDoEntryV2) -> Bool {
        return lhs.id == rhs.id && lhs.todo == rhs.todo && lhs.completed == rhs.completed
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class ToDoListV2: ObservableObject, Codable, Equatable {
    @Published var activeLst: [ToDoEntryV2] {
        didSet {
            didChange.send(self)
        }
    }
    @Published var inactiveLst: [ToDoEntryV2] {
        didSet {
            didChange.send(self)
        }
    }
    
    let didChange = PassthroughSubject<ToDoListV2, Never>()
    var cancellables = Set<AnyCancellable>()
    
    init(activeLst: [ToDoEntryV2], inactiveLst: [ToDoEntryV2] = []) {
        self.activeLst = activeLst
        self.inactiveLst = inactiveLst
    }
    
    static func == (l: ToDoListV2, r: ToDoListV2) -> Bool {
        return l.activeLst == r.activeLst && l.inactiveLst == r.inactiveLst
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case activeLst
        case inactiveLst
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activeLst = try container.decode([ToDoEntryV2].self, forKey: .activeLst)
        inactiveLst = try container.decode([ToDoEntryV2].self, forKey: .inactiveLst)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activeLst, forKey: .activeLst)
        try container.encode(inactiveLst, forKey: .inactiveLst)
    }
    
    func removeTask(entry: ToDoEntryV2) {
        let ind = activeLst.firstIndex(of: entry)
        if let ind = ind {
            inactiveLst.append(activeLst[ind])
            activeLst.remove(at: ind)
        } else {
            print("Failed to remove entry \(entry)")
        }
    }
    
    func removeTask(id: UUID) {
        let ind = activeLst.firstIndex { $0.id == id }
        if let ind = ind {
            inactiveLst.append(activeLst[ind])
            activeLst.remove(at: ind)
        } else {
            print("Failed to remove entry with id \(id)")
        }
    }
    
    func uuidToEntry(_ uuid: UUID) -> ToDoEntryV2? {
        return activeLst.first { $0.id == uuid } ?? inactiveLst.first {$0.id == uuid }
    }

    static func migrate(fromV1 v1: ToDoListV1) -> ToDoListV2 {
        let active = v1.lst.filter { $0.active }.map { ToDoEntryV2(id: $0.id, todo: $0.todo, completed: $0.completed) }
        let inactive = v1.lst.filter { !$0.active }.map { ToDoEntryV2(id: $0.id, todo: $0.todo, completed: $0.completed) }
        return ToDoListV2(activeLst: active, inactiveLst: inactive)
    }
}

struct ToDoEntryV1 : Codable, Equatable, Identifiable{
    var id: UUID = UUID();
    var todo: String;
    var active: Bool = true;
    var completed: Bool = false;
}

class ToDoListV1: ObservableObject, Codable, Equatable {
    @Published var lst: [ToDoEntryV1] {
        didSet {
            didChange.send(self)
        }
    }
    let didChange = PassthroughSubject<ToDoListV1, Never>()
    
    init(lst: [ToDoEntryV1]) {
        self.lst = lst
    }
    
    static func == (l: ToDoListV1, r: ToDoListV1) -> Bool {
        return l.lst == r.lst
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case lst
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lst = try container.decode([ToDoEntryV1].self, forKey: .lst)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lst, forKey: .lst)
    }
    
    func uuidToEntry(_ uuid: UUID) -> ToDoEntryV1? {
        return lst.first { $0.id == uuid }
    }
}
