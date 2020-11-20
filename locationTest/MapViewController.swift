//
//  MapViewController.swift
//  locationTest
//
//  Created by imf-mini-3 on 2020/11/19.
//

import UIKit
import TMapSDK
import SnapKit
import NVActivityIndicatorView
import CoreLocation
import RxCocoa
import RxSwift

class MapViewController: UIViewController, NVActivityIndicatorViewable {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation? {
        didSet {
            if let latitude = self.currentLocation?.coordinate.latitude,
               let longitude = self.currentLocation?.coordinate.longitude {
                currentLocation2D = CLLocationCoordinate2D(latitude: latitude,
                                                           longitude: longitude)
            }
        }
    }
    var currentLocation2D: CLLocationCoordinate2D?
    
    var searchText: String = ""
    
    let pathData = TMapPathData()
    var POIDataArray: Array<TMapPoiItem> = []
    var POImarkers: Array<TMapMarker> = []
    
    var disposeBag = DisposeBag()
    
    let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let toolbar: UIToolbar = {
        let tb = UIToolbar()
        tb.backgroundColor = .white
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    let btnToCurLoc: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 5
        btn.backgroundColor = .white
        btn.setImage(UIImage(named: "currentLocation"), for: .normal)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowOffset = CGSize(width: 5, height: 5)
        btn.layer.shadowRadius = 5
        return btn
    }()
    
    let zoomButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowRadius = 5
        return view
    }()
    
    let btnZoomIn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.backgroundColor = .white
        btn.setImage(UIImage(named: "plus"), for: .normal)
//        btn.setTitle("+", for: .normal)
        return btn
    }()
    let btnZoomOut: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.backgroundColor = .white
//        btn.setTitle("-", for: .normal)
        btn.setImage(UIImage(named: "minus"), for: .normal)
        return btn
    }()
    
    
    
    var mapView: TMapView?
    
    var apiKey: String {
        get {
            return "l7xxbbbef76beb424cf3a1e5ee9872176621"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.addSubview(mapContainerView)
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { create in
            create.left.right.bottom.equalTo(view)
            create.height.equalTo(view).multipliedBy(0.1)
        }
        mapContainerView.snp.makeConstraints { create in
            create.left.right.equalToSuperview()
            create.bottom.equalTo(toolbar.snp.top)
            create.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        mapContainerView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setGPS(onComplete: { [weak self] in
            guard let self = self else { return }
            self.initToolbar()
            self.initMapView()
        })
    }

    func initSearchBar(view: UIView) {
        view.addSubview(self.searchBar)
        searchBar.snp.makeConstraints { create in
            create.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            create.left.right.equalToSuperview()
            
        }
    }
    
    func initCurrentLocationButton(view: UIView) {
        self.searchBar.delegate = self
        view.addSubview(self.btnToCurLoc)
        self.btnToCurLoc.snp.makeConstraints { create in
            create.left.equalToSuperview().offset(10)
            create.bottom.equalToSuperview().offset(-10)
            create.height.width.equalTo(self.toolbar.snp.height).multipliedBy(0.7)
        }
        btnToCurLoc.rx.tap.subscribe(onNext: {
            if let currentLocation = self.currentLocation2D {
                self.mapView?.setZoom(16)
                self.mapView?.animateTo(location: currentLocation)
    //            self.shootAPI(latitude: String(currentLocation.latitude), longitude: String(currentLocation.longitude))
            }
        }).disposed(by: disposeBag)
    }
    
    func initZoomButton(view: UIView) {
        var zoom = self.mapView?.getZoom() ?? 0
        
        view.addSubview(self.zoomButtonContainer)
        self.zoomButtonContainer.snp.makeConstraints { create in
            create.right.equalToSuperview().offset(-10)
            create.centerY.equalToSuperview()
            create.width.equalTo(btnToCurLoc)
            create.height.equalTo(btnToCurLoc).multipliedBy(2)
        }
        zoomButtonContainer.addSubview(btnZoomIn)
        zoomButtonContainer.addSubview(btnZoomOut)
        btnZoomIn.snp.makeConstraints { create in
            create.left.right.top.equalToSuperview()
            create.height.equalToSuperview().multipliedBy(0.5)
        }
        btnZoomOut.snp.makeConstraints { create in
            create.left.right.bottom.equalToSuperview()
            create.height.equalToSuperview().multipliedBy(0.5)
        }
        btnZoomIn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            zoom += 1
            self.mapView?.animateTo(zoom: zoom)
        }).disposed(by: disposeBag)
        btnZoomOut.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            zoom -= 1
            self.mapView?.animateTo(zoom: zoom)
        }).disposed(by: disposeBag)
    }
    
    func initToolbar() {
        let toolbarItem1 = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        let toolbarItem2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        //현재 위치로 이동
        toolbarItem1.rx.tap.subscribe(onNext: { _ in
            //액션 추가
            self.pathData.requestFindTitlePOI("상계역") { (items, error) in
                guard let _items = items else { return }
                for item in _items {
                    print("asdfasd: \(item.poiName)")
                }
            }
        }).disposed(by: disposeBag)
        toolbarItem2.rx.tap.subscribe(onNext: { _ in
            //액션 추가
        }).disposed(by: disposeBag)
        
        self.toolbar.setItems([spacer, toolbarItem1, spacer, toolbarItem2, spacer], animated: true)
    }
}

extension MapViewController: TMapViewDelegate {
    
    func initMapView() {
        mapContainerView.subviews.forEach { $0.removeFromSuperview() }
        self.mapView = TMapView(frame: self.mapContainerView.frame)
        self.mapView?.delegate = self
        self.mapView?.setApiKey(self.apiKey)
        guard let currentLocation = self.currentLocation2D else { return }
        guard let mapView = self.mapView else { return }
        mapView.setCenter(currentLocation)
        mapView.setZoom(16)
        
        mapContainerView.addSubview(mapView)
        self.initCurrentLocationButton(view: self.mapContainerView)
        self.initZoomButton(view: self.mapContainerView)
        self.initSearchBar(view: self.mapContainerView)
        mapContainerView.addSubview(loadingView)
        
//        교통정보 색으로 구분지어 제공
//        mapView.setTrafficMode(true)
//        mapView.trackinMode = .followWithCourse
        loadingView.snp.makeConstraints { create in
            create.left.right.top.bottom.equalTo(view)
        }
        startAnimating(message: "Loading", messageFont: UIFont.systemFont(ofSize: 20), type: .squareSpin, color: UIColor(red: 100, green: 100, blue: 100, alpha: 0.5), padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), textColor: .white)
    }
    
    func authorizationSuccess () {
        print("리것이 린증")
    }
    
    func authorizationFail () {
        print("리것이 린증 fail")
    }
    
    func SKTMapApikeySucceed() {
        print("나도 린증인데 뭔 린증이야,,?")
    }
    
    func SKTMapApikeyFailed(error: NSError?) {
        print("나도 린증인데 뭔 fail이야,,?: \(String(describing: error))")
    }
    
    public func mapViewDidFinishLoadingMap() {
        self.loadingView.isHidden = true
        self.loadingView.layoutIfNeeded()
        
        self.mapView?.animateTo(zoom: 16)
        stopAnimating()
    }
    
    public func mapViewDidChangeBounds() {
        // self.logLabel.text = "지도 영역 변경됨"
        print("mapViewdidChangeBounds")
    }
    
    //작동을 안 하는데 왜 된다고 하냐
//    func mapView(_ mapView: TMapView, shouldChangeFrom oldPosition: CLLocationCoordinate2D, to newPosition: CLLocationCoordinate2D) -> Bool {
//        print("oldPoistion: \(oldPosition)")
//        print("newPoistion: \(newPosition)")
//        return true
//    }
    
    func mapView(_ mapView: TMapView, tapOnMarker marker: TMapMarker) {
        // self.logLabel.text = "마커 터치됨"
    }
    
    func mapView(_ mapView: TMapView, singleTapOnMap location: CLLocationCoordinate2D) {
        // 지도 싱글 탭
        print("Single Tap on location: latitude: \(location.latitude), logitude: \(location.longitude) ")
        self.view.endEditing(true)
    }
    
    func mapView(_ mapView: TMapView, doubleTapOnMap location: CLLocationCoordinate2D) {
        print("Double Tap on location: latitude: \(location.latitude), logitude: \(location.longitude) ")
    }
    
    func mapView(_ mapView: TMapView, longTapOnMap location: CLLocationCoordinate2D) {
        print("Long Tap on location: latitude: \(location.latitude), logitude: \(location.longitude) ")
            let marker = TMapMarker(position: location)
            marker.map = self.mapView ?? TMapView()
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func setGPS(onComplete: @escaping (() -> Void)) {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
//      locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
//      이벤트 수신 단위 거리
//      locationManager.distanceFilter = 100
        
//      위치정보 한번만 요청
//      locationManager.requestLocation()
//      이벤트 수신 단위 거리에 따라 계속 요청
        locationManager.startUpdatingLocation()
//      자동으로 멈춤 방지
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        self.currentLocation = locationManager.location
        onComplete()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coor = manager.location?.coordinate {
//            print("latitude" + String(coor.latitude) + " longitude" + String(coor.longitude))
            let latitude = String(coor.latitude)
            let longitude = String(coor.longitude)
            shootAPI(latitude: latitude, longitude: longitude)
        }
        self.currentLocation = locations.last
    }
    
    func shootAPI(latitude: String, longitude: String) {
        let str = "http://192.168.0.40:8081/back"
        let data: [String: Any] = ["data": ["latitude": latitude, "logitude": longitude]]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        guard let url = URL(string: str) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print()
                print("err: \(error?.localizedDescription ?? "No Data")")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
        }
        task.resume()
    }
    
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("asdfawd")
        guard let text = searchBar.text else { return }
        self.searchText = text
        self.pathData.requestFindTitlePOI(text) { results, error in
            print("text: \(text)")
            guard let _results = results else { return }
            DispatchQueue.main.async {
                self.mapView?.setCenter(_results.first?.coordinate ?? CLLocationCoordinate2D())
                for result in _results {
                    guard let coord = result.coordinate else { return }
                    let marker = TMapMarker(position: coord)
                    marker.map = self.mapView
                    self.POImarkers.append(marker)
                }
            }
            
            
        }
        self.view.endEditing(true)
    }
}

