
import Foundation

@globalActor
actor MyGlobalActor: GlobalActor {
    
    static let shared = MyGlobalActor()
    
    // MARK: To implement serial executor
    private static let executor = GlobalActorSerialExecutor()
    static let sharedUnownedExecutor: UnownedSerialExecutor = MyGlobalActor.executor.asUnownedSerialExecutor()
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.sharedUnownedExecutor
    }
}

final class GlobalActorSerialExecutor: SerialExecutor {
    private let queue = DispatchQueue(label: "MyGlobalActorQueue")
    
    func enqueue(_ job: UnownedJob) {
        queue.async {
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }
    
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        return UnownedSerialExecutor(ordinary: self)
    }
}

@MyGlobalActor
class DataManager {
    
    @MainActor @Published var data: Int = 0
    
    func fetchData() async {
        let currentData = await data
        
        // Executing on MyGlobalActor
        print(currentData)
        print("Fetching data on MyGlobalActor.")
        
        await setData(value: 22)
    }
    
    @MainActor private func setData(value: Int) {
        data = value
    }
}
