//
//  TestViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/24/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit

class MineViewController: UIViewController {
    
    var currentListing: Listing?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let destination: UILabel = {
        let phone = UILabel()
        phone.textAlignment = .center
        phone.font = .systemFont(ofSize: 20, weight: .bold)
        return phone
    }()
    
    private let time: UILabel = {
        let time = UILabel()
        time.textAlignment = .center
        time.font = .systemFont(ofSize: 20, weight: .bold)
        return time
    }()
    
    private let meeting: UILabel = {
        let meeting = UILabel()
        meeting.textAlignment = .center
        meeting.font = .systemFont(ofSize: 20, weight: .bold)
        return meeting
    }()
    
    private let phone: UILabel = {
        let phone = UILabel()
        phone.textAlignment = .center
        phone.font = .systemFont(ofSize: 20, weight: .bold)
        return phone
    }()
    
    private let accept: UIButton = {
        let accept = UIButton(frame: CGRect(x: 30, y: 500, width: 100, height: 52))
        accept.setTitle("Accept", for: .normal)
        accept.setTitleColor(.white, for: .normal)
        accept.backgroundColor = .link
        accept.layer.cornerRadius = 12
        accept.layer.masksToBounds = true
        accept.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        accept.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        return accept
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(accept)
        // Do any additional setup after loading the view.
    }
    
    @objc func acceptTapped() {
        print("yesy")
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
