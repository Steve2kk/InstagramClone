//
//  LoginViewController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 31.01.2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let headerContainer:UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.init(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white").withRenderingMode(.alwaysOriginal))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email:"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password:"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let loginButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    let moveToSignUpButton: UIButton = {
        let button = UIButton(type: .system )
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        let secondAttribute = NSMutableAttributedString(string: "Sign Up.", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
        attributedTitle.append(secondAttribute)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleMoveToSignUp), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.addSubview(moveToSignUpButton)
        moveToSignUpButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 40)
        moveToSignUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(headerContainer)
        headerContainer.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 200)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: headerContainer.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 150)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err {
                print("Failed to login with email: ",err)
                return
            }
            
            print("Succefully logged in with uid: ",user?.user.uid ?? "")
            guard let mainTabBarController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setupUIAndViewControllers()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleMoveToSignUp() {
       let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.hasText &&
             passwordTextField.hasText
        
        if isFormValid {
            print(isFormValid)
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        }
    }
    
   
}
