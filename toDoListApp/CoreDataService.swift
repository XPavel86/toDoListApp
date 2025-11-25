//
//  CoreDataService.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// CoreDataService.swift
import Foundation
import CoreData
import UIKit

class CoreDataService: CoreDataServiceProtocol {
    
    static let shared = CoreDataService()
    
    var persistentContainer: NSPersistentContainer
    
    // Флаг, чтобы не загружать базу данных несколько раз
    private var isInitialized = false

    // Конструктор остается простым
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "toDoListApp")
    }
    
    // Публичный метод инициализации, который можно вызывать всегда
    func initialize(completion: @escaping () -> Void) {
        // Если уже инициализировались, просто вызываем completion и выходим
        if isInitialized {
            completion()
            return
        }
        
        // Иначе выполняем полную инициализацию
        persistentContainer.loadPersistentStores { [weak self] _, error in
            guard let self = self else { return }
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            // Устанавливаем флаг, что все готово
            self.isInitialized = true
            // Включаем автоматическое слияние изменений
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            
            completion()
        }
    }

    // Тестовый конструктор остается без изменений
    internal init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.isInitialized = true // Считаем, что тестовый контейнер уже готов
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }


    // MARK: - Public Methods
    
    func toggleTaskCompletion(for taskId: UUID, completion: @escaping () -> Void) {
        persistentContainer.performBackgroundTask { backgroundContext in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            
            // Ищем задачу по уникальному ID
            request.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(request)
                if let taskEntity = results.first {
                    // Меняем статус на противоположный
                    taskEntity.isCompleted.toggle()
                    try backgroundContext.save()
                    print("✅ Task completion status toggled for ID: \(taskId.uuidString)")
                }
            } catch {
                print("❌ Failed to toggle task completion: \(error)")
            }
            
            // Вызываем completion в главном потоке
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    /// Сохранение всех задач из API в базу данных
    /// обещание - выполнить  код после завершения операции, 
    func saveInitialTasks(apiTasks: [APITask], completion: @escaping () -> Void) {
        persistentContainer.performBackgroundTask { backgroundContext in
            apiTasks.forEach { apiTask in
                let taskEntity = TaskEntity(context: backgroundContext)
                taskEntity.id = UUID()
                taskEntity.title = apiTask.todo
                taskEntity.taskDescription = ""
                taskEntity.createdDate = Date()
                taskEntity.isCompleted = apiTask.completed
            }
            
            do {
                try backgroundContext.save()
                print("✅ Background save finished successfully.")
                
                // После завершения сохранения в фоновом потоке,
                // вызываем completion в главном потоке.
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("❌ Failed to save initial tasks: \(error)")
                // Даже в случае ошибки лучше вызвать completion,
                // чтобы не "зависнуть" в ожидании.
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    /// Получение всех задач из базы данных
    func fetchTasks() -> [Task] {
        // Этот метод тоже остается без изменений.
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        
        do {
            let taskEntities = try context.fetch(request)
            return taskEntities.map { Task(taskEntity: $0) }
        } catch {
            print("Error fetching tasks from Core Data: \(error)")
            return []
        }
    }
    
    func deleteTask(for taskId: UUID, completion: @escaping () -> Void) {
        persistentContainer.performBackgroundTask { backgroundContext in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(request)
                if let taskEntityToDelete = results.first {
                    backgroundContext.delete(taskEntityToDelete)
                    try backgroundContext.save()
                    print("✅ Task deleted with ID: \(taskId.uuidString)")
                }
            } catch {
                print("❌ Failed to delete task: \(error)")
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func createTask(title: String, description: String, completion: @escaping () -> Void) {
        persistentContainer.performBackgroundTask { backgroundContext in
            let taskEntity = TaskEntity(context: backgroundContext)
            taskEntity.id = UUID()
            taskEntity.title = title
            taskEntity.taskDescription = description
            taskEntity.createdDate = Date()
            taskEntity.isCompleted = false
            
            do {
                try backgroundContext.save()
                print("✅ New task created successfully.")
            } catch {
                print("❌ Failed to create new task: \(error)")
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func updateTask(id: UUID, title: String, description: String, completion: @escaping () -> Void) {
        // Используем главный контекст, так как это быстрая операция, инициированная UI
        let context = self.context
        
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let taskEntity = results.first {
                taskEntity.title = title
                taskEntity.taskDescription = description
                try context.save() // Сохраняем прямо в главном контексте
                print("✅ Task updated successfully with ID: \(id.uuidString)")
            }
        } catch {
            print("❌ Failed to update task: \(error)")
        }
        
        // Так как мы в главном потоке, просто вызываем completion
        completion()
    }
}
    // Другие CRUD операции (update, delete, create) мы добавим на следующих шагах

