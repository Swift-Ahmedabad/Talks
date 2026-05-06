
import SwiftUI

final class TaskExample: ObservableObject, @unchecked Sendable {
    
    private var runningTask: Task<Int, Error>?
    private var cancellables: Set<AnyCancellable> = []
    
    init() async {
        await operation()
    }
    
    func run() {
        // MARK: Task and sub task
        runningTask = Task {
            print("Main Task")
            await operation()
            Task(priority: .background) {
                print("Child task")
            }
            
            if Bool.random() {
                throw NSError(domain: "", code: 0)
            } else {
                return 0
            }
        }
        runningTask?.cancel()
        
        // MARK: Task Priorities
        print(TaskPriority.userInitiated.rawValue)
        print(TaskPriority.high.rawValue)
        print(TaskPriority.medium.rawValue)
        print(TaskPriority.low.rawValue)
        print(TaskPriority.utility.rawValue)
        print(TaskPriority.background.rawValue)
        
        // MARK: Detached Task
        Task.detached { [weak self] in
            for i in 1...10 {
                try Task.checkCancellation()
                print("Working for \(i)")
                await self?.operation()
            }
        }
        .store(in: &cancellables)
    }
    
    func operation() async {
        try? await Task.sleep(for: .seconds(1))
        print("Performing some operation!")
    }
    
    deinit {
        runningTask?.cancel()
        print("Deinit")
    }
}

import Combine

extension Task {
    
    func store(in set: inout Set<AnyCancellable>) {
        set.insert(AnyCancellable(cancel))
    }
}
