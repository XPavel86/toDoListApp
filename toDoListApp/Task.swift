//
//  Task.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// Task.swift
import Foundation

struct Task: Identifiable {
    let id: UUID
    var title: String
    var taskDescription: String
    let createdDate: Date
    var isCompleted: Bool
    
    // Удобный инициализатор
    init(title: String, taskDescription: String) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.createdDate = Date()
        self.isCompleted = false
    }
    
    // Инициализатор для создания из CoreData объекта
    init(taskEntity: TaskEntity) {
        self.id = taskEntity.id ?? UUID()
        self.title = taskEntity.title ?? ""
        self.taskDescription = taskEntity.taskDescription ?? ""
        self.createdDate = taskEntity.createdDate ?? Date()
        self.isCompleted = taskEntity.isCompleted
    }
}
