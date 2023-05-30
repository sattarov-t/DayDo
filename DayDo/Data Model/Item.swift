//
//  Item.swift
//  DayDo
//
//  Created by Тимур on 26.05.2023.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var creationDate: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
