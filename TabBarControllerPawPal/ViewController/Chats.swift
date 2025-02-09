//
//  Chats.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 09/02/25.
//

import UIKit
import Firebase
import FirebaseFirestore

class Chats: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!

    // MARK: - Properties
    var messages: [ChatMessage] = []
    var userId: String?
    var caretakerId: String?
    var chatId: String?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.separatorStyle = .none
        
       

        
        if let userId = userId, let caretakerId = caretakerId {
                    chatId = generateChatId(userId: userId, caretakerId: caretakerId)
                    fetchMessages()
                } else {
                    print("Error: User ID or Caretaker ID is nil")
                }
                
        
        setupKeyboardObservers()
    }
    
    // MARK: - Generate Chat ID
    private func generateChatId(userId: String, caretakerId: String) -> String {
        return userId < caretakerId ? "\(userId)_\(caretakerId)" : "\(caretakerId)_\(userId)"
    }
    
    // MARK: - Fetch Messages in Real-Time
    private func fetchMessages() {
        guard let chatId = chatId else { return }
        
        db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                self.messages.removeAll()
                
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp
                    
                    let message = ChatMessage(senderId: senderId, text: text, timestamp: timestamp?.dateValue() ?? Date())
                    self.messages.append(message)
                }
                
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                    if !self.messages.isEmpty {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.myTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
    }
    
    // MARK: - Send Message
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let chatId = chatId, let userId = userId,
              let text = messageTextField.text, !text.isEmpty,
              let caretakerId = caretakerId else { return }
        
        let newMessage: [String: Any] = [
            "senderId": userId,
            "receiverId": caretakerId,
            "text": text,
            "timestamp": Timestamp()
        ]
        
        db.collection("chats").document(chatId).collection("messages").addDocument(data: newMessage) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.messageTextField.text = ""
                }
            }
        }
    }
    
    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let isCurrentUser = message.senderId == userId
        
        if isCurrentUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SentMessageCell", for: indexPath) as! SentMessageCell
            cell.configure(with: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedMessageCell", for: indexPath) as! ReceivedMessageCell
            cell.configure(with: message)
            return cell
        }
    }
    
    // MARK: - Handle Keyboard Visibility
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.view.frame.origin.y = -keyboardFrame.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
