//
//  MUser.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 1/17/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import Foundation
import FirebaseAuth

class MUser {

    let objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var purchasedItemIds: [String]

    var fullAdress: String?
    var onBoard: Bool

    //MARK: - Initializers

    init(_objectId: String, _email: String, _firstName: String, _lastName: String) {
        objectId = _objectId
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + " " + _lastName
        fullAdress = ""
        onBoard = false
        purchasedItemIds = []
    }

    init(_dictionary: NSDictionary) {
        objectId = _dictionary[KOBJECTID] as! String
        if let mail = _dictionary[KEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }

        if let fname = _dictionary[KFIRSTNAME] {
            firstName = fname as! String
        } else {
            firstName = ""
        }

        if let lname = _dictionary[KLASTNAME] {
            lastName = lname as! String
        } else {
            lastName = ""
        }

        fullName = firstName + " " + lastName

        if let faddress = _dictionary[KFULLADDRESS] {
            fullAdress = faddress as? String
        } else {
            fullAdress = ""
        }

        if let onB = _dictionary[KONBOARD] {
            onBoard = onB as! Bool
        } else {
            onBoard = false
        }

        if let purchaseIds = _dictionary[KPURCHASEDITEMSIDS] {
            purchasedItemIds = purchaseIds as! [String]
        } else {
            purchasedItemIds = []
        }
    }

    //MARK: - Return current user
    class func currentID() -> String {
        return Auth.auth().currentUser!.uid
    }

    class func currentUser() -> MUser? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: KCURRENTUSER) {
                return MUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }

    //MARK: - Login func

    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if (error == nil) {
                if (authDataResult?.user.isEmailVerified == true) {
                    downloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
                    completion(error, true)
                } else {
                    print("email is not verified")
                    completion(error, false)
                }
            } else {
                completion(error, false)
            }
        }
    }

    //MARK: - Register user
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            completion(error)
            if (error == nil) {
                //Send email verification
                authDataResult?.user.sendEmailVerification(completion: { (error) in
                    print("auth email veriffication error: \(error?.localizedDescription)")
                })
            }
        }
    }

    //MARK: - Resend link methods

    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }

    class func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                print("resend Email errorb \(error?.localizedDescription)")
                completion(error)
            })
        })
    }

    class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: KCURRENTUSER)
            UserDefaults.standard.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }

    }

}


//MARK: - DownloadUser

func downloadUserFromFirestore(userId: String, email: String) {

    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if snapshot.exists {
            print("download current  user from firestore")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            //there is no user, save new in firestore
            let user = MUser(_objectId: userId, _email: email, _firstName: "", _lastName: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
        }
    }

}

//MARK: - Save user to firebase

func saveUserToFirestore(mUser: MUser) {
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String: Any]) { (error) in
        if (error != nil) {
            print("error saving user \(error?.localizedDescription)")
        }
    }
}

func saveUserLocally(mUserDictionary: NSDictionary) {
    UserDefaults.standard.setValue(mUserDictionary, forKey: KCURRENTUSER)
    UserDefaults.standard.synchronize()
}

//MARK: - Helper Function

func userDictionaryFrom(user: MUser) -> NSDictionary {
    return NSDictionary(objects: [user.objectId, user.email, user.firstName, user.lastName, user.fullName, user.fullAdress ?? "", user.onBoard, user.purchasedItemIds], forKeys: [KOBJECTID as NSCopying, KEMAIL as NSCopying, KFIRSTNAME as NSCopying, KLASTNAME as NSCopying, KFULLNAME as NSCopying, KFULLADDRESS as NSCopying, KONBOARD as NSCopying, KPURCHASEDITEMSIDS as NSCopying])
}

//MARK: - Update User

func updateCurrentUserInFirestore(withValues: [String : Any], completion: @escaping(_ error: Error?) -> Void) {
    if let dictionnary = UserDefaults.standard.object(forKey: KCURRENTUSER) {
        let userObject = (dictionnary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        FirebaseReference(.User).document(MUser.currentID()).updateData(withValues) { (error) in
            completion(error)
            if (error == nil) {
                saveUserLocally(mUserDictionary: userObject)
            }
        }
    }
}
