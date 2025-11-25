//
//  TaskListViewController.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// TaskListViewController.swift
import UIKit

// Возвращаемся к UIViewController, так как нам нужен полный контроль над разметкой
class TaskListViewController: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar! // Добавили аутлет для поиска
    
    // MARK: - Properties
    private let viewModel = TaskListViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchBar()
        setupBindings()
        
        viewModel.fetchTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchTasks()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Поиск задач"
        // Убираем фон у поисковой строки для лучшего вида
        searchBar.searchBarStyle = .minimal
    }
    
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
//    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        
//        // Получаем задачу для нужной строки
//        let task = viewModel.task(at: indexPath)
//        
//        // Создаем конфигурацию
//        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
//            // Создаем меню
//            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
//                print("Редактировать задачу: \(task.title)")
//                // TODO: Здесь будет переход на экран редактирования
//            }
//            
//            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
//                self?.shareTask(title: task.title)
//            }
//            
//            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
//                self?.deleteTask(taskId: task.id)
//            }
//            
//            // Возвращаем UIMenu с нашими действиями
//            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
//        }
//        
//        return configuration
//    }
    
    // MARK: - IB Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        print("Кнопка 'Добавить задачу' нажата!")
        // Здесь мы будем переходить на следующий экран в следующем подшаге
    }
    
    
}
//kkkkkkkk
// MARK: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellIdentifier", for: indexPath) as! TaskTableViewCell
        
        let task = viewModel.task(at: indexPath)
        cell.configure(with: task)
        
        // Подписываемся на нажатие чекбокса
        cell.onCheckboxTapped = { [weak self] taskId in
            print("Чекбокс нажат для задачи с ID: \(taskId)")
            self?.viewModel.toggleTaskCompletion(for: taskId)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
// TaskListViewController.swift

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    
    // УБРАЛИ 'override'
     func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let task = viewModel.task(at: indexPath)
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
                self?.performSegue(withIdentifier: "showAddEditScreen", sender: indexPath)
            }
            
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                // Вызываем метод, который мы добавим ниже
                self?.shareTask(title: task.title)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                // Вызываем метод, который мы добавим ниже
                self?.deleteTask(taskId: task.id)
            }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
        
        return configuration
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showAddEditScreen", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddEditScreen" {
            let destinationVC = segue.destination as! AddEditTaskViewController
            
            // Если sender - это IndexPath, значит мы редактируем
            if let indexPath = sender as? IndexPath {
                let taskToEdit = viewModel.task(at: indexPath)
                destinationVC.taskToEdit = taskToEdit
            }
            // Если sender - не IndexPath (например, кнопка "добавить"),
            // то destinationVC.taskToEdit останется nil, что правильно для создания новой задачи.
        }
    }
    
}

// MARK: - Private Actions (ЭТОТ БЛОК НУЖНО ДОБАВИТЬ)
extension TaskListViewController {
    
    private func shareTask(title: String) {
        let activityViewController = UIActivityViewController(activityItems: [title], applicationActivities: nil)
        
        // Для iPad нужно указать, откуда показывать контроллер
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
    
    private func deleteTask(taskId: UUID) {
        viewModel.deleteTask(for: taskId)
    }
}

  


// MARK: - UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    // Реализуем поиск в следующем подшаге
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Пока что просто печатаем текст
        print("Поиск: \(searchText)")
    }
}

