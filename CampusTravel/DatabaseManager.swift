//
//  DatabaseManager.swift
//  
//
//  Created by Andrew Mo on 8/23/20.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    public func userExists(with email: String, completion: @escaping((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func insertUser(with user: User) {
        database.child("Users").child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "phone_number": user.phoneNumber
        ])
    }
}

struct User {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let phoneNumber: String
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
