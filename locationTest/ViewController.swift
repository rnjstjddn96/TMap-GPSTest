//
//  ViewController.swift
//  locationTest
//
//  Created by imf-mini-3 on 2020/11/17.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa


class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    var latitude: String = ""
    var longitude: String = ""
    var currentLocation: CLLocation?
    
    var disposeBag = DisposeBag()
    
    let button: UIButton = {
        let btn = UIButton()
        btn.setTitle("shootAPI", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let btnMap: UIButton = {
        let btn = UIButton()
        btn.setTitle("to Map", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        view.addSubview(button)
        view.addSubview(btnMap)
        
        btnMap.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -view.frame.height/4).isActive = true
        btnMap.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnMap.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnMap.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height/4).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.shootAPI(latitude: self.latitude, longitude: self.longitude)
        }).disposed(by: disposeBag)
        
        btnMap.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let mapViewController = MapViewController()
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }).disposed(by: disposeBag)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
//      이벤트 수신 단위 거리
//      locationManager.distanceFilter = 100
        

//      locationManager.requestWhenInUseAuthorization()
        
//      위치정보 한번만 요청
//      locationManager.requestLocation()
//      이벤트 수신 단위 거리에 따라 계속 요청
        locationManager.startUpdatingLocation()
//      자동으로 멈춤 방지
        locationManager.pausesLocationUpdatesAutomatically = false
    
        locationManager.allowsBackgroundLocationUpdates = true
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coor = manager.location?.coordinate {
//            print("latitude" + String(coor.latitude) + " longitude" + String(coor.longitude))
            self.latitude = String(coor.latitude)
            self.longitude = String(coor.longitude)
            shootAPI(latitude: latitude, longitude: longitude)
        }
        self.currentLocation = locations.last
    }
    
    func shootAPI(latitude: String, longitude: String) {
        print("shoot")
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

