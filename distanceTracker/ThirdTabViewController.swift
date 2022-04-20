//
//  ViewController.swift
//  distanceTracker
//
//  Created by manukant tyagi on 19/04/22.
//

import UIKit

class ThirdTabController: UIViewController {

    var runs: [Run] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }

    func getData(){
        let allRuns = DBManager().read()
        runs = allRuns.filter({ (run) in
            if let distance = Double(run.distance){
                if distance > 50{
                    return true
                }
            }
            return false
        })
    }

}
extension ThirdTabController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.dateLabel.text = runs[indexPath.row].date
        cell.timeLabel.text = runs[indexPath.row].time
        cell.distanceLabel.text = "\(runs[indexPath.row].distance) M"
        return cell
    }
    
    
}
