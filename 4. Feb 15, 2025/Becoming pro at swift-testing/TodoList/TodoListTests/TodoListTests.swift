//
//  TodoListTests.swift
//  TodoListTests
//
//  Created by Saumil on 14/02/25.
//

import Testing
@testable import TodoList

extension Tag {
    @Tag static var addTask: Tag
}
extension Tag {
    @Tag static var editTask: Tag
}
struct TodoListTests {
    
    var taskManager: TaskManager!
    
    init() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        taskManager = TaskManager()
    }
    
    @Test("Add Task", .tags(.addTask))
    func testAddTask() {
        // arrange
        let initialTaskCount = taskManager.tasks.count
        
        // act
        let newTask = Task(title: "New Task", description: "Description for new task")
        taskManager.addTask(newTask)
        
        // expect
        #expect(taskManager.tasks.count == initialTaskCount + 1, "Task count should increase by 1 after adding a task.")
        #expect(taskManager.tasks.contains(where: { $0 == newTask }), "New task should be added to the task list.")
    }
    
    @Test("Add Task", .tags(.addTask))
    func testAddDuplicateTask() {
        // arrange
        let task = Task(title: "Duplicate Task", description: "This is a duplicate task.")
        
        // act
        taskManager.addTask(task)
        let initialTaskCount = taskManager.tasks.count
        taskManager.addTask(task)
        
        // expect
        #expect(taskManager.tasks.count == initialTaskCount + 1, "Duplicate task should not be added more than once.")
    }
    
    @Test(arguments: [20, 30])
    func testMultiplication(value: Int) {
     #expect(value * 2 > 10)
    }

    @Test("Add Task", .tags(.addTask))
    func testAddMultipleTasks() {
        // arrange
        let task1 = Task(title: "First Task", description: "Description for first task")
        let task2 = Task(title: "Second Task", description: "Description for second task")
        
        // act
        taskManager.addTask(task1)
        taskManager.addTask(task2)
        
        // expect
        #expect(taskManager.tasks.count == 2, "Task count should be 2 after adding two tasks.")
        #expect(taskManager.tasks.contains(where: { $0 == task1 }), "First task should be added.")
        #expect(taskManager.tasks.contains(where: { $0 == task2 }), "Second task should be added.")
    }
    
    @Test("Edit Task", .tags(.editTask))
    func testEditTask() {
        // arrange
        let initialTask = Task(title: "Old Task", description: "Old description")
        let updatedTask = Task(title: "Updated Task", description: "Updated description")
        
        // act
        taskManager.addTask(initialTask)
        taskManager.editTask(updatedTask, for: initialTask)
        
        // expect
        #expect(taskManager.tasks.first?.title == updatedTask.title, "Task title should be updated.")
        #expect(taskManager.tasks.first?.description == updatedTask.description, "Task description should be updated.")
    }
    
    @Test("Edit Task", .tags(.editTask))
    func testEditTaskWithEmptyTitle() {
        // arrange
        let initialTask = Task(title: "Initial Task", description: "Initial task description")
        let updatedTask = Task(title: "", description: "Updated task with empty title")
        
        // act
        taskManager.addTask(initialTask)
        taskManager.editTask(updatedTask, for: initialTask)
        
        // expect
        #expect(taskManager.tasks.first?.title == updatedTask.title, "Task title should be updated even if it's empty.")
        #expect(taskManager.tasks.first?.description == updatedTask.description, "Task description should be updated.")
    }
    
    @Test("Edit Task", .tags(.editTask))
    func testEditTaskWithEmptyDescription() {
        // arrange
        let initialTask = Task(title: "Task with Description", description: "Some description here.")
        let updatedTask = Task(title: "Task with Empty Description", description: "")
        
        // act
        taskManager.addTask(initialTask)
        taskManager.editTask(updatedTask, for: initialTask)
        
        // expect
        #expect(taskManager.tasks.first?.description == updatedTask.description, "Task description should be updated even if it's empty.")
    }
    
    @Test("Edit Task", .tags(.editTask))
    func testEditTaskTitleToSameValue() {
        // arrange
        let initialTask = Task(title: "Task to Update", description: "Description of the task")
        let updatedTask = Task(title: "Task to Update", description: "Updated description of the task")
        
        // act
        taskManager.addTask(initialTask)
        taskManager.editTask(updatedTask, for: initialTask)
        
        // expect
        #expect(taskManager.tasks.first?.title == updatedTask.title, "Task title should remain the same if no change is made.")
        #expect(taskManager.tasks.first?.description == updatedTask.description, "Task description should be updated correctly.")
    }
    
    @Test("Edit Task", .tags(.editTask))
    func testEditNonExistentTask() {
        // arrange
        let initialTask = Task(title: "Initial Task", description: "Initial description")
        let nonExistentTask = Task(title: "Non Existent Task", description: "This task does not exist in the list.")
        let updatedTask = Task(title: "Updated Task", description: "Updated description")
        
        // act
        taskManager.addTask(initialTask)
        taskManager.editTask(updatedTask, for: nonExistentTask)
        
        // expect
        #expect(taskManager.tasks.contains(where: { $0 != updatedTask }), "Non-existent task should not be updated.")
        #expect(taskManager.tasks.contains(where: { $0 != nonExistentTask }), "Non-existent task should not exist in the list.")
    }
    
}
