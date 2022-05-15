//
//  InputViewController.swift
//  RealmSync
//
//  Created by woodsmall on 2022/05/15.
//

import Eureka
import UIKit

protocol InputViewControllerDelegate: AnyObject {
    func inputViewDidFinished()
}

class InputViewController: FormViewController {
    
    private enum Sections: Int {
        case title
        case date
        case detail
        
        static let count = detail.rawValue + 1
        
        func text() -> String {
            switch self {
            case .title:
                return "タイトル"
            case .date:
                return "日付"
            case .detail:
                return "詳細"
            }
        }
        
        func placeholder() -> String {
            switch self {
            case .title:
                return "タイトルを入力"
            case .date:
                return "日付を入力"
            case .detail:
                return "詳細を入力"
            }
        }
        
        func numberOfRows() -> Int {
            switch self {
            case .title:
                return 1
            case .date:
                return 3
            case .detail:
                return 1
            }
        }
        
        func heightForRow() -> CGFloat {
            switch self {
            case .title:
                return CGFloat(44)
            case .date:
                return CGFloat(44)
            case .detail:
                return CGFloat(100)
            }
        }
        
        func key() -> String {
            switch self {
            case .title:
                return "title"
            case .date:
                return "date"
            case .detail:
                return "detail"
            }
        }
    }
    
    private enum DateSection: Int {
        case allDay
        case from
        case to

        func text() -> String {
            switch self {
            case .allDay:
                return "終日"
            case .from:
                return "開始"
            case .to:
                return "終了"
            }
        }
        
        func key() -> String {
            switch self {
            case .allDay:
                return "allDay"
            case .from:
                return "from"
            case .to:
                return "to"
            }
        }
    }
    
    weak var delegate: InputViewControllerDelegate?

    var mCurrentDate = Date()

    var schedule: Schedule?
    var id = 0
    var year = 0
    var month = 0
    var startDate = ""
    var endDate = ""
    var startTime = ""
    var endTime = ""
    var allDay = false
    var scheduleTitle = ""
    var location = ""
    var memo = ""
    var imageDir = ""
    var createDate = Date()
    var updateDate = Date()
    
    private var bSaved = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setSchedule()
        setForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if bSaved {
            self.delegate?.inputViewDidFinished()
        }
    }

    
    @IBAction private func actionSave(_ sender: Any) {
        setSave()
    }

    @IBAction private func actionDone(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @objc func setSave() {
        let textRow = form.rowBy(tag: Sections.title.key()) as! TextRow
        var title = textRow.value
        if title == nil {
            title = "タイトルなし"
        }
        
        let allDayRow = form.rowBy(tag: DateSection.allDay.key()) as! SwitchRow
        var allDay = allDayRow.value
        if allDay == nil {
            allDay = false
        }
        
        let fromRow = form.rowBy(tag: DateSection.from.key()) as! DateTimeInlineRow
        let from = getStringFromDate(date: fromRow.value!, format: Constant.DATE_FORMAT_DB)
        let fromTime = getStringFromDate(date: fromRow.value!, format: Constant.TIME_FORMAT_DB)

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: fromRow.value!)
        let year = comps.year!
        let month = comps.month!
        
        let toRow = form.rowBy(tag: DateSection.to.key()) as! DateTimeInlineRow
        let to = getStringFromDate(date: toRow.value!, format: Constant.DATE_FORMAT_DB)
        let toTime = getStringFromDate(date: toRow.value!, format: Constant.TIME_FORMAT_DB)

        let detailRow = form.rowBy(tag: Sections.detail.key()) as! TextAreaRow
        var detail = detailRow.value
        if detail == nil {
            detail = ""
        }
        
        let s = Schedule()
        if id == 0 {
            s.id = Schedule.lastId()
        } else {
            s.id = id
            s.createDate = createDate
        }
        s.year = year
        s.month = month
        s.startDate = from
        s.endDate = to
        s.startTime = fromTime
        s.endTime = toTime
        if allDay! {
            s.allDay = true
        }
        s.schedule = title!
        s.location = location
        s.memo = detail!
        s.updateDate = Date()
        s.save()
        
        bSaved = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setSchedule() {
        if id == 0 {
            return
        }
        
        if let s = Schedule.find(id: id) {
            schedule = s
            year = s.year
            month = s.month
            startDate = s.startDate
            endDate = s.endDate
            startTime = s.startTime
            endTime = s.endTime
            allDay = s.allDay
            scheduleTitle = s.schedule
            location = s.location
            memo = s.memo
            imageDir = s.imageDir
            createDate = s.createDate
        }
    }
    
    
    func setForm() {
        // タイトル
        let titleRow = TextRow() {
            $0.tag = Sections.title.key()
            $0.title = Sections.title.text()
            $0.placeholder = Sections.title.placeholder()
            if id != 0 {
                $0.value = scheduleTitle
            }
        }
        let titleSection = Section(Sections.title.text())
        titleSection.append(titleRow)
        
        // 日付
        let alldayRow = SwitchRow(DateSection.allDay.key()) { row in
            row.tag = DateSection.allDay.key()
            row.title = DateSection.allDay.text()
            if id != 0 {
                row.value = allDay
            }
        }.onChange { [weak self] row in
            let from: DateTimeInlineRow! = self?.form.rowBy(tag: DateSection.from.key())
            let to: DateTimeInlineRow! = self?.form.rowBy(tag: DateSection.to.key())
            
            if row.value ?? false {
                from.dateFormatter?.dateStyle = .medium
                from.dateFormatter?.timeStyle = .none
                to.dateFormatter?.dateStyle = .medium
                to.dateFormatter?.timeStyle = .none
                
            } else {
                from.dateFormatter?.dateStyle = .medium
                from.dateFormatter?.timeStyle = .short
                to.dateFormatter?.dateStyle = .medium
                to.dateFormatter?.timeStyle = .short

            }
            from.updateCell()
            to.updateCell()
            from.inlineRow?.updateCell()
            to.inlineRow?.updateCell()

        }
        
        let fromRow = DateTimeInlineRow(DateSection.from.key()) { row in
            row.tag = DateSection.from.key()
            row.title = DateSection.from.text()
            row.dateFormatter?.dateStyle = .medium
            if id != 0 {
                if allDay {
                    row.value = getDateFromString(string: startDate, format: Constant.DATE_FORMAT_DB)
                    row.dateFormatter?.timeStyle = .none
                } else {
                    row.value = getDateFromString(string: startDate + " " + startTime, format: Constant.DATE_TIME_FORMAT_DB)
                    row.dateFormatter?.timeStyle = .short
                }
            } else {
                row.value = mCurrentDate
                row.dateFormatter?.timeStyle = .short
            }
        }.onExpandInlineRow { [weak self] cell, row, inlineRow in
            inlineRow.cellUpdate { cell, row in
                let allDay: SwitchRow! = self?.form.rowBy(tag: DateSection.allDay.key())
                if allDay.value ?? false {
                    cell.datePicker.datePickerMode = .date
                } else {
                    cell.datePicker.datePickerMode = .dateAndTime
                }
            }
         }

        let toRow = DateTimeInlineRow(DateSection.to.key()) { row in
            row.tag = DateSection.to.key()
            row.title = DateSection.to.text()
            row.dateFormatter?.dateStyle = .medium
            if id != 0 {
                if allDay {
                    row.value = getDateFromString(string: endDate, format: Constant.DATE_FORMAT_DB)
                    row.dateFormatter?.timeStyle = .none
                } else {
                    row.value = getDateFromString(string: endDate + " " + endTime, format: Constant.DATE_TIME_FORMAT_DB)
                    row.dateFormatter?.timeStyle = .short
                }
            } else {
                row.value = Calendar.current.date(byAdding: .hour, value: 1, to: mCurrentDate)!
                row.dateFormatter?.timeStyle = .short
            }
        }.onExpandInlineRow { [weak self] cell, row, inlineRow in
            inlineRow.cellUpdate { cell, row in
                let allDay: SwitchRow! = self?.form.rowBy(tag: DateSection.allDay.key())
                if allDay.value ?? false {
                    cell.datePicker.datePickerMode = .date
                } else {
                    cell.datePicker.datePickerMode = .dateAndTime
                }
            }
        }

        let dateSection = Section(Sections.date.text())
        dateSection.append(alldayRow)
        dateSection.append(fromRow)
        dateSection.append(toRow)

        // 詳細
        let detailRow = TextAreaRow() { row in
            row.tag = Sections.detail.key()
            row.title = Sections.detail.text()
            row.placeholder = Sections.detail.placeholder()
            if id != 0 {
                row.value = memo
            }
        }
        
        let detailSection = Section(Sections.detail.text())
        detailSection.append(detailRow)

        
        form.append(titleSection)
        form.append(dateSection)
        form.append(detailSection)
    }

    func getStringFromDate(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    func getDateFromString(string: String, format: String) -> Date {
        if string.count == 0 {
            return Date()
        }
        var result = string
        switch format {
        case Constant.DATE_FORMAT_DB:
            result += " 00:00:00"
            break
        case Constant.TIME_FORMAT_DB:
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar.current
            dateFormatter.dateFormat = Constant.DATE_FORMAT_DB
            result = dateFormatter.string(from: Date()) + " " + string
            break
        default:
            break
        }
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = Constant.DATE_FORMAT_DB + " " + Constant.TIME_FORMAT_DB
        
        guard let date = dateFormatter.date(from: result) else {
            return Date()
        }
        return date
    }
}
