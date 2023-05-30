//
//  Category.swift
//  DayDo
//
//  Created by Тимур on 26.05.2023.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
