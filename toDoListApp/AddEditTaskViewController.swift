//
//  AddEditTaskViewController.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 25.11.2025.
//

// AddEditTaskViewController.swift
// AddEditTaskViewController.swift
import UIKit

class AddEditTaskViewController: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    // MARK: - Properties
    
    // Если это свойство заполнено, мы редактируем задачу. Если nil - создаем новую.
    var taskToEdit: Task?
    
    private var isEditMode: Bool {
        return taskToEdit != nil
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    // Этот метод вызывается, когда контроллер исчезает (например, при нажатии "назад")
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // isMovingFromParent проверяет, что контроллер именно "выталкивается" из стека,
        // а не, например, скрывается под другим модальным окном.
        if isMovingFromParent {
            saveTask()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        descriptionTextView.isEditable = true
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 8.0
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.delegate = self
    }
    
    private func populateData() {
        if isEditMode {
            title = "Редактирование"
            titleTextField.text = taskToEdit?.title
            
            if let desc = taskToEdit?.taskDescription, !desc.isEmpty {
                descriptionTextView.text = desc
                descriptionTextView.textColor = .label
            } else {
                descriptionTextView.text = "Описание задачи"
                descriptionTextView.textColor = .placeholderText
            }
            
            dateLabel.text = dateFormatter.string(from: taskToEdit?.createdDate ?? Date())
        } else {
            title = "Новая задача"
            dateLabel.text = dateFormatter.string(from: Date())
        }
    }
    
    // MARK: - Saving Logic
    private func saveTask() {
        guard let title = titleTextField.text, !title.isEmpty else {
            // Если название пустое, ничего не сохраняем
            return
        }
        
        var description = descriptionTextView.text ?? ""
        if description == "Описание задачи" {
            description = ""
        }
        
        if isEditMode {
            // Обновляем существующую задачу
            guard let taskId = taskToEdit?.id else { return }
            CoreDataService.shared.updateTask(id: taskId, title: title, description: description) {
                // completion не нужен, так как мы уже уходим с экрана
            }
        } else {
            // Создаем новую задачу
            CoreDataService.shared.createTask(title: title, description: description) {
                // completion не нужен
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension AddEditTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание задачи"
            textView.textColor = .placeholderText
        }
    }
}
