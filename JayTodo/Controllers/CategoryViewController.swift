//
//  CategoryViewController.swift
//  JayTodo
//
//  Created by John Spina on 8/13/19.
//  Copyright © 2019 jspina. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
  
  let realm = try! Realm()
  
  //Static array test set
  //var categoryArray = ["1", "2", "3", "4"]
  var categories: Results<Category>?
  
    override func viewDidLoad() {
        super.viewDidLoad()

      loadCategories()
      
      tableView.separatorStyle = .none
      
    }

  
  //MARK: - TableView Datasource Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return categories?.count ?? 1
    
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Ternary operator
    // value = condition ? valueIfTrue : valueIfFalse
    
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if let category = categories?[indexPath.row] {
      
      cell.textLabel?.text = category.name
      
      guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
      
      cell.backgroundColor = categoryColor
      cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)

    }
    
    
    return cell
    
  }
  
  
  //MARK: - TableView Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "goToItems", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! TodoListViewController
    
    if let indexPath = tableView.indexPathForSelectedRow {
      destinationVC.selectedCategory = categories?[indexPath.row]
    }
  }
  
  //MARK: - Data Manipulation Methods

  func save(category: Category) {
    
    do {
      try realm.write {
        realm.add(category)
      }
    } catch {
      print("Error saving context \(error)")
    }
    
    tableView.reloadData()
    
  }
  
  func loadCategories() {
    
    categories = realm.objects(Category.self)

    tableView.reloadData()
    
  }
  
  //MARK: - Delete Data From Swipe
  
  override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
          do {
            try self.realm.write {
              self.realm.delete(categoryForDeletion)
            }
          } catch {
            print("Error deleting category, \(error)")
          }
  
        }
  }
  
  //MARK: - Add New Categories
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textField = UITextField()
    
    let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
    
    let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
      // what will happen once the user clicks the Add Category button on our UIAlert
      
      let newCategory = Category()
      newCategory.name = textField.text!
      newCategory.color = UIColor.randomFlat.hexValue()
      
      self.save(category: newCategory)
      
    }
    
    alert.addTextField { (field) in
      textField = field
      textField.placeholder = "Create New Category"
    }
    
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
    
  }
  
}
