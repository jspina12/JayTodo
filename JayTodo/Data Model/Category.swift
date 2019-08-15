//
//  Category.swift
//  JayTodo
//
//  Created by John Spina on 8/13/19.
//  Copyright © 2019 jspina. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
  @objc dynamic var name: String = ""
  let items = List<Item>()
}
