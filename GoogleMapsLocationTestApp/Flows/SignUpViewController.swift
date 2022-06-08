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
    
    
    // MARK: Properties
    
    private let database = RealmDB()
    private var users: Results<User>?
    private var usertoDB = [User]()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        users = database.loadUsers()
        print("Realm file is here: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    // MARK: IBAction func
    
    @IBAction func signUpButtonTapped() {
        signNewUser()
    }
    
    @IBAction func takePictureButtonTapped() {
        print("Image button tapped")
        takePicture()
    }
    
    // MARK: Private methods
    
    private func signNewUser() {
        print("sign new user")
        guard loginTextField.text != "" && passwordTextField.text != "" && confirmPassword.text != "" && confirmPassword.text == passwordTextField.text else { showAlert(); return }
        guard let users = users else { return }
        if users.contains(where: { $0.login == loginTextField.text }) == true {
            showAlertUserisinDB()
        } else {
            usertoDB.append(User(login: loginTextField.text!, password: passwordTextField.text!.sha1()))
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
            let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            self?.navigationController?.present(loginVC, animated: true)
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
    
    private func takePicture() {
        print("Trying to take picture")
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
            return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
}

// MARK: Image picker controller extension delegate

extension SignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = extractImage(from: info)
        print(image!)
        picker.dismiss(animated: true)
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}
