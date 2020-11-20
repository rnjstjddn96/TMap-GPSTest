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
    
    
    let button: UIButton = {
        let btn = UIButton()
        btn.setTitle("IndicatorShows", for: .normal)
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
//            self.indicatorView.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                self.indicatorView.stopAnimating()
            })
        }).disposed(by: disposeBag)
        
        btnMap.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let mapViewController = MapViewController()
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }).disposed(by: disposeBag)
    }
}

