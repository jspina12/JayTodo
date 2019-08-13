//
//  CategoryViewController.swift
//  JayTodo
//
//  Created by John Spina on 8/13/19.
//  Copyright © 2019 jspina. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
  
  //Static array test set
  //var categoryArray = ["1", "2", "3", "4"]
  var categories = [Category]()
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  
    override func viewDidLoad() {
        super.viewDidLoad()

      loadCategories()
      
    }

  
  //MARK: - TableView Datasource Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return categories.count
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    
    let category = categories[indexPath.row]
    
    cell.textLabel?.text = category.name
    
    // Ternary operator
    // value = condition ? valueIfTrue : valueIfFalse
    
    return cell
    
  }
  
  //MARK: - TableView Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "goToItems", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! TodoListViewController
    
    if let indexPath = tableView.indexPathForSelectedRow {
      destinationVC.selectedCategory = categories[indexPath.row]
    }
  }
  
  //MARK: - Add New Categories
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textField = UITextField()
    
    let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
    
    let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
      // what will happen once the user clicks the Add Category button on our UIAlert
      
      let newCategory = Category(context: self.context)
      newCategory.name = textField.text!
      
      self.categories.append(newCategory)
      
      self.saveCategories()
      
    }
    
    alert.addTextField { (field) in
      textField = field
      textField.placeholder = "Create New Category"
    }
    
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
    
  }
  
 
  //MARK: - Data Manipulation Methods

  func saveCategories() {
    
    do {
      try context.save()
    } catch {
      print("Error saving context \(error)")
    }
    
    tableView.reloadData()
    
  }
  
  func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
    
    do {
      categories = try context.fetch(request)
    } catch {
      print("Error loading categories \(error)")
    }
    
    tableView.reloadData()
    
  }
  
}
