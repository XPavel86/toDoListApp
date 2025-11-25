//
//  TaskListViewModel.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

/*
// TaskListViewModel.swift
import Foundation

class TaskListViewModel {
    
    private var tasks: [Task] = []
    // Новый массив для отфильтрованных задач
    private var filteredTasks: [Task] = []
    
    var onDataUpdated: (() -> Void)?
    
    // Свойство, которое определяет, идет ли сейчас поиск
    var isSearching: Bool {
        // Простой способ проверки: если фильтрованный массив не пустой
        // или если мы находимся в режиме поиска (можно добавить флаг, но для начала сойдет)
        // Более надежный способ - добавить отдельный булев флаг `isSearchActive`
        return !filteredTasks.isEmpty || (searchText?.isEmpty == false)
    }
    
    // Добавим свойство для хранения текущего поискового запроса
    private var searchText: String?

    func fetchTasks() {
        self.tasks = CoreDataService.shared.fetchTasks()
        // При загрузке новых данных сбрасываем фильтр
        self.filteredTasks = []
        self.searchText = nil
        onDataUpdated?()
    }
    
    // MARK: - Search Logic
      
      /// Фильтрует задачи по текстовому запросу
      func filterTasks(with searchText: String) {
          self.searchText = searchText
          
          if searchText.isEmpty {
              // Если запрос пустой, скрываем результаты поиска
              self.filteredTasks = []
          } else {
              // Иначе фильтруем основной массив
              self.filteredTasks = tasks.filter { task in
                  // Ищем в названии (case-insensitive)
                  task.title.lowercased().contains(searchText.lowercased())
              }
          }
          
          // Уведомляем View об изменении
          onDataUpdated?()
      }
      
      /// Сбрасывает результаты поиска
      func clearSearch() {
          self.filteredTasks = []
          self.searchText = nil
          onDataUpdated?()
      }
      
      // MARK: - Helpers for View (Обновляем эти методы)
      
      func numberOfRowsInSection() -> Int {
          // Если ищем, возвращаем количество отфильтрованных, иначе - общее
          return isSearching ? filteredTasks.count : tasks.count
      }
      
      func task(at indexPath: IndexPath) -> Task {
          // Если ищем, берем из отфильтрованного массива, иначе - из основного
          return isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
      }
    
    // Метод для изменения статуса задачи
    func toggleTaskCompletion(for taskId: UUID) {
        CoreDataService.shared.toggleTaskCompletion(for: taskId) { [weak self] in
            // После обновления в базе, перезагружаем данные
            self?.fetchTasks()
        }
    }
    
    // MARK: - Helpers for View
    
    func numberOfRowsInSection() -> Int {
        return tasks.count
    }
    
    func task(at indexPath: IndexPath) -> Task {
        return tasks[indexPath.row]
    }
    
    func deleteTask(for taskId: UUID) {
        CoreDataService.shared.deleteTask(for: taskId) { [weak self] in
            // После удаления из базы, перезагружаем данные
            self?.fetchTasks()
        }
    }
}

    */

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
