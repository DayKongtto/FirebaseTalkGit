//
//  MainViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/02/06.
//

import UIKit
import SnapKit
import Firebase

class PeopleViewController: UIViewController {

    var array: [UserModel] = []
    let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeopleViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.bottom.left.right.equalTo(view)
        }
        
        Database.database().reference().child("users").observe(DataEventType.value) { snapshop in
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            for child in snapshop.children {
                guard let fChild = child as? DataSnapshot else { continue }
                let userModel = UserModel()
                
                guard let fValue = fChild.value as? [String: Any] else { continue }
                userModel.userName = fValue["userName"] as? String
                userModel.profileImageURL = fValue["profileImageURL"] as? String
                userModel.uid = fValue["uid"] as? String
                
                if userModel.uid == myUid { continue }
                self.array.append(userModel)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                as? PeopleViewCell else { return UITableViewCell() }
        
        guard let imageView = cell.imageview else { return UITableViewCell() }
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10)
            make.width.height.equalTo(50)
        }
        
        guard let urlString = array[indexPath.row].profileImageURL else { return cell }
        guard let url = URL(string: urlString) else { return cell }
                            
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
                imageView.layer.cornerRadius = imageView.frame.size.width / 2
                imageView.clipsToBounds = true
            }
        }).resume()
        
        guard let label = cell.label else { return UITableViewCell() }
        label.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].userName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let view = self.storyboard?
                .instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        else { return }
        view.destinationUid = array[indexPath.row].uid
        self.navigationController?.pushViewController(view, animated: true)
    }
}
