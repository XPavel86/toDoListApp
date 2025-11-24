//
//  TaskTableViewCell.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// TaskTableViewCell.swift
import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // Переопределяем инициализатор, чтобы установить стиль, если создаем ячейку программно.
    // Но так как мы настраиваем в Storyboard, этот метод не будет вызываться.
    // Тем не менее, это хорошая практика.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        // Дополнительная настройка ячейки, если нужна
        accessoryType = .disclosureIndicator // Стрелочка справа
    }
    
    // Метод для конфигурации ячейки данными
    func configure(with task: Task) {
        textLabel?.text = task.title
        detailTextLabel?.text = task.taskDescription.isEmpty ? "Нет описания" : task.taskDescription
        
        // Визуально отображаем статус выполнения
        if task.isCompleted {
            textLabel?.textColor = .secondaryLabel
            textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        } else {
            textLabel?.textColor = .label
            textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        }
    }
}
