# Waudiya
워디여 앱

###진행상황###


##만든 과정##

main.storyboard에서 인터페이스 구성

![스크린샷 2022-08-27 오후 3 31 12](https://user-images.githubusercontent.com/102133961/187018113-cb225477-1f61-4dd4-be44-c02f83e51645.jpg)

##기능상세##

사용자가 지정한 위치 인근에 도달할 시 알람 또는 진동

사용자와 지정 위치 거리 간격 설정 가능

현재는 위치 검색 기능과 자동 완성 기능까지 구현 완료 (2022.8.27)

:: 정확한 위치 상세 등록이 불가능해서, MapKit를 이용해 핀으로 위치를 직접 지정할 수 있는 네비게이션을 만들 예정

##위치검색서비스 코드##

import UIKit
import MapKit

protocol LocationSearchViewControllerDelegate: AnyObject {
    func sendData(locationName: String, longitude: String, latitude: String)
}


class LocationSearchViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    var mapView: MKMapView!
    
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
        searchCompleter?.resultTypes = .pointOfInterest
        searchCompleter?.region = searchRegion
        searchbar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
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
            let longitudeex : String
            let latitudeex: String
            longitudeex = String((places?.placemark.coordinate.longitude)!)
            latitudeex = String((places?.placemark.coordinate.latitude)!)
            // 여기 수정 가능성
            
            self.delegate?.sendData(locationName: (places?.name)!, longitude: longitudeex, latitude: latitudeex)
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


구현하느라 진땀 뺏다.

제일 힘들었던 점은 userDefault에 해당 MKMapItem 객체를 통쩨로 넘겨주고 저장할 수 없단 거였는데

그냥 선택한 MKMapItem 안에 있는 위도 경도 그리고 위치 정보만 (String) 가져와서 넘겨주는 식으로 해결했다.

뷰 컨트롤러가 많다 보니, 서로 이동 과정에서 저장버튼이 나타나지 않고, 수정 버튼이 눌리지 않거나, 즐겨찾기가 되어있는 메모가 수정화면으로 돌아갔을 땐 즐겨찾기가 강제 해제되는 문제가 발생했다.

그래서 뷰 연계 절차를 옵저버를 이용한 방식으로 바꿨더니 해결됐다.

