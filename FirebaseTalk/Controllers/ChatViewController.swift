//
//  ChatViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/04.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet private weak var sendButton: UIButton?
    @IBOutlet private weak var messageTextfield: UITextField?
    @IBOutlet private weak var tableView: UITableView?
    
    var destinationUid: String?
    
    var uid: String?
    var chatRoomUid: String?
    var commnts: [ChatModel.Comments] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton?.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        createRoom()
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
                "message": message
            ]
            
            Database.database().reference().child("chatRooms").child(chatRoomUid!)
                .child("comments").childByAutoId().setValue(comment)
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
                        self.messageTextfield?.text = ""
                        self.getMessageList()
                    }
                }
            }
    }
    
    func getMessageList() {
        guard let roomUid = chatRoomUid else { return }
        Database.database().reference().child("chatRooms").child(roomUid).child("comments")
            .observe(DataEventType.value) { dataSnapshot in
                self.commnts.removeAll()
                guard let items = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for item in items {
                    guard let itemValue = item.value as? [String: AnyObject] else { return }
                    guard let comment = ChatModel.Comments(JSON: itemValue) else { return }
                    self.commnts.append(comment)
                }
                self.tableView?.reloadData()
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
        return commnts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = commnts[indexPath.row].message
        
        return cell
    }
}
