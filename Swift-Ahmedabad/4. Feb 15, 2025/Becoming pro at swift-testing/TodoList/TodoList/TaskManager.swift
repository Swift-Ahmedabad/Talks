//
//  TaskManager.swift
//  Swift-Login-Testing
//
//  Created by Saumil Shah on 11/02/25.
//

class Task: Equatable {
    var title: String
    var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.title == rhs.title && lhs.description == rhs.description
    }
}

class TaskManager {
    var tasks: [Task] = []
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func editTask(_ updatedTask: Task, for task: Task) {
        if let index = tasks.firstIndex(where: { $0 === task }) {
            tasks[index] = updatedTask
        }
    }
}
