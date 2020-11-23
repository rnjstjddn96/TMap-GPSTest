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
import NVActivityIndicatorView


class ViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let btnNMap: UIButton = {
        let btn = UIButton()
        btn.setTitle("to NaverMap", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let btnTMap: UIButton = {
        let btn = UIButton()
        btn.setTitle("to TMap", for: .normal)
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
        view.addSubview(btnNMap)
        view.addSubview(btnTMap)
        
        btnTMap.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -view.frame.height/4).isActive = true
        btnTMap.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnTMap.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnTMap.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        btnNMap.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height/4).isActive = true
        btnNMap.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnNMap.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnNMap.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        
        btnNMap.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let mapViewController = NaverMapViewController()
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }).disposed(by: disposeBag)
        
        btnTMap.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let mapViewController = TMapViewController()
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }).disposed(by: disposeBag)
    }
}

