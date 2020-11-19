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
import RxCocoa
import RxSwift

class MapViewController: UIViewController, NVActivityIndicatorViewable {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var latitude: String = ""
    var longitude: String = ""
    
    var disposeBag = DisposeBag()
    let indicatorView = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 100, height: 100), type: .ballClipRotatePulse, color: .white, padding: 0)
    
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
    
    var mapView: TMapView?
    var apiKey: String {
        get {
            return "l7xxbbbef76beb424cf3a1e5ee9872176621"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(mapContainerView)
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { create in
            create.left.right.bottom.equalTo(view)
            create.height.equalTo(view).multipliedBy(0.1)
        }
        mapContainerView.snp.makeConstraints { create in
            create.left.right.top.equalToSuperview()
            create.bottom.equalTo(toolbar.snp.top)
        }
        
        mapContainerView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setGPS()
        initMapView()
    }
    
    func initToolbar() {
        let toolbarItem1 = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: nil)
        let toolbarItem2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbarItem1.rx.tap.subscribe(onNext: { _ in
            let latitude = self.currentLocation?.coordinate.latitude
            let longitude = self.currentLocation?.coordinate.longitude
//            print("latitude: \(latitude), longitude: \(longitude)")
            if let _latitude = latitude, let _longitude = longitude {
                self.mapView?.animateTo(location: CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude))
                self.shootAPI(latitude: String(_latitude), longitude: String(_longitude))
            }
        }).disposed(by: disposeBag)
        toolbarItem2.rx.tap.subscribe(onNext: { _ in
            //액션 추가
        }).disposed(by: disposeBag)
        
        self.toolbar.setItems([spacer, toolbarItem1, spacer, toolbarItem2, spacer], animated: true)
    }
    
    func initMapView() {
//        mapContainerView.subviews.forEach { $0.removeFromSuperview() }
        initToolbar()
        self.mapView = TMapView(frame: self.mapContainerView.frame)
        self.mapView?.delegate = self
        self.mapView?.setApiKey(self.apiKey)
        guard let mapView = self.mapView else { return }
        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(loadingView)
        loadingView.addSubview(indicatorView)
        
        loadingView.snp.makeConstraints { create in
            create.left.right.top.bottom.equalTo(mapView)
        }
        startAnimating()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MapViewController: TMapViewDelegate {
    
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
        UIView.animate(withDuration: 0.5) {
            self.loadingView.isHidden = true
            self.loadingView.layoutIfNeeded()
        }
        self.mapView?.animateTo(zoom: 16)
        stopAnimating()
        print("나 끝났다 여기로와봐")
    }
    
    public func mapViewDidChangeBounds() {
        // self.logLabel.text = "지도 영역 변경됨"
//        stopAnimating()
        print("mapViewdidChangeBounds")
    }
    
    func mapView(_ mapView: TMapView, tapOnMarker marker: TMapMarker) {
        // self.logLabel.text = "마커 터치됨"
    }
    
    func mapView(_ mapView: TMapView, doubleTapOnMap location: CLLocationCoordinate2D) {
        // self.logLabel.text = "지도 더블탭"
    }
    
    func mapView(_ mapView: TMapView, longTapOnMap location: CLLocationCoordinate2D) {
        // self.logLabel.text = "지도 롱탭"
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func setGPS() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
    
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coor = manager.location?.coordinate {
//            print("latitude" + String(coor.latitude) + " longitude" + String(coor.longitude))
//            self.latitude = String(coor.latitude)
//            self.longitude = String(coor.longitude)
//            shootAPI(latitude: latitude, longitude: longitude)
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
