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

class CoreDataService {
    
    static let shared = CoreDataService()
    
    // РЕШЕНИЕ ПРОБЛЕМЫ:
    // Создаем контейнер прямо здесь, внутри сервиса.
    // Он инициализируется один раз при первом обращении к shared.
    // ВАЖНО: Убедитесь, что имя "ToDoList" в кавычках совпадает с именем вашего .xcdatamodeld файла!
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "toDoListApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // В реальном приложении здесь нужна более сложная обработка ошибок.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}

    // MARK: - Public Methods
    
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
}
    // Другие CRUD операции (update, delete, create) мы добавим на следующих шагах

