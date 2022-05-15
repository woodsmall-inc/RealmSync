//
//  Schedule.swift
//  RealmSync
//
//  Created by woodsmall on 2022/05/15.
//

import RealmSwift

class Schedule: Object {
    @objc dynamic var id = 1
    @objc dynamic var year = 0
    @objc dynamic var month = 0
    @objc dynamic var startDate = ""
    @objc dynamic var endDate = ""
    @objc dynamic var startTime = ""
    @objc dynamic var endTime = ""
    @objc dynamic var allDay = false
    @objc dynamic var schedule = ""
    @objc dynamic var location = ""
    @objc dynamic var memo = ""
    @objc dynamic var imageDir = ""
    @objc dynamic var createDate = Date()
    @objc dynamic var updateDate = Date()

    // プライマリーキー
    override class func primaryKey() -> String? {
        return "id"
    }

    // インデックス
    override class func indexedProperties() -> [String] {
        return ["year", "month", "startDate"]
    }
    
    /* 【検索】 */
    static func findAll() -> Results<Schedule> {
        var results: Results<Schedule>?
        let realm = try! Realm()
        results = realm.objects(Schedule.self)
        return results!
    }

    static func find(id: Int) -> Schedule? {
        var result: Schedule?
        let realm = try! Realm()
        result = realm.object(ofType: Schedule.self, forPrimaryKey: id)
        return result
    }

    static func findDate(sDate: String) -> Results<Schedule> {
        var results: Results<Schedule>?
        let realm = try! Realm()
        results = realm.objects(Schedule.self).filter("startDate == %@", sDate)
        return results!
    }
    
    static func findMonth(year: Int, month: Int) -> Results<Schedule> {
        var results: Results<Schedule>?
        let realm = try! Realm()
        results = realm.objects(Schedule.self).filter("year == %@ AND month == %@", year, month)
        return results!
    }

    static func findSchedule(schedule: String) -> Results<Schedule> {
        var results: Results<Schedule>?
        let realm = try! Realm()
        results = realm.objects(Schedule.self).filter("schedule == %@", schedule)
        return results!
    }
    
    static func findKeyword(keyword: String) -> Results<Schedule> {
        var results: Results<Schedule>?
        let realm = try! Realm()
        results = realm.objects(Schedule.self).filter("schedule CONTAINS %@", keyword)
        return results!
    }

    static func lastId() -> Int {
        let realm = try! Realm()
        if let result = realm.objects(Schedule.self).sorted(byKeyPath: "id", ascending: true).last {
            return result.id + 1
        }
        return 1
    }
    
    /* 【保存】 */
    func save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self, update: .modified)
        }
    }
    
    /* 【削除】 */
    func delete() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }

    func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}
