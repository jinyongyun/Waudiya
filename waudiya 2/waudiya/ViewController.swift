//
//  ViewController.swift
//  waudiya
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var promises = [Promise](){
        didSet {
            self.savePromiseList()
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.loadPromiseList()
    }
    
    
    private func configureTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let WriteCellViewController = segue.destination as? WriteCellViewController {
            WriteCellViewController.delegate = self
            
        }
    }
    
    private func savePromiseList(){
        let date = self.promises.map {
            [
                "title": $0.title,
                "detailcontent": $0.detailcontent,
                "datetime": $0.datetime,
                "location": $0.location,
                "isStar": $0.isStar
            ]
            
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "promises")
    }
    
    private func loadPromiseList(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "promises") as? [[String: Any]] else { return }
        self.promises = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let detailcontent = $0["detailcontent"] as? String else { return nil }
            guard let date = $0["datetime"] as? Date else { return nil }
            guard let location = $0["location"] as? MKMapItem else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Promise(title: title, detailcontent: detailcontent, datetime: date, location: location, isStar: isStar)
        }
    }
    
    private func dateToString(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
    
}


extension ViewController: UITableViewDelegate {
    
    
    
    
    
}



extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.promises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customcell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomCell else {return UITableViewCell() }
        let promise = self.promises[indexPath.row]
        customcell.title.text = promise.title
        customcell.location.text = promise.location.name
        customcell.datetime.text = self.dateToString(date: promise.datetime)
        

        return customcell
    }
    
}

extension ViewController: WriteCellViewDelegate {
    func didSelectRegister(promise: Promise) {
        self.promises.append(promise)
        self.tableView.reloadData()
    }
    
    
}
