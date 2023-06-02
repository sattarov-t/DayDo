//
//  DoViewController.swift
//  DayDo
//
//  Created by Тимур on 27.05.2023.
//

import UIKit
import RealmSwift

class DoViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var doItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return doItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = doItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "Задачи еще не добавлены"
        }
        return cell
    }
    
    //MARK: - Tableview delegate methods (func for checkmark of cell)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = doItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add new item (Buttom func)
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Добавьте задачу", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Добавить", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.creationDate = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving newitem\(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Создайте новую задачу"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation Methods
    
    func loadItems() {
        doItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    //MARK: - Delete Data from Swipe
    //Create model for using swipe in CategoryController and DoController
    override func updateModel(at indexPath: IndexPath) {
        if let doForDeletion = self.doItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(doForDeletion)
                }
            } catch {
                print("Error with deleting category\(error)")
            }
        }
    }
    
}

//MARK: - Search bar methods

extension DoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        doItems = doItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "creationDate", ascending: true)
        
        tableView.reloadData()
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}
