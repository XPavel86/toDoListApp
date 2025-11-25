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
    
    // MARK: - IB Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        print("Кнопка 'Добавить задачу' нажата!")
        // Здесь мы будем переходить на следующий экран в следующем подшаге
    }
}

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
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Выбрана задача: \(viewModel.task(at: indexPath).title)")
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
