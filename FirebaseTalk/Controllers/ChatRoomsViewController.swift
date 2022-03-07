//
//  ChatRoomsViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/07.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    
    var uid: String?
    var chatRooms: [ChatModel] = []
    var destinationUsers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uid = Auth.auth().currentUser?.uid
        getChatRoomsList()
    }
    
    func getChatRoomsList() {
        guard let gUid = uid else { return }
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/" + gUid)
            .observeSingleEvent(of: DataEventType.value) { dataSnapshot in
                self.chatRooms.removeAll()
                guard let items = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for item in items {
                    guard let chatRoomDic = item.value as? [String: AnyObject] else { return }
                    guard let chatModel = ChatModel(JSON: chatRoomDic) else { return }
                    self.chatRooms.append(chatModel)
                }
                self.tableView?.reloadData()
            }
    }

}

extension ChatRoomsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath)
                as? RowCell else { return UITableViewCell() }
        
        var destinationUid: String?
        
        guard let gUid = uid else { return UITableViewCell() }
        let users = chatRooms[indexPath.row].users
        for user in users {
            if user.key != gUid {
                destinationUid = user.key
                guard let dUid = destinationUid else { return UITableViewCell() }
                destinationUsers.append(dUid)
            }
        }
        
        guard let gDestinationUid = destinationUid else { return UITableViewCell() }
        Database.database().reference().child("users").child(gDestinationUid)
            .observe(DataEventType.value) { snapshop in
                let userModel = UserModel()
                
                guard let userValue = snapshop.value as? [String: Any] else { return }
                userModel.userName = userValue["userName"] as? String
                userModel.profileImageURL = userValue["profileImageURL"] as? String
                userModel.uid = userValue["uid"] as? String
                
                cell.titleLabel?.text = userModel.userName
                guard let urlString = userModel.profileImageURL else { return }
                guard let url = URL(string: urlString) else { return }
                            
                guard let imageview = cell.imageview else { return }
                URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                    DispatchQueue.main.async {
                        imageview.image = UIImage(data: data!)
                        imageview.layer.cornerRadius = imageview.frame.size.width / 2
                        imageview.clipsToBounds = true
                    }
                }).resume()
                
                guard let lastMessageKey = self.chatRooms[indexPath.row].comments
                        .keys.max() else { return }
                cell.lastMessageLabel?.text = self.chatRooms[indexPath.row]
                    .comments[lastMessageKey]?.message
                
                guard let time = self.chatRooms[indexPath.row]
                        .comments[lastMessageKey]?.timestamp?.toDayTime else { return }
                cell.timestampLabel?.text = time
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let destinationUid = destinationUsers[indexPath.row]
        guard let view = self.storyboard?
                .instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        else { return }
        view.destinationUid = destinationUid
        self.navigationController?.pushViewController(view, animated: true)
    }
}
