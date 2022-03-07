//
//  ChatViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/04.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet private weak var sendButton: UIButton?
    @IBOutlet private weak var messageTextfield: UITextField?
    @IBOutlet private weak var tableView: UITableView?
    
    var destinationUid: String?
    
    var uid: String?
    var chatRoomUid: String?
    var userModel: UserModel?
    var comments: [ChatModel.Comments] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton?.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
//        let tap: UIGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setKeyboardNotification()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    func setKeyboardNotification() {
       
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(keyboardWillShow),
                                                name: UIResponder.keyboardWillShowNotification,
                                                object: nil)
         
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(keyboardWillHide),
                                                name: UIResponder.keyboardWillHideNotification,
                                                object: nil)
         
     }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
          if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                  let keyboardRectangle = keyboardFrame.cgRectValue
                  let keyboardHeight = keyboardRectangle.height
              UIView.animate(withDuration: 1) {
                  self.bottomConstraint?.constant = keyboardHeight
                  if self.comments.count > 0 {
                      self.tableView?.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0),
                                                  at: UITableView.ScrollPosition.bottom, animated: true)
                  }
              }
          }
      }
    
    @objc func keyboardWillHide(notification: NSNotification) {
            bottomConstraint?.constant = 10
       }
    
    @objc func createRoom() {
        guard let sUid = uid else { return }
        guard let sDestinationUid = destinationUid else { return }
        let createRoomInfo: [String: Any] = [
            "users": [
                sUid: true,
                sDestinationUid: true
            ]
        ]
        
        if chatRoomUid == nil {
            self.sendButton?.isEnabled = false
            Database.database().reference().child("chatRooms")
            .childByAutoId().setValue(createRoomInfo) { err, _ in
                    if err == nil { self.checkChatRoom() }
            }
        } else {
            guard let message = messageTextfield?.text else { return }
            let comment: [String: Any] = [
                "uid": sUid,
                "message": message,
                "timestamp": ServerValue.timestamp()
            ]
            
            Database.database().reference().child("chatRooms").child(chatRoomUid!)
                .child("comments").childByAutoId().setValue(comment) { _, _ in
                    self.messageTextfield?.text = ""
                    self.messageTextfield?.resignFirstResponder()
                }
        }
    }
    
    func checkChatRoom() {
        guard let cUid = uid else { return }
        guard let cDestinationUid = destinationUid else { return }
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/" + cUid)
            .observeSingleEvent(of: DataEventType.value) { dataSnapshot in
                guard let items = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for item in items {
                    guard let chatRoomDic = item.value as? [String: AnyObject] else { return }
                    guard let chatModel = ChatModel(JSON: chatRoomDic) else { return }
                    if chatModel.users[cDestinationUid] == true {
                        self.chatRoomUid = item.key
                        self.sendButton?.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
            }
    }
    
    func getDestinationInfo() {
        guard let gDestinationUid = destinationUid else { return }
        Database.database().reference().child("users").child(gDestinationUid)
            .observeSingleEvent(of: DataEventType.value) { dataSnapShot in
                self.userModel = UserModel()
                guard let snapShotValue = dataSnapShot.value as? [String: Any] else { return }
                self.userModel?.userName = snapShotValue["userName"] as? String
                self.userModel?.profileImageURL = snapShotValue["profileImageURL"] as? String
                self.userModel?.uid = snapShotValue["uid"] as? String
                self.getMessageList()
            }
    }
    
    func getMessageList() {
        guard let roomUid = chatRoomUid else { return }
        Database.database().reference().child("chatRooms").child(roomUid).child("comments")
            .observe(DataEventType.value) { dataSnapshot in
                self.comments.removeAll()
                guard let items = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for item in items {
                    guard let itemValue = item.value as? [String: AnyObject] else { return }
                    guard let comment = ChatModel.Comments(JSON: itemValue) else { return }
                    self.comments.append(comment)
                }
                self.tableView?.reloadData()
                
                if self.comments.count > 0 {
                    self.tableView?.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0),
                                                at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
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

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.comments[indexPath.row].uid == uid {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell",
                                                           for: indexPath)
                    as? MyMessageCell else { return UITableViewCell() }
            cell.nameLabel?.text = userModel?.userName
            cell.messageLabel?.text = comments[indexPath.row].message
            cell.messageLabel?.numberOfLines = 0
            
            guard let time = comments[indexPath.row].timestamp?.toDayTime else { return cell }
            cell.timestampLabel?.text = time
            
            guard let urlString = userModel?.profileImageURL else { return cell }
            guard let url = URL(string: urlString) else { return cell }
            guard let imageView = cell.profileImageView else { return cell }
                                
            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data!)
                    imageView.layer.cornerRadius = imageView.frame.size.width / 2
                    imageView.clipsToBounds = true
                }
            }).resume()
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell",
                                                           for: indexPath)
                    as? DestinationMessageCell else { return UITableViewCell() }
            cell.nameLabel?.text = userModel?.userName
            cell.messageLabel?.text = comments[indexPath.row].message
            cell.messageLabel?.numberOfLines = 0
            
            guard let time = comments[indexPath.row].timestamp?.toDayTime else { return cell }
            cell.timestampLabel?.text = time
            
            guard let urlString = userModel?.profileImageURL else { return cell }
            guard let url = URL(string: urlString) else { return cell }
            guard let imageView = cell.profileImageView else { return cell }
                                
            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data!)
                    imageView.layer.cornerRadius = imageView.frame.size.width / 2
                    imageView.clipsToBounds = true
                }
            }).resume()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//extension ChatViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        createRoom()
//        return true
//    }
//}
