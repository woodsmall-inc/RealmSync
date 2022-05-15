//
//  Project.swift
//  RealmSync
//
//  Created by woodsmall on 2022/05/15.
//

import RealmSwift

class Project: EmbeddedObject {
    @Persisted var name: String?
    @Persisted var partition: String?
    
    convenience init(partition: String, name: String) {
        self.init()
        
        self.partition = partition
        self.name = name
    }
}
