//
//  HistoryVC.swift
//  GrainChain1
//
//  Created by José Cadena on 09/03/20.
//  Copyright © 2020 GranChain. All rights reserved.
//

import UIKit
import CoreData

class HistoryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var runs = [Run]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        runs = getRuns()
        tableView.reloadData()
    }
    
    func getRuns() -> [Run] {
        let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.startTime), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let runs = try CoreDataStack.context.fetch(fetchRequest)
            return runs
        } catch {
            return []
        }
    }
    

}

extension HistoryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! historyCell
        cell.setCell(runs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsID") as! DetailsVC
        vc.run = runs[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
