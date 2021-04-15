//
//  ItemListCollectionViewController.swift
//  DemoX
//
//  Created by homejay on 2021/3/5.
//

import UIKit

private let reuseIdentifier = "ItemListCollectionViewCell"

class ItemListCollectionViewController: UICollectionViewController {
    
    var incomeImageNameArray = [String]()
    var incomeLabelTitleArray = [String]()
    var expenseImageNameArray = [String]()
    var expenseLabelTitleArray = [String]()
    
    var segmentedValue = 0
    var itemNameContent = ""
    var imageName = ""
    var number = 0
    
    var incomeListArray = [List]() //支出 選項清單
    var expenseListArray = [List]() //收入 選項清單
    
    //設置基本 收入 支出 選項清單 & List讀檔
    func setListInfo() {
        //List讀檔
        if let incomeList = List.readDocumentDirectory(),
           let expenseList = List.readDocumentDirectoryEx(){
            incomeListArray = incomeList
            expenseListArray = expenseList
        }else{
            incomeListArray = List.makeListItem(imageNameArray: incomeImageNameArray, labelTitleArray: incomeLabelTitleArray)
            expenseListArray = List.makeListItem(imageNameArray: expenseImageNameArray, labelTitleArray: expenseLabelTitleArray)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        incomeImageNameArray = List.returnIncomeImageNameArray()
        incomeLabelTitleArray = List.returnIncomeTitleArray()
        
        expenseImageNameArray = List.returnExpenseImageNameArray()
        expenseLabelTitleArray = List.returnExpenseTitleArray()
        
        setListInfo()
        updateListArrayBool()

        setFlowLayout(itemSpace:3,columnCount:4)
        
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
        flowLayout?.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        //將 Min Spacing For Cells & Min Spacing For Lines 都設為 itemSpace。
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
        flowLayout?.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    /*
    // 部份凍結效果 配合 present呈現 要再研究
    func setReusableView(reusableView:UIView) {
        // 此屬性為告訴ios自動建立放置位置的約束條件，有要autolayout就不會有它，有它就無法autolayout
        reusableView.translatesAutoresizingMaskIntoConstraints = false
        
        // 在collectionView上加 View
        //collectionView.addSubview(reusableView)
        
        guard let navigationBarHeight = self.navigationController?.navigationBar.bounds.height else { return }
        
        reusableView.frame = CGRect(x: collectionView.bounds.origin.x,
                                    y: collectionView.bounds.height/4, width: collectionView.bounds.width, height: collectionView.bounds.height/3)
        
        // 設定View的高度
        reusableView.heightAnchor.constraint(equalToConstant: (collectionView.bounds.height)/3 + navigationBarHeight).isActive = true
        
        // 設定View左右與collectionView左右無間距
        reusableView.leadingAnchor.constraint(equalTo: collectionView.frameLayoutGuide.leadingAnchor).isActive = true
        reusableView.trailingAnchor.constraint(equalTo: collectionView.frameLayoutGuide.trailingAnchor).isActive = true
        
        // 設定top與contentLayoutGuide top無間距, 並設定Priority為999, 發生衝突時將犧牲此約束條件
        //let topConstraint = reusableView.topAnchor.constraint(equalTo: collectionView.contentLayoutGuide.topAnchor)
        //topConstraint.priority = UILayoutPriority(999)
        //topConstraint.isActive = true
        
        // 設定View底部 與collectionView top間距65,讓View底部保留25不會被捲動
        // 設定buttom與safeAreaLayoutGuide 大於等於 safeAreaLayoutGuide top + 常數 三分之一螢幕與bar 的高
        reusableView.bottomAnchor.constraint(greaterThanOrEqualTo: collectionView.safeAreaLayoutGuide.topAnchor, constant: (collectionView.bounds.height)/3 + navigationBarHeight).isActive = true
    }
    */
    
    //回傳 ReusableView 顯示的內容 每次reload都會觸發
    //創建一個要返回的UICollectionReusableView，方法跟cell類似 要轉型
    //ofKind 看是要header or footer
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "itemListFooterCollectionReusableView", for: indexPath) as? itemListFooterCollectionReusableView else { return UICollectionReusableView()}
        
        //雖然目前沒用到，但ReusableView上的元件要顯示，故還是要return
        
        return reusableView
    }

    @IBAction func makeNewItem(_ sender: Any) {
        
        //這邊觸發到Detail的unwindSegue 資料傳過去
        
    }
    
    //將incomeListArray、expenseLiseArray的isTap變更為false
    func updateListArrayBool() {
        if incomeListArray.count != 0 {
            for i in 0...incomeListArray.count - 1 {
                incomeListArray[i].isTap = false
            }
        }
        if expenseListArray.count != 0 {
            for i in 0...expenseListArray.count - 1 {
                expenseListArray[i].isTap = false
            }
        }
    }
    
    //點cell觸發
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = indexPath.item
        
        //把點到的位置編號另外存起來
        number = indexPath.item
        
        //變更回預設的false
        updateListArrayBool()
        
        //變更點選到的item為isTap true 並將 圖片名稱與標籤 另外存起來
        switch segmentedValue {
        
        case 0:
            incomeListArray[item].isTap = true
            if let imageName = incomeListArray[item].imageName,
               let title = incomeListArray[item].title {
                self.imageName = imageName
                itemNameContent = title
                print("selfImageName",self.imageName)
                print("itemNameContent",itemNameContent)
            }
        default:
            expenseListArray[item].isTap = true
            if let imageName = expenseListArray[item].imageName,
               let title = expenseListArray[item].title{
                self.imageName = imageName
                itemNameContent = title
                print("selfImageName",self.imageName)
                print("itemNameContent",itemNameContent)
            }
            
        }
        //重新整理
        collectionView.reloadData()
    }
    
    //segmentedValueChange 這邊可以不用寫，改寫在ReusableView那裡，因為 return ReusableView 那邊每次reload都會回傳
    @IBAction func segmentedValueChange(_ sender: UISegmentedControl) {
        segmentedValue = sender.selectedSegmentIndex
        print("segmentedValue",segmentedValue)
        
        collectionView.reloadData()
        
        //setListInfo()
    }
    
    //恢復預設清單
    @IBAction func resetListArray(_ sender: Any) {
        
        incomeListArray = List.makeListItem(imageNameArray: incomeImageNameArray, labelTitleArray: incomeLabelTitleArray)
        expenseListArray = List.makeListItem(imageNameArray: expenseImageNameArray, labelTitleArray: expenseLabelTitleArray)
        
        List.saveDocumentDirectory(listArray: incomeListArray)
        List.saveDocumentDirectoryEx(listArray: expenseListArray)
        
        collectionView.reloadData()
    }
    
    
    //傳資料到editCollectionVC
    @IBSegueAction func showItemDetail(_ coder: NSCoder) -> EditCollectionViewController? {
        let editCollectionVC =  EditCollectionViewController(coder: coder)
        
        editCollectionVC?.segmentedValue = segmentedValue
        editCollectionVC?.imageName = imageName
        editCollectionVC?.itemNameContent = itemNameContent
        editCollectionVC?.incomeListArray = incomeListArray
        editCollectionVC?.expenseListArray = expenseListArray
        editCollectionVC?.number = number
        
        return editCollectionVC
    }
    
    //判斷有無任何成員被點選，有才能使用segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "goToEditCollectionVC" {
            
            switch segmentedValue {
            case 0:
                let incomeIsTap = incomeListArray.contains { (list) -> Bool in
                    list.isTap == true
                }
                
                if incomeIsTap == false {
                    let alert = AlertController.shared.makeSingleAlert(title: "友情提示", message: "請先點選任一標籤唷～")
                    present(alert, animated: true, completion: nil)
                }
                
                return incomeIsTap
                
            default:
                let expenseIsTap = expenseListArray.contains { (list) -> Bool in
                    list.isTap == true
                }
                
                if expenseIsTap == false {
                    let alert = AlertController.shared.makeSingleAlert(title: "友情提示", message: "請先點選任一標籤唷～")
                    present(alert, animated: true, completion: nil)
                }
                
                return expenseIsTap
            }
        }else{
            return true
        }
    }
    
    @IBAction func listComplete(_ sender: Any) {
        //這邊會觸發Detail的unwinde Segue
    }
    
    //資料傳回 from EidiCollectionVC
    @IBAction func unwindToItemListCollectionView(_ unwindSegue: UIStoryboardSegue) {
        
        if let sourceViewController = unwindSegue.source as? EditCollectionViewController{
            
            incomeListArray = sourceViewController.incomeListArray
            expenseListArray = sourceViewController.expenseListArray
            
            imageName = sourceViewController.imageName
            itemNameContent = sourceViewController.itemNameContent
            
            segmentedValue = sourceViewController.segmentedValue
            
            switch unwindSegue.identifier {
            case "editUnwind":
                //修改
                if unwindSegue.identifier == "editUnwind" {
                    switch segmentedValue {
                    case 0:
                        incomeListArray[number].imageName = imageName
                        incomeListArray[number].imageSelectedName = imageName + "-1"
                        
                        incomeListArray[number].title = itemNameContent
                    default:
                        expenseListArray[number].imageName = imageName
                        expenseListArray[number].imageSelectedName = imageName + "-1"
                        
                        expenseListArray[number].title = itemNameContent
                    }
                }
                
            case "addUnwind":
                //新增 - 新增的為彩圖，不是新增的 改為 黑白圖
                let list = List(imageName: imageName, imageSelectedName: imageName + "-1", title: itemNameContent, isTap: true)
                
                switch segmentedValue {
                case 0:
                    incomeListArray.append(list)
                    
                    incomeListArray[number].isTap = false
                    number = incomeListArray.count - 1 //number的位置會變為 新增的彩圖 位置
                
                default:
                    expenseListArray.append(list)
                    
                    expenseListArray[number].isTap = false
                    
                    number = expenseListArray.count - 1 //number的位置會變為 新增的彩圖 位置
                }
                
            case "deleteUnwind":
                //刪除
                switch segmentedValue {
                case 0:
                    if incomeListArray.count != 1 {
                        incomeListArray.remove(at: number)
                    }else{
                        let alert = AlertController.shared.makeSingleAlert(title: "提醒您", message: "還請先新增或修改標籤唷")
                        present(alert, animated: true, completion: nil)
                    }
                default:
                    if expenseListArray.count != 1 {
                        expenseListArray.remove(at: number)
                    }else{
                        let alert = AlertController.shared.makeSingleAlert(title: "提醒您", message: "還請先新增或修改標籤唷")
                        present(alert, animated: true, completion: nil)
                    }
                }
            default:
                break
            }
        }
        
        collectionView.reloadData()
        
        List.saveDocumentDirectory(listArray: incomeListArray)
        List.saveDocumentDirectoryEx(listArray: expenseListArray)
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
        
        switch segmentedValue {
        case 0:
            return incomeListArray.count
        default:
            return expenseListArray.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemListCollectionViewCell else { return UICollectionViewCell()}
        
        switch segmentedValue {
        case 0:
            if let name = incomeListArray[indexPath.item].imageName,
               let selectedName = incomeListArray[indexPath.item].imageSelectedName,
               let title = incomeListArray[indexPath.item].title {
                
                cell.itemLabel.text = title
                
                //判斷有沒有被點擊過
                //三原子寫法，應用在bool
                let imgName = incomeListArray[indexPath.item].isTap ? selectedName:name
                cell.itemImageView.image = UIImage(named: imgName)
                
            }
        default:
            if let name = expenseListArray[indexPath.item].imageName,
               let selectedName = expenseListArray[indexPath.item].imageSelectedName,
               let title = expenseListArray[indexPath.item].title {
                
                cell.itemLabel.text = title
                
                //判斷有沒有被點擊過
                switch expenseListArray[indexPath.item].isTap {
                case true:
                    cell.itemImageView.image = UIImage(named: selectedName)
                default:
                    cell.itemImageView.image = UIImage(named: name)
                }
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
        print("ItemListCollectionViewController＿＿＿＿＿死亡")
    }

}
