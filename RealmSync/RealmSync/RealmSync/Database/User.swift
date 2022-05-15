//
//  User.swift
//  RealmSync
//
//  Created by woodsmall on 2022/05/15.
//

import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var _id: String = ""
    @Persisted var name: String?
    @Persisted var memberOf: List<Project>
}
