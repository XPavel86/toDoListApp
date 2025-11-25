//
//  TaskListViewModel.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// TaskListViewModel.swift
import Foundation

class TaskListViewModel {
    
    // MARK: - Properties
    private var tasks: [Task] = []
    private var filteredTasks: [Task] = []
    
    var onDataUpdated: (() -> Void)?
    
    private var searchText: String?

    // MARK: - Data Loading
    func fetchTasks() {
        loadTasksFromCoreData()
        clearSearch() // При первой загрузке поиск должен быть сброшен
    }
    
    public func refreshTasks() {
        loadTasksFromCoreData()
        reapplyCurrentFilter() // Переприменяем фильтр к новым данным
        onDataUpdated?()
    }
    
    // MARK: - Search Logic
    func filterTasks(with searchText: String) {
        self.searchText = searchText
        
        if searchText.isEmpty {
            self.filteredTasks = []
        } else {
            self.filteredTasks = tasks.filter { task in
                // Ищем и в названии, и в описании (case-insensitive)
                let titleMatch = task.title.lowercased().contains(searchText.lowercased())
                let descriptionMatch = task.taskDescription.lowercased().contains(searchText.lowercased())
                return titleMatch || descriptionMatch
            }
        }
        
        onDataUpdated?()
    }
    
    func clearSearch() {
        self.filteredTasks = []
        self.searchText = nil
        onDataUpdated?()
    }
    
    // MARK: - CRUD Actions
    func toggleTaskCompletion(for taskId: UUID) {
        CoreDataService.shared.toggleTaskCompletion(for: taskId) { [weak self] in
            // Используем refreshTasks, чтобы не сбивать поиск
            self?.refreshTasks()
        }
    }
    
    func deleteTask(for taskId: UUID) {
        CoreDataService.shared.deleteTask(for: taskId) { [weak self] in
            // И здесь тоже
            self?.refreshTasks()
        }
    }
    
    private func loadTasksFromCoreData() {
        self.tasks = CoreDataService.shared.fetchTasks()
    }
    
    private func reapplyCurrentFilter() {
        guard let searchText = self.searchText, !searchText.isEmpty else {
            self.filteredTasks = []
            return
        }
        
        self.filteredTasks = tasks.filter { task in
            let titleMatch = task.title.lowercased().contains(searchText.lowercased())
            let descriptionMatch = task.taskDescription.lowercased().contains(searchText.lowercased())
            return titleMatch || descriptionMatch
        }
    }
    
    var taskCountString: String {
        let count = isSearching ? filteredTasks.count : tasks.count
        let ending = count % 10 == 1 && count % 100 != 11 ? "Задача" : (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20) ? "Задачи" : "Задач")
        return "\(count) \(ending)"
    }
    
    // MARK: - Helpers for View
    private var isSearching: Bool {
        return !filteredTasks.isEmpty || (searchText?.isEmpty == false)
    }
    
    func numberOfRowsInSection() -> Int {
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    func task(at indexPath: IndexPath) -> Task {
        return isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
    }
}
