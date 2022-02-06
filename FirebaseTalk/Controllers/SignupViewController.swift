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

class SignupViewController: UIViewController {
    
    @IBOutlet weak var email: HoshiTextField!
    @IBOutlet weak var name: HoshiTextField!
    @IBOutlet weak var password: HoshiTextField!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color : String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBar = UIView()
        
        let statusBarHeight = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 0
        
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(statusBarHeight)
        }
        
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        signup.backgroundColor = UIColor(hex: color)
        cancel.backgroundColor = UIColor(hex: color)
        
        signup.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancel.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    @objc func signupEvent() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!){ (result, err) in
            let uid = result?.user.uid
            
            Database.database().reference().child("users").child(uid!).setValue(["name":self.name.text!])
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
