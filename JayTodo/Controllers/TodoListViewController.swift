//
//  ViewController.swift
//  JayTodo
//
//  Created by John Spina on 8/8/19.
//  Copyright © 2019 jspina. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

  var todoItems: Results<Item>?
  let realm = try! Realm()
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var selectedCategory : Category? {
    didSet {
      loadItems()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist"))
    
    tableView.separatorStyle = .none
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
        title = selectedCategory?.name

        guard let colorHex = selectedCategory?.color else { fatalError() }

        updateNavBar(withHexCode: colorHex)
    
  }

  
  override func viewWillDisappear(_ animated: Bool) {
  
    updateNavBar(withHexCode: "1D9BF6")
    
  }

  
  //MARK:- Nav Bar Setup Methods
  func updateNavBar(withHexCode colorHexCode: String) {
    
    guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")}

    guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
    
    navBar.barTintColor = navBarColor
    
    navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
    
    navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    
    searchBar.barTintColor = navBarColor
    
  }
  
  
  
  //MARK: - Tableview Datasource Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return todoItems?.count ?? 1
    
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = super.tableView(tableView, cellForRowAt: indexPath)

    if let item = todoItems?[indexPath.row] {
      
      cell.textLabel?.text = item.title
      
      if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
      }
      
//      print("Version 1: \(CGFloat(indexPath.row / todoItems!.count))")
//      print("Version 2: \(CGFloat(indexPath.row) / CGFloat(todoItems!.count))")
      
      // Ternary operator
      // value = condition ? valueIfTrue : valueIfFalse
      
      cell.accessoryType = item.done ? .checkmark : .none
    } else {
      cell.textLabel?.text = "No Items Added"
    }
    
    return cell
    
  }
  
  //MARK - TableView Delegate Methods
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // print(itemArray[indexPath.row])
    
    if let item = todoItems?[indexPath.row] {
      do {
        try realm.write {
          item.done = !item.done
        }
      } catch {
        print("Error saving done status, \(error)")
      }
    }
    
    tableView.reloadData()

    tableView.deselectRow(at: indexPath, animated: true)
    
  }
  
  
  //MARK - Add New Items
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textField = UITextField()
    
    let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
    
    let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
      // what will happen once the user clicks the Add Item button on our UIAlert
      
      if let currentCategory = self.selectedCategory {
        do {
          try self.realm.write {
            let newItem = Item()
            newItem.title = textField.text!
            newItem.dateCreated = Date()
            currentCategory.items.append(newItem)
          }
        } catch {
          print("Error saving new items, \(error)")
        }
      }
      
      self.tableView.reloadData()

    }
    
    alert.addTextField { (alertTextField) in
      alertTextField.placeholder = "Create New Item"
      textField = alertTextField
    }
    
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  //MARK - Model Manipulation Methods
  
  func saveItems() {
    
    self.tableView.reloadData()
    
  }
  
  func loadItems() {

    todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

    tableView.reloadData()

  }
  
  override func updateModel(at indexPath: IndexPath) {
    if let item = todoItems?[indexPath.row] {
      do {
          try realm.write {
              realm.delete(item)
          }
        } catch {
          print("Erorr deleting Item, \(error)")
        }
    }
  }
  
}


//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
    
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
