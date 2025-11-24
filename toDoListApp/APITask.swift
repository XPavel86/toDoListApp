//
//  APITask.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// APITask.swift
import Foundation

// Структура для парсинга ответа от API
struct APITodosResponse: Codable {
    let todos: [APITask]
}

// Структура, соответствующая одному объекту задачи из API
struct APITask: Codable {
    let id: Int
    let todo: String // Название задачи в API
    let completed: Bool // Статус в API
    let userId: Int

    // Мы не будем использовать это напрямую, а конвертировать в нашу модель Task
}
