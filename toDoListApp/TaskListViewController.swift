//
//  TaskListViewController.swift
//  toDoListApp
//
//  Created by Pavel Dolgopolov on 24.11.2025.
//

// TaskListViewController.swift
import UIKit

class TaskListViewController: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Properties
    private let viewModel = TaskListViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список дел"
        
        setupTableView()
        setupSearchBar()
        setupBindings()
        
        // Для первоначальной загрузки используем fetchTasks()
        viewModel.fetchTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // При возвращении на экран обновляем данные, но сохраняем состояние поиска
        viewModel.refreshTasks()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        // Регистрация не нужна, так как мы используем прототип в Storyboard
        tableView.tableFooterView = UIView()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Поиск задач"
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = true
    }
    
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddEditScreen" {
            let destinationVC = segue.destination as! AddEditTaskViewController
            if let indexPath = sender as? IndexPath {
                let taskToEdit = viewModel.task(at: indexPath)
                destinationVC.taskToEdit = taskToEdit
            }
        }
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
        
        cell.onCheckboxTapped = { [weak self] taskId in
            self?.viewModel.toggleTaskCompletion(for: taskId)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showAddEditScreen", sender: indexPath)
    }
    
    // MARK: - Context Menu Configuration
        func tableView(_ tableView: UITableView,
                       contextMenuConfigurationForRowAt indexPath: IndexPath,
                       point: CGPoint) -> UIContextMenuConfiguration? {
            
            let task = viewModel.task(at: indexPath)

            return UIContextMenuConfiguration(
                identifier: indexPath as NSCopying,
                previewProvider: {
                    TaskPreviewViewController(task: task)
                },
                actionProvider: { _ in
                    let edit = UIAction(
                        title: "Редактировать",
                        image: UIImage(systemName: "square.and.pencil")
                    ) { [weak self] _ in
                        self?.performSegue(withIdentifier: "showAddEditScreen", sender: indexPath)
                    }

                    let share = UIAction(
                        title: "Поделиться",
                        image: UIImage(systemName: "square.and.arrow.up")
                    ) { [weak self] _ in
                        self?.shareTask(title: task.title)
                    }

                    let delete = UIAction(
                        title: "Удалить",
                        image: UIImage(systemName: "trash"),
                        attributes: .destructive
                    ) { [weak self] _ in
                        self?.deleteTask(taskId: task.id)
                    }

                    return UIMenu(title: "", children: [edit, share, delete])
                }
            )
        }

        
        // MARK: - Центрирование контекстного меню (главное исправление)
//    func tableView(_ tableView: UITableView,
//                   contextMenuConfiguration configuration: UIContextMenuConfiguration,
//                   highlightPreviewForItemAt indexPath: IndexPath,
//                   point: CGPoint) -> UITargetedPreview? {
//
//        let target = UIPreviewTarget(container: tableView.superview ?? tableView,
//                                     center: CGPoint(x: tableView.bounds.midX, y: point.y))
//
//        let dummy = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
//        dummy.backgroundColor = .clear
//
//        let params = UIPreviewParameters()
//        params.backgroundColor = .clear // например
//
//        return UITargetedPreview(view: dummy, parameters: params, target: target)
//    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfiguration configuration: UIContextMenuConfiguration,
                   highlightPreviewForItemAt indexPath: IndexPath,
                   point: CGPoint) -> UITargetedPreview? {

        // центрируем по ширине экрана
        let target = UIPreviewTarget(
            container: tableView.superview ?? tableView,
            center: CGPoint(x: tableView.bounds.midX,
                            y: tableView.cellForRow(at: indexPath)?.frame.midY ?? point.y)
        )

        let dummy = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        dummy.backgroundColor = .clear
        
        let params = UIPreviewParameters()
       params.backgroundColor = .clear // например

        return UITargetedPreview(view: dummy, parameters: params, target: target)
    }

        
} // END UITableViewDelegate

// MARK: - UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterTasks(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.clearSearch()
    }
}

// MARK: - Private Actions
extension TaskListViewController {
    private func shareTask(title: String) {
        let activityViewController = UIActivityViewController(activityItems: [title], applicationActivities: nil)
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
