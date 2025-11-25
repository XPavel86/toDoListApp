//
//  TaskTableViewCell.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// TaskTableViewCell.swift
// TaskTableViewCell.swift
import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    @IBOutlet var checkboxButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBAction func checkboxButtonTapped(_ sender: UIButton) {
        // Проверяем, что taskId существует, и вызываем замыкание
        guard let taskId = taskId else { return }
        onCheckboxTapped?(taskId)
    }
    
    private var taskId: UUID?
    var onCheckboxTapped: ((UUID) -> Void)?
    
    // Форматировщик для даты, чтобы создавать его один раз
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
        // Configure the view for the selected state
    }
    
    // MARK: - Configuration
    
    func configure(with task: Task) {
        // Сохраняем id задачи
        self.taskId = task.id
        
        titleLabel.text = task.title
        descriptionLabel.text = task.taskDescription.isEmpty ? "Нет описания" : task.taskDescription
        dateLabel.text = dateFormatter.string(from: task.createdDate)
        
        updateCheckboxState(isCompleted: task.isCompleted)
    }
    
    private func updateCheckboxState(isCompleted: Bool) {
        if isCompleted {
            checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            // Зачеркиваем заголовок
            titleLabel.attributedText = NSAttributedString(
                string: titleLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            titleLabel.textColor = .secondaryLabel
        } else {
            checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
            // Убираем зачеркивание
            titleLabel.attributedText = NSAttributedString(string: titleLabel.text ?? "")
            titleLabel.textColor = .label
        }
    }
}
