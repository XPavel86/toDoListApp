//
//  TaskTableViewCell.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// TaskTableViewCell.swift
// TaskTableViewCell.swift
// TaskTableViewCell.swift
import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    // УБРАЛИ: @IBOutlet var titleLabel!
    @IBOutlet var checkboxButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    @IBAction func checkboxButtonTapped(_ sender: UIButton) {
        guard let taskId = taskId else { return }
        onCheckboxTapped?(taskId)
    }
    
    private var taskId: UUID?
    var onCheckboxTapped: ((UUID) -> Void)?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // --- НОВЫЙ, СОВРЕМЕННЫЙ КОД ДЛЯ iOS 15+ ---
        
        // 1. Создаем конфигурацию. Стиль .plain самый подходящий для чекбокса.
        var config = UIButton.Configuration.plain()
        
        // 2. Убираем все внутренние отступы (аналог старого contentEdgeInsets)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        // 3. Убираем отступы вокруг изображения (аналог старого imageEdgeInsets)
        config.imagePadding = 0
        
        // 4. Применяем конфигурацию к нашей кнопке
        checkboxButton.configuration = config
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
    
    // TaskTableViewCell.swift

    func configure(with task: Task) {
        self.taskId = task.id
        
        // Получаем текущую конфигурацию кнопки
        var updatedConfig = checkboxButton.configuration
        
        if task.isCompleted {
            // --- ЗАДАЧА ВЫПОЛНЕНА ---
            // 1. Устанавливаем иконку заполненного кружка
            updatedConfig?.image = UIImage(systemName: "checkmark.circle.fill")
            // 2. Устанавливаем АКТИВНЫЙ цвет (например, синий или зеленый)
            updatedConfig?.baseForegroundColor = .systemBlue // или .systemGreen, или ваш кастомный цвет
            
            // Применяем зачеркивание к titleLabel
            let attributedTitle = NSAttributedString(
                string: task.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            titleLabel.attributedText = attributedTitle
            titleLabel.textColor = .secondaryLabel
            
        } else {
            // --- ЗАДАЧА НЕ ВЫПОЛНЕНА ---
            // 1. Устанавливаем иконку пустого кружка
            updatedConfig?.image = UIImage(systemName: "circle")
            // 2. Устанавливаем НЕАКТИВНЫЙ (серый) цвет
            updatedConfig?.baseForegroundColor = .systemGray3 // или .systemGray4, .quaternaryLabel
            
            // Обычный текст для titleLabel
            titleLabel.text = task.title
            titleLabel.textColor = .label
        }
        
        // Применяем обновленную конфигурацию обратно к кнопке
        checkboxButton.configuration = updatedConfig
        
        // --- Остальная часть метода остается без изменений ---
        descriptionLabel.text = task.taskDescription.isEmpty ? "Нет описания" : task.taskDescription
        dateLabel.text = dateFormatter.string(from: task.createdDate)
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            
            // Сбрасываем все, что может вызывать конфликты
            taskId = nil
            onCheckboxTapped = nil
            
            // Важно сбросить и изображение, и текст кнопки
            checkboxButton.setImage(nil, for: .normal)
            checkboxButton.setTitle(nil, for: .normal)
            checkboxButton.setTitleColor(.label, for: .normal) // Возвращаем цвет по умолчанию
            descriptionLabel.text = nil
            dateLabel.text = nil
        }
    
    // MARK: - Configuration
    
    // НОВЫЙ МЕТОД: Обновляет иконку, текст и стиль кнопки
    private func updateCheckboxAndTitle(for task: Task) {
        if task.isCompleted {
            checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            
            // Зачеркиваем текст прямо на кнопке
            let attributedTitle = NSAttributedString(
                string: task.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            checkboxButton.setAttributedTitle(attributedTitle, for: .normal)
            checkboxButton.setTitleColor(.secondaryLabel, for: .normal)
            
        } else {
            checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
            
            // Устанавливаем обычный текст на кнопке
            checkboxButton.setTitle(task.title, for: .normal)
            checkboxButton.setTitleColor(.label, for: .normal)
        }
    }
}
