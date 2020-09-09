//
//  EditListingViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 9/4/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditListingViewController: UIViewController, UITextFieldDelegate {
    
    var currentListing: Listing?

    private var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(EditListingViewController.dateChanged(datePicker:)), for: .valueChanged)
        return datePicker
    }()
    
    private let time: UITextField = {
        let time = UITextField()
        time.textColor = .black
        time.layer.borderWidth = 1
        time.layer.borderColor = UIColor.lightGray.cgColor
        time.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        time.leftViewMode = .always
        time.backgroundColor = .white
        time.tintColor = .link
        return time
    }()
    
    private let destination: UITextField = {
        let destination = UITextField()
        destination.textColor = .black
        destination.layer.borderWidth = 1
        destination.layer.borderColor = UIColor.lightGray.cgColor
        destination.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        destination.leftViewMode = .always
        destination.backgroundColor = .white
        destination.tintColor = .link
        return destination
    }()
    
    private let meeting: UITextField = {
        let meeting = UITextField()
        meeting.textColor = .black
        meeting.layer.borderWidth = 1
        meeting.layer.borderColor = UIColor.lightGray.cgColor
        meeting.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        meeting.leftViewMode = .always
        meeting.backgroundColor = .white
        meeting.tintColor = .link
        return meeting
    }()
    
    private let submit: UIButton = {
        let submit = UIButton()
        submit.setTitle("Submit", for: .normal)
        submit.setTitleColor(.white, for: .normal)
        submit.backgroundColor = .black
        submit.layer.masksToBounds = true
        submit.titleLabel?.font = UIFont(name: "PerspectiveSans", size: 23)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return submit
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Edit Listing"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteListing))
        navigationItem.rightBarButtonItem?.tintColor = .red
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditListingViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        let destinationPlaceholder = NSAttributedString(string: currentListing!.destination, attributes: [NSAttributedString.Key.font: UIFont(name: "PerspectiveSans", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        destination.attributedPlaceholder = destinationPlaceholder
        let meetingPlaceholder = NSAttributedString(string: currentListing!.meeting, attributes: [NSAttributedString.Key.font: UIFont(name: "PerspectiveSans", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        meeting.attributedPlaceholder = meetingPlaceholder
        let timePlaceholder = NSAttributedString(string: currentListing!.time, attributes: [NSAttributedString.Key.font: UIFont(name: "PerspectiveSans", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        time.attributedPlaceholder = timePlaceholder
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
        submit.frame = CGRect(x: 30, y: 360, width: view.frame.width - 60, height: 45)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case destination:
            textField.resignFirstResponder()
            time.becomeFirstResponder()
        case meeting:
            textField.resignFirstResponder()
            submitTapped()
        default:
            break
        }
        return true
    }
    
    @IBAction private func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteListing() {
        let confirm = UIAlertController(title: "Are You Sure?", message: "This action cannot be undone", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            Database.database().reference().child("Listings").child(strongSelf.currentListing!.listingID).removeValue()
            strongSelf.navigationController?.popToRootViewController(animated: true)
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        confirm.addAction(yes)
        confirm.addAction(no)
        present(confirm, animated: true, completion: nil)
    }
    
    @objc private func submitTapped() {
        destination.resignFirstResponder()
        time.resignFirstResponder()
        meeting.resignFirstResponder()
        if destination.text != "" {
            Database.database().reference().child("Listings").child(currentListing!.listingID).child("destination").setValue(destination.text)
        }
        if time.text != "" {
            Database.database().reference().child("Listings").child(currentListing!.listingID).child("time_date").setValue(time.text)
        }
        if meeting.text != "" {
            Database.database().reference().child("Listings").child(currentListing!.listingID).child("meeting_location").setValue(meeting.text)
        }
        navigationController?.popToRootViewController(animated: true)
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
