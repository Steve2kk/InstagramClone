//
//  ViewController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 14.01.2021.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    let addPhotoBtn:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email:"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username:"
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
    
    let signupButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    let alreadyHaveAnAccountButton: UIButton = {
        let button = UIButton(type: .system )
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        let secondAttribute = NSMutableAttributedString(string: "Sign In.", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
        attributedTitle.append(secondAttribute)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleMoveToSignIn), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.hasText &&
            usernameTextField.hasText && passwordTextField.hasText
        
        if isFormValid {
            print(isFormValid)
            signupButton.isEnabled = true
            signupButton.backgroundColor = UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        }
    }
    
    @objc func handleMoveToSignIn() {
        navigationController?.popViewController(animated: true)
    }
    
    var profileImage: String?
    @objc func handleAddProfilePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            addPhotoBtn.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            addPhotoBtn.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        addPhotoBtn.layer.cornerRadius = addPhotoBtn.frame.width / 2
        addPhotoBtn.layer.masksToBounds = true
        addPhotoBtn.layer.borderColor = UIColor.init(white: 1, alpha: 0.03).cgColor
        addPhotoBtn.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text,email.count > 0 else {return}
        guard let username = usernameTextField.text,username.count > 0 else {return}
        guard let password = passwordTextField.text,password.count > 0 else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult: AuthDataResult?, error: Error?) in
            if let err = error {
                print("Failed to create a user: ",err)
            }
            guard let uid = authDataResult?.user.uid else {return}
            print("User created success",uid)
            
            guard let image = self.addPhotoBtn.imageView?.image else {return}
            guard let uploadData = image.jpegData(compressionQuality: 0.3 ) else {return}
            
            let storageRef = Storage.storage().reference().child("profile_images")
            let fileName = NSUUID().uuidString
            let riversRef = storageRef.child(fileName)

            riversRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if let err = error {
                    print("Failed to save profile photo: ",err)
                    return
                }
                print("Successfully upload profile image to storage")
                
                riversRef.downloadURL { (url, err) in
                    if let error = err {
                        print("Fail to download url",error)
                        return
                    }
                    let urlString = url?.absoluteString
                    let dictionaryValues = [
                        "username": username,
                        "profile_image": urlString
                    ]
                    let values = [uid:dictionaryValues]
                    self.saveToDatabaseUserInfo(values: values)
                    guard let mainTabBarController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController as? MainTabBarController else {return}
                    
                    mainTabBarController.setupUIAndViewControllers()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    fileprivate func saveToDatabaseUserInfo(values: [String: Any]) {
        Database.database().reference().child("users").updateChildValues(values) { (err, ref) in
            if let error = err {
                print("Failed to save user info: ",error)
            }
            print("Succesfully saved user into database",ref)
    }
    }
    
    fileprivate func setupUI() {
        view.addSubview(addPhotoBtn)
        addPhotoBtn.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        addPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,usernameTextField,passwordTextField,signupButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: addPhotoBtn.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
        
        view.addSubview(alreadyHaveAnAccountButton)
        alreadyHaveAnAccountButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -30, paddingRight: 0, width: 0, height: 40)
        alreadyHaveAnAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

