//
//  SignupViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/01/23.
//

import UIKit
import SnapKit
import Firebase
import TextFieldEffects
import FirebaseStorage

class SignupViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var email: HoshiTextField?
    @IBOutlet private weak var name: HoshiTextField?
    @IBOutlet private weak var password: HoshiTextField?
    @IBOutlet private weak var signup: UIButton?
    @IBOutlet private weak var cancel: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBar = UIView()
        
        let statusBarHeight = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 0
        
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(statusBarHeight)
        }
        
        let remoteConfig = RemoteConfig.remoteConfig()
        guard let color = remoteConfig.getBackGroundColor(remoteConfig) else { return }
        
        statusBar.backgroundColor = color
        
        imageView?.isUserInteractionEnabled = true
        imageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        signup?.backgroundColor = color
        cancel?.backgroundColor = color
        
        signup?.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancel?.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    @objc func signupEvent() {
        guard let emailText = email?.text else { return }
        guard let passwordText = password?.text else { return }
        guard let nameText = name?.text else { return }
        
        Auth.auth().createUser(withEmail: emailText, password: passwordText) { result, _ in
            let uid = result?.user.uid
            let image = self.imageView?.image?.jpegData(compressionQuality: 0.1)
            
            let imageRef = Storage.storage().reference().child("userImages").child(uid!)
            imageRef.putData(image!, metadata: nil) { _, _ in
                imageRef.downloadURL { url, _ in
                    guard let imgURL = url else {
                        print("image upload fail")
                        return
                    }
                    print("image upload success")
                    Database.database().reference().child("users").child(uid!)
                        .setValue(["userName": nameText, "profileImageURL": imgURL.absoluteString])
                }
            }
            
        }
    }
    
    @objc func cancelEvent() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imageView?.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
}
