//
//  TaskListViewController_.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//
// TaskListViewController.swift
import UIKit

// ИЗМЕНЕНИЕ: Наследуемся от UITableViewController
class TaskListViewController: UITableViewController {

    // УБРАЛИ: @IBOutlet var tableView: UITableView! - он уже есть в UITableViewController
    
    // Экземпляр нашей ViewModel
    private let viewModel = TaskListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список дел"
        
        // УБРАЛИ: setupTableView() - больше не нужно
        
        setupBindings()
        
        // Загружаем данные
        viewModel.fetchTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchTasks()
    }
    
    // УБРАЛИ: private func setupTableView() - больше не нужно
    
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension TaskListViewController {
    
    // UITableViewController уже реализует методы dataSource/delegate,
    // нам нужно только переопределить нужные.
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Идентификатор должен совпадать со Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellIdentifier", for: indexPath) as! TaskTableViewCell
        
        let task = viewModel.task(at: indexPath)
        cell.configure(with: task)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Выбрана задача: \(viewModel.task(at: indexPath).title)")
    }
}
