//
//  AddViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(AddViewController.dateChanged(datePicker:)), for: .valueChanged)
        return datePicker
    }()
    
    private let time: UITextField = {
        let time = UITextField()
        time.layer.cornerRadius = 12
        time.layer.borderWidth = 1
        time.layer.borderColor = UIColor.lightGray.cgColor
        time.placeholder = "Enter a time"
        time.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        time.leftViewMode = .always
        time.backgroundColor = .white
        return time
    }()
    
    private let destination: UITextField = {
        let destination = UITextField()
        destination.returnKeyType = .continue
        destination.layer.cornerRadius = 12
        destination.layer.borderWidth = 1
        destination.layer.borderColor = UIColor.lightGray.cgColor
        destination.placeholder = "Enter a destination"
        destination.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        destination.leftViewMode = .always
        destination.backgroundColor = .white
        return destination
    }()
    
    private let meeting: UITextField = {
        let meeting = UITextField()
        meeting.returnKeyType = .continue
        meeting.layer.cornerRadius = 12
        meeting.layer.borderWidth = 1
        meeting.layer.borderColor = UIColor.lightGray.cgColor
        meeting.placeholder = "Enter a meeting location"
        meeting.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        meeting.leftViewMode = .always
        meeting.backgroundColor = .white
        return meeting
    }()
    
    private let submit: UIButton = {
        let submit = UIButton()
        submit.setTitle("Submit", for: .normal)
        submit.setTitleColor(.white, for: .normal)
        submit.backgroundColor = .link
        submit.layer.cornerRadius = 12
        submit.layer.masksToBounds = true
        submit.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        submit.addTarget(self, action: #selector(add), for: .touchUpInside)
        return submit
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        time.inputView = datePicker
        view.addSubview(time)
        view.addSubview(destination)
        view.addSubview(meeting)
        view.addSubview(submit)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        time.frame = CGRect(x: 30, y: 200, width: scrollView.frame.width - 60, height: 52)
        destination.frame = CGRect(x: 30, y: 260, width: scrollView.frame.width - 60, height: 52)
        meeting.frame = CGRect(x: 30, y: 320, width: scrollView.frame.width - 60, height: 52)
        submit.frame = CGRect(x: 30, y: 380, width: scrollView.frame.width - 60, height: 52)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func add() {
        self.dismiss(animated: true, completion: nil)
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        Database.database().reference().child("Listings").childByAutoId().setValue([
            "email": safeEmail,
            "destination": destination.text!,
            "time_date": time.text!,
            "meeting_location": meeting.text!
        ])
        
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm E, d MMM y"
        time.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
