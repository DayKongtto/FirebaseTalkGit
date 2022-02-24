//
//  LoginViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2021/10/17.
//

import UIKit
import SnapKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak private var email: UITextField?
    @IBOutlet weak private var password: UITextField?
    @IBOutlet weak private var loginButton: UIButton?
    @IBOutlet weak private var signupButton: UIButton?
    
    //let remoteConfig = RemoteConfig.remoteConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard (try? Auth.auth().signOut()) != nil else { return }
        
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
        loginButton?.backgroundColor = color
        signupButton?.backgroundColor = color
        
        signupButton?.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        loginButton?.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { _, user in
            if user == nil { return }
            
            guard let view = self.storyboard?
                    .instantiateViewController(withIdentifier: "MainViewTabbarController")
                    as? UITabBarController else { return }
            view.modalPresentationStyle = .fullScreen
            self.present(view, animated: true, completion: nil)
        }
    }
    
    @objc func loginEvent() {
        guard let emailText = email?.text else { return }
        guard let passwordText = password?.text else { return }
        
        Auth.auth().signIn(withEmail: emailText, password: passwordText) { _, err in
            if err == nil { return }
            let alert = UIAlertController(title: "에러",
                                          message: err.debugDescription,
                                          preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
            self.present( alert, animated: true, completion: nil)
        }
    }
    
    @objc func presentSignup() {
        guard let view = self.storyboard?
                .instantiateViewController(withIdentifier: "SignupViewController")
                as? SignupViewController else { return }
        view.modalPresentationStyle = .fullScreen
        self.present(view, animated: true, completion: nil)
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
