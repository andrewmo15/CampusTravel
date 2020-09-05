//
//  AddViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddViewController: UIViewController, UITextFieldDelegate {
    
    private var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(AddViewController.dateChanged(datePicker:)), for: .valueChanged)
        return datePicker
    }()
    
    private let time: UITextField = {
        let time = UITextField()
        time.textColor = .black
        time.layer.cornerRadius = 12
        time.layer.borderWidth = 1
        time.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter a departure time", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        time.attributedPlaceholder = placeholderText
        time.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        time.leftViewMode = .always
        time.backgroundColor = .white
        return time
    }()
    
    private let destination: UITextField = {
        let destination = UITextField()
        destination.textColor = .black
        destination.layer.cornerRadius = 12
        destination.layer.borderWidth = 1
        destination.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter a destination", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        destination.attributedPlaceholder = placeholderText
        destination.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        destination.leftViewMode = .always
        destination.backgroundColor = .white
        return destination
    }()
    
    private let meeting: UITextField = {
        let meeting = UITextField()
        meeting.textColor = .black
        meeting.layer.cornerRadius = 12
        meeting.layer.borderWidth = 1
        meeting.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter a meeting location", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        meeting.attributedPlaceholder = placeholderText
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        destination.delegate = self
        meeting.delegate = self
        time.inputView = datePicker
        view.addSubview(time)
        view.addSubview(destination)
        view.addSubview(meeting)
        view.addSubview(submit)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        destination.frame = CGRect(x: 30, y: 150, width: view.frame.width - 60, height: 52)
        time.frame = CGRect(x: 30, y: 220, width: view.frame.width - 60, height: 52)
        meeting.frame = CGRect(x: 30, y: 290, width: view.frame.width - 60, height: 52)
        submit.frame = CGRect(x: 30, y: 360, width: view.frame.width - 60, height: 52)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case destination:
            textField.resignFirstResponder()
            time.becomeFirstResponder()
        case meeting:
            textField.resignFirstResponder()
            add()
        default:
            break
        }
        return true
    }
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func add() {
        time.resignFirstResponder()
        destination.resignFirstResponder()
        meeting.resignFirstResponder()
        if destination.text!.isEmpty || time.text!.isEmpty || meeting.text!.isEmpty {
            let alert = UIAlertController(title: "Whoops!", message: "Please fill in all information!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else {
            Database.database().reference().child("Listings").childByAutoId().setValue([
                "email": UserDefaults.standard.object(forKey: "SafeEmail") as? String ?? " ",
                "destination": destination.text!,
                "time_date": time.text!,
                "meeting_location": meeting.text!
            ])
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/yyyy, h:mm a"
        time.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc private func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
