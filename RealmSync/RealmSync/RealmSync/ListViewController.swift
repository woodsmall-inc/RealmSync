//
//  ViewController.swift
//  RealmSync
//
//  Created by woodsmall on 2022/05/15.
//

import RealmSwift
import UIKit

class ListViewController: UIViewController {

    private var arrSchedule = [Schedule]()

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var viewNodata: UIView!
    @IBOutlet private var labelNodata: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setSchedule()
    }

    @IBAction private func actionAdd(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InputViewController") as! InputViewController
        viewController.delegate = self
        let navigationBar = UINavigationController(rootViewController: viewController)
        navigationBar.modalTransitionStyle = .coverVertical
        present(navigationBar, animated: true, completion: nil)
    }
    
    func setSchedule() {
        arrSchedule.removeAll()
        
        let sortDescriptors = [
            RealmSwift.SortDescriptor(keyPath: "startDate", ascending: true),
            RealmSwift.SortDescriptor(keyPath: "allDay", ascending: false),
            RealmSwift.SortDescriptor(keyPath: "startTime", ascending: true)
        ]
        let s = Schedule.findAll().sorted(by: sortDescriptors)
        if s.count > 0 {
            for i in 0...s.count - 1 {
                arrSchedule.append(s[i])
            }
            viewNodata.isHidden = true
        } else {
            viewNodata.isHidden = false
        }
        tableView.reloadData()
    }
}

extension ListViewController: InputViewControllerDelegate {
    func inputViewDidFinished() {
        setSchedule()
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSchedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")

        let schedule = arrSchedule[indexPath.row]
        
        cell.textLabel?.text = schedule.schedule
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InputViewController") as! InputViewController
        viewController.delegate = self
        viewController.id = arrSchedule[indexPath.row].id
        let navigationBar = UINavigationController(rootViewController: viewController)
        navigationBar.modalTransitionStyle = .coverVertical
        present(navigationBar, animated: true, completion: nil)
    }
}
