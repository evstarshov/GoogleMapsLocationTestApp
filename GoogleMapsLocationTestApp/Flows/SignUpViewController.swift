//
//  SignUpViewController.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 20.05.2022.
//

import UIKit
import Realm
import RealmSwift

class SignUpViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    
    
    // MARK: Properties
    
    private let database = RealmDB()
    private var users: Results<User>?
    private var usertoDB = [User]()
    private var imagePicker: ImagePicker!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        users = database.loadUsers()
        print("Realm file is here: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    // MARK: IBAction func
    
    @IBAction func signUpButtonTapped() {
        signNewUser()
    }
    
    @IBAction func takePictureButtonTapped(_ sender: Any) {
        self.imagePicker.present(from: sender as! UIView)
    }
    
    // MARK: Private methods
    
    private func signNewUser() {
        print("sign new user")
        guard loginTextField.text != "" && passwordTextField.text != "" && confirmPassword.text != "" && confirmPassword.text == passwordTextField.text else { showAlert(); return }
        guard let users = users else { return }
        if users.contains(where: { $0.login == loginTextField.text }) == true {
            showAlertUserisinDB()
        } else {
            let image = self.avatarImage.image
                usertoDB.append(User(login: loginTextField.text!, password: passwordTextField.text!.sha1(), imageData: (image?.toPngString()) ?? "camera"))
            database.save(usertoDB)
            showComfirmation()
        }
    }
    
    private func showAlert() {
        let alertVC = UIAlertController(title: "Error", message: "Login or password is empty, or password field and comfirm password field are not equal!", preferredStyle: .alert)
        let alertItem = UIAlertAction(title: "Ok", style: .cancel)
        alertVC.addAction(alertItem)
        present(alertVC, animated: true)
    }
    
    private func showComfirmation() {
        let alertVC = UIAlertController(title: "Registered!", message: "Succsessful registration", preferredStyle: .alert)
        let alertItem = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alertVC.addAction(alertItem)
        present(alertVC, animated: true)
    }
    
    private func showAlertUserisinDB() {
        let alertVC = UIAlertController(title: "Error!", message: "User already registered", preferredStyle: .alert)
        let alertItem = UIAlertAction(title: "Ok", style: .cancel)
        alertVC.addAction(alertItem)
        present(alertVC, animated: true)
    }
}

// MARK: Image picker controller extension delegate

extension SignUpViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.avatarImage.image = image
    }
}
