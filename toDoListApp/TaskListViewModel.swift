//
//  TaskListViewModel.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// TaskListViewModel.swift
import Foundation

class TaskListViewModel {
    
    // Массив задач. Приватный, чтобы доступ к нему был только через ViewModel.
    private var tasks: [Task] = []
    
    // Замыкание, которое будет вызываться для обновления UI.
    // View (ViewController) подпишется на него.
    var onDataUpdated: (() -> Void)?
    
    // Загружает задачи из Core Data и уведомляет View.
    func fetchTasks() {
        // Пока что для простоты делаем это в главном потоке.
        // CoreDataService.shared.fetchTasks() и так быстрая операция.
        self.tasks = CoreDataService.shared.fetchTasks()
        // Уведомляем View, что данные изменились.
        onDataUpdated?()
    }
    
    // MARK: - Helpers for View
    
    func numberOfRowsInSection() -> Int {
        return tasks.count
    }
    
    func task(at indexPath: IndexPath) -> Task {
        return tasks[indexPath.row]
    }
}
