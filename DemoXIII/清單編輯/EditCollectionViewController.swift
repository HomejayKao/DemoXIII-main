//
//  EditCollectionViewController.swift
//  DemoX
//
//  Created by homejay on 2021/3/7.
//

import UIKit

private let reuseIdentifier = "EditCollectionViewCell"

class EditCollectionViewController: UICollectionViewController {
    
    var itemListArray = [List]()
    var itemListImageNameArray = [String]()
    
    var segmentedValue = 0 //接收傳過來的 收入或支出的判斷值
    var itemNameContent = "" //接收傳過來的 項目名稱
    var imageName = "" //接收傳過來的 照片名稱
    var number = 0 //接收傳過來 上一頁點擊cell時的 位置編號
    
    var incomeListArray = [List]() //接收傳過來的 支出 選項清單
    var expenseListArray = [List]() //接收傳過來的 收入 選項清單
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemListImageNameArray = List.returnAllImageNameArray()
        
        var listArray = [List]()
        
        for i in 0...itemListImageNameArray.count - 1 {
            
            let list = List(imageName: itemListImageNameArray[i],imageSelectedName:itemListImageNameArray[i]+"-1")
            
            listArray.append(list)
        }
        
        itemListArray = listArray
        
        setFlowLayout(itemSpace:4,columnCount:5)

        print("segmentedValue",segmentedValue)
        print("itemNameContent",itemNameContent)
        print("imageName",imageName)
        print("number",number)

    }
    
    func setFlowLayout(itemSpace:CGFloat,columnCount:CGFloat) {
        //實現一排 4 張正方形的照片，照片間的距離為 3，總共有 3 個間距，那麼在寬度 414 的 iPhone 11 時，cell 的寬度將為 (414 - 4*3) / 4 = 100.5
        
        //間隔寬、間距
        let itemSpace = itemSpace
        //列數
        let columnCount = columnCount
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        
        //利用 function floor 將小數點後的數字捨去，因為還有小數點的話，有可能會讓最後加起來的寬度超過螢幕寬度。(間距數 = 列數-1)
        let cellWidth = floor((collectionView.bounds.width - itemSpace * (columnCount-1)) / columnCount)
        flowLayout?.itemSize = CGSize(width: cellWidth , height: cellWidth )
        
        //將 Min Spacing For Cells & Min Spacing For Lines 都設為 itemSpace。
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
        flowLayout?.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    
    //回傳 ReusableView 顯示的內容 每次reload都會觸發
    //創建一個要返回的UICollectionReusableView，方法跟cell類似 要轉型
    //ofKind 看是要header or footer
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "EditCollectionReusableView", for: indexPath) as? EditCollectionReusableView else { return UICollectionReusableView()}
        
        reusableView.editTextField.text = itemNameContent
        
        return reusableView
    }
    
    //點cell觸發，變更圖片名稱
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //先將所有項目 變 黑白圖
        for i in 0...itemListArray.count - 1 {
            itemListArray[i].isTap = false
        }
        
        itemListArray[indexPath.item].isTap = true //被點到的變彩圖
        
        if let itemImageName = itemListArray[indexPath.item].imageName {
            imageName = itemImageName
            print("變更後的imageName",imageName)
            
            //僅存起來不做變更，不然按新增或刪除時 也會變更圖片，只不過刪除沒差，因為都是整筆刪掉
        }
        collectionView.reloadData()
    }
    //變更item的標籤title
    @IBAction func editingTitleChange(_ sender: UITextField) {
        if let content = sender.text {
            itemNameContent = content
            print("變更後的title",itemNameContent)
        }
    }
    
    //修改
    @IBAction func updateItem(_ sender: Any) {

        //會先到unwindSegue才會再跑這，故這邊太慢，傳過去的資料還是舊的
        //改成點選時就將修改陣列內容存起來，實際要改變內容則是按修改按鈕才做修改，但還是失敗
        
        //必須到unwindSegue那邊再作修改，故此時必須判斷是透過 修改button 還是 新增button 到unwindSegue
        //用unwindSegue的ID判斷

    }
    
    //新增
    @IBAction func addNewItem(_ sender: Any) {
        
    }
    
    //刪除
    @IBAction func deleteItem(_ sender: Any) {
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addUnwind" {
            
            let list = List(imageName: imageName, imageSelectedName: imageName + "-1", title: itemNameContent)
            
            switch segmentedValue {
            case 0:
                let bool =  incomeListArray.allSatisfy { (incomeList) -> Bool in
                    return incomeList.imageName != list.imageName && incomeList.title != list.title
                }
                
                if bool == false {
                    let alert = AlertController.shared.makeSingleAlert(title: "提醒您", message: "清單內已有重複標籤了唷～")
                    present(alert, animated: true, completion: nil)
                }
                
                return bool
                
            default:
                let bool = expenseListArray.allSatisfy { (expenseList) -> Bool in
                    return expenseList.imageName != list.imageName && expenseList.title != list.title
                }
                
                if bool == false {
                    let alert = AlertController.shared.makeSingleAlert(title: "提醒您", message: "清單內已有重複標籤了唷～")
                    present(alert, animated: true, completion: nil)
                }
                return bool
            }
        }else{
            return true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return itemListArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? EditCollectionViewCell else { return UICollectionViewCell() }
        
        //判斷itemListArray有無包含，傳過來的imageName，是否一樣，一樣的話該成員isTap = true
        for i in 0...itemListArray.count - 1 {
            if itemListArray[i].imageName == imageName {
                itemListArray[i].isTap = true
            }
        }
        
        
        //itemListArray裡，isTap放 彩圖，不是的話 黑白圖
        if let imageName = itemListArray[indexPath.item].imageName,
           let imageSelectedName = itemListArray[indexPath.item].imageSelectedName {
            
            switch itemListArray[indexPath.item].isTap {
            case true:
                cell.setImageInfo(string: imageSelectedName)
            default:
                cell.setImageInfo(string: imageName)
            }
        }
        
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    deinit {
        print("EditCollectionViewController＿＿＿＿＿死亡")
    }
}
