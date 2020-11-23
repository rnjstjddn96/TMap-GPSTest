//
//  NaverMapViewController.swift
//  locationTest
//
//  Created by imf-mini-3 on 2020/11/23.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import CoreLocation
import RxCocoa
import RxSwift

class NaverMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    let rectView: UIButton = {
        let view = UIButton()
        view.backgroundColor = .yellow
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
//        view.addSubview(rectView)
//        rectView.addTarget(self, action: #selector(animate), for: .touchUpInside)
//        rectView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.height.width.equalTo(50)
//        }
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        animate(someView: self.rectView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.snp.top)
            make.height.equalToSuperview()
        }
    }
    
    @objc func animate() {
        UIView.animate(withDuration: 2.0) {
            self.rectView.backgroundColor = .black
            self.rectView.snp.remakeConstraints { update in
                update.height.width.equalTo(100)
                update.left.equalToSuperview()
                update.top.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "dummy cell"
        return cell
    }
}
