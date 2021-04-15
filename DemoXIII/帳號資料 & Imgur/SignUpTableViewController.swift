//
//  SignUpTableViewController.swift
//  DemoXI
//
//  Created by homejay on 2021/3/23.
//

import UIKit
import Foundation
import PhotosUI

//鍵盤return 跳下個textField
extension SignUpTableViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case nameTextField:
            phoneTextField.becomeFirstResponder()
        case phoneTextField:
            addressTextField.becomeFirstResponder()
        case addressTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            accountTextField.becomeFirstResponder()
        case accountTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            noteTextField.becomeFirstResponder()
        case noteTextField:
            textField.endEditing(true)
        default:
            break
        }
        return true
    }
}

extension SignUpTableViewController:UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    //選照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[.originalImage] as? UIImage{ //原始照
            imageAttachment.image = originalImage //設定圖片
            selectedImage = originalImage
            print(selectedImage!.jpegData(compressionQuality: 0.9)!.base64EncodedString())
            dismiss(animated: true, completion: nil) //選完照片後從顯示的controller回到前一頁
        }
    }
}

class SignUpTableViewController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet var tagsButton: [UIButton]!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var imageAttachment: UIImageView!
    
    var itemArray = [PostInfo.Item]()
    var postInfo:PostInfo?
    
    var tags = [String]()
    
    let postUrl = "https://api.airtable.com/v0/appUFA1vsu2dfoYsc/%E5%AE%A2%E6%88%B6%E8%B3%87%E6%96%99%E8%A1%A8"
    
    var attachment:PostInfo.Item.Field.Attachment?
    var attachmentArray = [PostInfo.Item.Field.Attachment]()
    
    var selectedImage:UIImage?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        phoneTextField.delegate = self
        addressTextField.delegate = self
        emailTextField.delegate = self
        accountTextField.delegate = self
        passwordTextField.delegate = self
        noteTextField.delegate = self

    }
    
    //使tableView可以收鍵盤
    @IBAction func tableTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func isSelectedChange(_ sender: UIButton) {
        
        switch sender.isSelected {
        
        case true:
            sender.isSelected = false
            
            if let title = sender.currentTitle,
               let index = tags.firstIndex(of: title){ //從頭開始找 含有 指定字串 的是第幾個
                tags.remove(at: index)
            }
            
            print(sender.currentTitle!,sender.isSelected,sender.tag,tags)
            
        case false:
            sender.isSelected = true
            tags.append(sender.currentTitle!)
            
            print(sender.currentTitle!,sender.isSelected,sender.tag,tags)
        }
    }
    @IBAction func addAccount(_ sender: Any) {
        
        guard nameTextField.text != "" else {
            print("請輸入姓名")
            makeAlert(message: "欄位：姓名")
            return
        }
        
        guard phoneTextField.text != "" else {
            print("請輸入電話")
            makeAlert(message: "欄位：電話")
            return
        }
        
        guard emailTextField.text != "" else {
            print("請輸入信箱")
            makeAlert(message: "欄位：信箱")
            return
        }
        
        guard accountTextField.text != "" else {
            print("請設定帳號")
            makeAlert(message: "欄位：帳號")
            return
        }
        
        guard passwordTextField.text != "" else {
            print("請設定密碼")
            makeAlert(message: "欄位：密碼")
            return
        }
        
        var gender = true
        
        switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            gender = true
        default:
            gender = false
        }
        
        
        if let image = selectedImage {
            
            NetworkController.shared.uploadImageToImgur(uiImage: image) { [self] (result) in
                switch result {
                case .success(let url):
                    print("url.absoluteString",url.absoluteString)
                    
                    attachment = PostInfo.Item.Field.Attachment(url:url.absoluteString )
                    
                    
                    if let attachment = self.attachment {
                        attachmentArray.append(attachment)
                        print("前面的attachmentArray.count",attachmentArray.count)
                    }
                    
                    makeAccount(gender: gender)
                    NetworkController.shared.createAirtableRecordAPI(urlString: postUrl, postInfo: postInfo)
                    
                    let alert = AlertController.shared.makeSingleAlert(title: "通知", message: "上傳成功")
                    present(alert, animated: true, completion: nil)
                    
                case .failure(let error):
                    print(error)
                }
            }
            
        }else{
            makeAlert(message: "欄位：圖片")
        }
        
        /*
        makeAccount(gender: gender)
        print("後面的attachmentArray.count",attachmentArray.count)
        NetworkController.shared.createAirtableRecordAPI(urlString: postUrl, postInfo: postInfo)
        */
        
        itemArray.removeAll() //避免重複上傳
        attachmentArray.removeAll() //避免重複上傳
        
    }
    
    //錯誤通知
    func makeAlert(message:String) {
        let singleAlert = AlertController.shared.makeSingleAlert(title: "請填寫完整", message: message)
        
        present(singleAlert, animated: true, completion: nil)
    }
    
    //新增資料
    func makeAccount(gender:Bool) {
        
        let field = PostInfo.Item.Field (
            Name: nameTextField.text,
            Phone: phoneTextField.text,
            Address: addressTextField.text,
            Email: emailTextField.text,
            Rating: Int(ratingSlider.value),
            Tags: tags,
            Account: accountTextField.text,
            Password: passwordTextField.text,
            Attachments: attachmentArray,
            Gender: gender,
            Notes: noteTextField.text
        )
        
        let item = PostInfo.Item(fields: field)
        
        itemArray.append(item)
        
        postInfo = PostInfo(records: itemArray)
        
    }
    
    //選照片
    @IBAction func selectPhoto(_ sender: UIButton) {
        
        //要有相簿才執行
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary //資料類型為 相簿
            imagePickerController.delegate = self //代表為自己
            
            //顯示各種Controller的present
            present(imagePickerController, animated: true, completion: nil)
            
            imagePickerController.allowsEditing = true //准許編輯
            
        }
    }
    
    @IBAction func infoDelete(_ sender: Any) {
        
        nameTextField.text = ""
        phoneTextField.text = ""
        addressTextField.text = ""
        emailTextField.text = ""
        ratingSlider.value = 0
        accountTextField.text = ""
        passwordTextField.text = ""
        noteTextField.text = ""
        imageAttachment.image = UIImage(named: "picture-1")
        
    }
    
    /*
    //定義 function touchesEnded(_:with:) 寫收鍵盤的程式實現
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    */

    // MARK: - Table view data source
    
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        print("SignUpTableViewController＿＿＿＿＿死亡")
    }
}
