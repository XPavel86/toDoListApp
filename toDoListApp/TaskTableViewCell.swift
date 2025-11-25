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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
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
    
    func configure(with task: Task) {
        self.taskId = task.id
        
        // ИЗМЕНЕНИЕ: Работаем напрямую с кнопкой
        updateCheckboxAndTitle(for: task)
        
        descriptionLabel.text = task.taskDescription.isEmpty ? "Нет описания" : task.taskDescription
        dateLabel.text = dateFormatter.string(from: task.createdDate)
    }
    
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
