//
//  LocationSearchViewController.swift
//  waudiya
//
//  Created by mac on 2022/08/08.
//

import UIKit
import MapKit

protocol LocationSearchViewControllerDelegate: AnyObject {
    func sendData(location: MKMapItem)
}


class LocationSearchViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    private var searchCompleter: MKLocalSearchCompleter?
    private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    var completerResults: [MKLocalSearchCompletion]?
    
    private var places: MKMapItem? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var localSearch: MKLocalSearch? {
        willSet {
            places = nil
            localSearch?.cancel()
            
        }
    }
    
    weak var delegate: LocationSearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.resultTypes = .address
        searchCompleter?.region = searchRegion
    }


 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchCompleter = nil
    }


    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }

    private func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = searchRegion
        
        searchRequest.resultTypes = .pointOfInterest
        
        localSearch = MKLocalSearch(request: searchRequest)
        
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                return
            }
            self.places = response?.mapItems[0]
            print(places?.placemark.coordinate as Any)
            self.delegate?.sendData(location: places!) // 여기 수정 가능성
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

}

extension LocationSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            
            completerResults = nil
        }
        
        searchCompleter?.queryFragment = searchText
    }
    
    
}

extension LocationSearchViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}

extension LocationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let suggestion = completerResults?[indexPath.row] {
            search(for: suggestion)
        }
    }
    
    
}

extension LocationSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? Cell else { return UITableViewCell() }
                
                if let suggestion = completerResults?[indexPath.row] {
                    cell.titleLabel.text = suggestion.title
                    cell.subtitleLabel.text = suggestion.subtitle
                    
                }
        return cell
    }
    
    
    
    
    
    
}
