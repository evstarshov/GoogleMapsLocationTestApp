//
//  LoginViewController.swift
//  GoogleMapsLocationTestApp
//
//  Created by Евгений Старшов on 20.05.2022.
//

import UIKit
import Realm
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: Properties
    
    private let database = RealmDB()
    private var users: Results<User>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
        configureLoginBindings()
        print("Realm file is here: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    // MARK: IBActions
    
    @IBAction func loginButtonTapped() {
        guard loginTextField.text != "" && passwordTextField.text != "" else { showAlertEmptyFields(); return }
        guard let users = users else {
            return
        }
        if users.contains(where: { $0.login == loginTextField.text && $0.password == passwordTextField.text?.sha1() }) {
            checkLogin()
        } else {
            showAlert()
        }
    }
    
    @IBAction func signUpButtonTapped() {
        let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signVC") as! SignUpViewController
        signVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(signVC, animated: true)
    }
    
    // MARK: Private methods
    
    private func loadUsers() {
        users = database.loadUsers()
    }
    
    private func checkLogin() {
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") as! ViewController
        mainVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    private func showAlert() {
        let alertVC = UIAlertController(title: "Error", message: "Login or password is incorrect!", preferredStyle: .alert)
        let alertItem = UIAlertAction(title: "Ok", style: .cancel)
        alertVC.addAction(alertItem)
        present(alertVC, animated: true)
    }
    
    private func showAlertEmptyFields() {
        let alertVC = UIAlertController(title: "Error", message: "Login or password fields should not be empty!", preferredStyle: .alert)
        let alertItem = UIAlertAction(title: "Ok", style: .cancel)
        alertVC.addAction(alertItem)
        present(alertVC, animated: true)
    }
    
    private func configureLoginBindings() {
        Observable
            .combineLatest(loginTextField.rx.text, passwordTextField.rx.text)
            .map { login, password in
                return !(login ?? "").isEmpty && !(password ?? "").isEmpty
            }
            .bind { [weak loginButton] inputFilled in
                loginButton?.isEnabled = inputFilled
            }
    }
}
