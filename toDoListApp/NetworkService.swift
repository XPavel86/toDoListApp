//
//  NetworkService.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// NetworkService.swift
import Foundation

// Перечисление для явной обработки ошибок сети
enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class NetworkService {
    
    static let shared = NetworkService() // Синглтон для легкого доступа
    
    private init() {}
    
    private let baseURL = "https://dummyjson.com/todos"

    func fetchTodos(completion: @escaping (Result<[APITask], NetworkError>) -> Void) {
        // 1. Проверяем валидность URL
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. Создаем задачу для URLSession. Запуск будет в фоновом потоке по умолчанию.
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 3. Обрабатываем возможные ошибки
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // 4. Декодируем JSON
            do {
                let apiResponse = try JSONDecoder().decode(APITodosResponse.self, from: data)
                completion(.success(apiResponse.todos))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume() // 5. Запускаем задачу
    }
}
