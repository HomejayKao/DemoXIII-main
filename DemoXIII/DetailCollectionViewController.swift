//
//  DetailCollectionViewController.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import UIKit
import CoreData

private let reuseIdentifier = "DetailCollectionViewCell"

//下一頁 處理過的資料 再傳回來，即便有存檔讀檔 也要傳，因為讀檔只有在一開始viewDidload時讀取，NavigationBar的返回不會觸發viewDidload
extension DetailCollectionViewController:ResultTableViewControllerDelegate {
    func resultTableViewController(_ controller: ResultTableViewController,
                                   incomeExpenseArray: [IncomeExpense],
                                   dateIncomeExpenseArray: [DateIncomeExpense]) {
        self.incomeExpenseArray = incomeExpenseArray
        self.dateIncomeExpenseArray = dateIncomeExpenseArray
    }
}

class DetailCollectionViewController: UICollectionViewController {
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var calculatorView: UIView!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var showButton: UIButton!
    
    var incomeImageNameArray = [String]()
    var incomeLabelTitleArray = [String]()
    var expenseImageNameArray = [String]()
    var expenseLabelTitleArray = [String]()
    var allItemImageNameArray = [String]()
    
    var incomeListArray = [List]() //支出 選項清單
    var expenseListArray = [List]() //收入 選項清單
    
    var titleArray = [String]() //紀錄button點擊狀況
    
    var incomeArray = [IncomeExpense]() //收入 陣列
    var expenseArray = [IncomeExpense]() // 支出 陣列
    var incomeExpenseArray = [IncomeExpense]() //收入 支出 陣列
    var dateIncomeExpenseArray = [DateIncomeExpense]() //每個日期的收支情況 EX:[2021/2/20,2021/2/22]
    
    var selectedTitle = "" //被選到的清單 其標籤 名稱，以及 傳到Item編輯畫面用
    var selectedImageName = "" //被選到的清單 其標籤 圖片名稱，以及 傳到Item編輯畫面用
    var selectedNumber = 0 //被選到的清單 其標籤 在其資料Array內的位置編號，傳到Item編輯畫面用
    var segmentedValue = 0 //將 收入 或 支出 的狀態存起來 傳到Item編輯畫面用
    
    //CoreData
    let persistenContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<IncomeExpenseDate>(entityName: "IncomeExpenseDate")
    var fetchedResultsController: NSFetchedResultsController<IncomeExpenseDate>?
    
    
    // TOP部份凍結效果
    func addView(newView:UIView) {
        // 此屬性為告訴ios自動建立放置位置的約束條件，有要autolayout就不會有它，有它就無法autolayout
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        // 在collectionView上加 View
        collectionView.addSubview(newView)
        
        guard let navigationBarHeight = self.navigationController?.navigationBar.bounds.height else { return }
        
        // 設定View的高度
        newView.heightAnchor.constraint(equalToConstant: (collectionView.bounds.height)/3 + navigationBarHeight*2).isActive = true
        
        // 設定View左右與collectionView左右無間距
        newView.leadingAnchor.constraint(equalTo: collectionView.frameLayoutGuide.leadingAnchor).isActive = true
        newView.trailingAnchor.constraint(equalTo: collectionView.frameLayoutGuide.trailingAnchor).isActive = true
        
        // 設定top與contentLayoutGuide top無間距, 並設定Priority為999, 發生衝突時將犧牲此約束條件
        let topConstraint = newView.topAnchor.constraint(equalTo: collectionView.contentLayoutGuide.topAnchor)
        topConstraint.priority = UILayoutPriority(999)
        topConstraint.isActive = true
        
        // 設定View底部 與collectionView top間距,讓View底部保留 達到不會被捲動
        // 設定buttom與safeAreaLayoutGuide 大於等於 safeAreaLayoutGuide top + 常數 三分之一螢幕與bar 的兩倍高
        newView.bottomAnchor.constraint(greaterThanOrEqualTo: collectionView.safeAreaLayoutGuide.topAnchor, constant: (collectionView.bounds.height)/3 + navigationBarHeight*2).isActive = true
        
    }
    
    // 一排放置多少Cell的排版效果
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
        flowLayout?.estimatedItemSize = .zero // cell 的尺寸才會依據 itemSize，否則它將從 auto layout 的條件計算 cell 的尺寸
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
        
        guard let navigationBarHeight = self.navigationController?.navigationBar.bounds.height else { return }
        //設置section的高，螢幕的三分之一高 然後要再加上navigationBar的兩倍高
        flowLayout?.sectionInset = UIEdgeInsets(top: (collectionView.bounds.height)/3 + navigationBarHeight*2,
                                                left: 0,
                                                bottom: 0,
                                                right: 0)
        
    }
    
    
    
    //變更標籤內容
    func changeSelectedItemInfo (imageName:String,title:String) {
        
        selectedImageView.image = UIImage(named: imageName)
        
        selectedLabel.text = title
    }
    
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
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: //收入清單
            
            //被選到的 標旗 預設為 清單的第一個
            if let imageName = incomeListArray.first?.imageName,
               let title = incomeListArray.first?.title{
                changeSelectedItemInfo(imageName: imageName, title: title)
                
                selectedImageName = imageName //將選到的標籤資料存起來 供傳到下一頁用
                selectedTitle = title //將選到的標籤資料存起來 供傳到下一頁用
            }
            
        default:
            
            //被選到的 標旗 預設為 清單的第一個
            if let imageName = expenseListArray.first?.imageName,
               let title = expenseListArray.first?.title{
                changeSelectedItemInfo(imageName: imageName, title: title)
                
                selectedImageName = imageName //將選到的標籤資料存起來 供傳到下一頁用
                selectedTitle = title //將選到的標籤資料存起來 供傳到下一頁用
            }
        }
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
    
    // 點擊 cell 所觸發的 func  點擊時 變更 標籤內容
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = indexPath.item
        
        //當點擊某個cell時，將incomeListArray、expenseLiseArray的isTap變更為false
        updateListArrayBool()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            //被點擊到的改為true
            incomeListArray[item].isTap = true
            
            if let imageName = incomeListArray[item].imageSelectedName,
               let title = incomeListArray[item].title {
                
                changeSelectedItemInfo(imageName: imageName, title: title)
                
                selectedImageName = imageName //將選到的標籤資料存起來 供傳到下一頁用
                selectedTitle = title //將選到的標籤資料存起來 供傳到下一頁用
            }
            
        default:
            expenseListArray[item].isTap = true
            
            if let imageName = expenseListArray[item].imageSelectedName,
               let title = expenseListArray[item].title {
                
                changeSelectedItemInfo(imageName: imageName, title: title)
                
                selectedImageName = imageName //將選到的標籤資料存起來 供傳到下一頁用
                selectedTitle = title //將選到的標籤資料存起來 供傳到下一頁用
            }
        }
        
        collectionView.reloadData()
        
        //只更新更新被點擊的cell，適用於類似那種 翻牌遊戲
        //collectionView.reloadItems(at: [IndexPath(item: indexPath.item, section: indexPath.section) ])
    }
    
    //將與datePicker一樣日期的紀錄挑出來
    func makePickerDayIncomeExpenseArray(date:Date,year:Int,month:Int,day:Int) -> [IncomeExpense] {
        
        let samePickerDayIncomeExpenseArray = incomeExpenseArray.filter { (incomeExpense) -> Bool in
            if incomeExpense.year == year ,
               incomeExpense.month == month ,
               incomeExpense.day == day {
                return true
            }else{
                return false
            }
        }
        return samePickerDayIncomeExpenseArray
    }
    
    
    //更新或新增 每個日期紀錄收支的情況
    func updateDateIncomeExpenseArray(date:Date,year:Int,month:Int,day:Int,incomeExpense:IncomeExpense) {
        
        //如果count == 0 代表dateIncomeExpenseArray沒有內容，即 第一筆資料 要 記錄在Array裡
        if dateIncomeExpenseArray.count == 0 {
            let dateIncomeExpense = DateIncomeExpense(incomeExpense: [incomeExpense],
                                                      date: date,
                                                      year: year,
                                                      month: month,
                                                      day: day,
                                                      beRecorded: true)
            
            dateIncomeExpenseArray.append(dateIncomeExpense)
            print("dateIncomeExpenseArray的第一筆紀錄，count為\(dateIncomeExpenseArray.count)")
        }
        
        var n = 0 //每一筆紀錄的位置
        
        //判斷每筆紀錄
        for index in dateIncomeExpenseArray {
            print("第\(n)筆記錄")
            print("picker選到的日期\(index.year!)/\(index.month!)/\(index.day!)")
            
            //情況一 紀錄時的日期 跟picker同一天，且 有記錄過了
            if index.year == year , index.month == month , index.day ==  day , index.beRecorded == true {
                
                let samePickerDayIncomeExpenseArray = makePickerDayIncomeExpenseArray(date: date, year: year, month: month, day: day)
                //更新該筆紀錄的收支情況
                dateIncomeExpenseArray[n].incomeExpense = samePickerDayIncomeExpenseArray
                
                print("dateIncomeExpenseArray[n].day\(dateIncomeExpenseArray[n].day!)")
                print("n 同一天 dateIncomeExpenseArray.count為\(dateIncomeExpenseArray.count)")
                
                //情況二 紀錄時的日期 跟picker同一天 但 沒紀錄，此行程式不會發生，因為陣列內每一筆紀錄，在記錄時都會變true
            }else if index.year == year , index.month == month , index.day ==  day , index.beRecorded == false {
                
                print("dateIncomeExpenseArray內容有問題！！")
                
                //情況三 紀錄時的日期 跟picker 不同天 但 有紀錄過
            }else if index.year != year || index.month != month || index.day != day , index.beRecorded == true{
                
                //要判斷 陣列內是否已有這個成員，沒有才加，有的話不加
                let hadElement = dateIncomeExpenseArray.contains { (dateIncomeExpense) -> Bool in
                    return dateIncomeExpense.year == year &&
                        dateIncomeExpense.month == month &&
                        dateIncomeExpense.day == day
                }
                print("此筆日期有記錄過 hadElement\(hadElement)")
                if hadElement {
                    print("陣列內已有記錄過的日期，故不新增日期")
                }else {
                    
                    let samePickerDayIncomeExpenseArray = makePickerDayIncomeExpenseArray(date: date, year: year, month: month, day: day)
                    
                    let dateIncomeExpense = DateIncomeExpense(incomeExpense: samePickerDayIncomeExpenseArray,
                                                              date: date,
                                                              year: year,
                                                              month: month,
                                                              day: day,
                                                              beRecorded: true)
                    
                    dateIncomeExpenseArray.append(dateIncomeExpense)
                }
                
                //情況四 紀錄時的日期 跟picker 不同天 也 沒紀錄過
            }else if index.year != year || index.month != month || index.day != day , index.beRecorded == false {
                
                let samePickerDayIncomeExpenseArray = makePickerDayIncomeExpenseArray(date: date, year: year, month: month, day: day)
                
                let dateIncomeExpense = DateIncomeExpense(incomeExpense: samePickerDayIncomeExpenseArray,
                                                          date: date,
                                                          year: year,
                                                          month: month,
                                                          day: day,
                                                          beRecorded: true)
                
                dateIncomeExpenseArray.append(dateIncomeExpense)
                
                print("n 不同天 dateIncomeExpenseArray.count為\(dateIncomeExpenseArray.count)")
            }
            
            n += 1
            print("after n \(n)")
        }
    }
    
    
    //變更收支選項
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        
        segmentedValue = sender.selectedSegmentIndex
        
        setListInfo()
        updateListArrayBool()
        
        collectionView.reloadData()
        
    }
    
    //輸入顯示並記錄
    @IBAction func inputNumber(_ sender: UIButton) {
        
        if let senderTitle = sender.currentTitle { //根據點擊的button 紀錄下來
            titleArray.append(senderTitle)
        }
        
        if titleArray.first == "0", titleArray.count > 1 { //第一個為0的話 刪掉第一個0，首字不為0
            titleArray.removeFirst()
        }
        
        let text = titleArray.joined(separator: "") //將Array去掉 變 字串
        
        priceTextField.text = text //呈現 點擊的內容
        
    }
    
    //輸入完畢 & 存檔
    func inputComplete() {
        
        if priceTextField.text == "" { //如果空白沒輸入，那就當成輸入0
            titleArray.append("0")
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            
            let number = titleArray.joined(separator: "") //將Array去掉 變 字串
            
            titleArray.removeAll() //記錄狀況 清空
            priceTextField.text = "" //呈現內容 清空
            
            
            //將指定的時間、標籤、金額，變成清單，並存到陣列
            if let money = Int(number) {
                
                let date = datePicker.date
                let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: date)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                
                let dateString = formatter.string(from: date)
                
                if let year = dateComponents.year,
                   let month = dateComponents.month,
                   let day = dateComponents.day {
                    //生成此筆收入
                    let income = IncomeExpense(money: money,
                                               time: date,
                                               imageName: selectedImageName,
                                               imageSelectedName: selectedImageName,
                                               title: selectedTitle,
                                               year: year,
                                               month: month,
                                               day: day)
                    
                    incomeArray.append(income) //將收入 加到 收入陣列
                    
                    incomeExpenseArray.append(income) //將收入 加到 收入支出陣列
                    
                    updateDateIncomeExpenseArray(date: date, year: year, month: month, day: day, incomeExpense: income) //更新 或 新增 每個日期的收支情況
                    
                    print("income.imageSelectedName\(income.imageSelectedName ?? "沒照片名")")
                    print("income.money\(income.money ?? 0)")
                    print("incomeArray\(incomeArray)")
                    print("incomeExpenseArray\(incomeExpenseArray)")
                    print("dateIncomeExpenseArray.count\(dateIncomeExpenseArray.count)")
                    
                    //——————————————————————————————————————————————————————————————————————————————————
                    
                    //CoreData - Create 新增資料
                    let incomeExpenseDate = IncomeExpenseDate(context: context)
                    
                    incomeExpenseDate.money = Int64(money)
                    incomeExpenseDate.date = date
                    incomeExpenseDate.dateString = dateString
                    incomeExpenseDate.imageSelectedName = selectedImageName

                    incomeExpenseDate.imageName = selectedImageName
                    incomeExpenseDate.title = selectedTitle
                    incomeExpenseDate.year = Int64(year)
                    incomeExpenseDate.month = Int64(month)
                    incomeExpenseDate.day = Int64(day)
                    incomeExpenseDate.beRecorded = true
                    
                    //CoreData - Save 儲存
                    do {
                        try context.save()
                    } catch {
                        print("CoreData收入儲存失敗",error)
                    }
                    
                }
                
            }
            
            
        default:
            let number = titleArray.joined(separator: "") //將Array去掉 變 字串
            
            titleArray.removeAll()
            priceTextField.text = ""
            
            //支出改為負數
            if let number = Int(number) {
                
                let money = -number //支出改為負數
                
                let date = datePicker.date
                let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: date)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                
                let dateString = formatter.string(from: date)
                
                if let year = dateComponents.year,
                   let month = dateComponents.month,
                   let day = dateComponents.day {
                    
                    //生成此筆支出
                    let expense = IncomeExpense(money: money,
                                                time: date,
                                                imageName: selectedImageName,
                                                imageSelectedName: selectedImageName,
                                                title: selectedTitle,
                                                year: year,
                                                month: month,
                                                day: day)
                    
                    expenseArray.append(expense) //將支出 加到 支出陣列
                    
                    incomeExpenseArray.append(expense) //將支出 加到 收入支出陣列
                    
                    updateDateIncomeExpenseArray(date: date, year: year, month: month, day: day, incomeExpense: expense)//更新 或 新增 每個日期的收支情況
                    
                    print("expense.imageSelectedName\(expense.imageSelectedName ?? "沒照片名")")
                    print("expense.money\(expense.money ?? 0)")
                    print("expenseArray\(expenseArray)")
                    print("incomeExpenseArray\(incomeExpenseArray)")
                    print("dateIncomeExpenseArray.count\(dateIncomeExpenseArray.count)")
                    
                    //——————————————————————————————————————————————————————————————————————————————————
                    
                    //CoreData - Create 新增資料
                    let incomeExpenseDate = IncomeExpenseDate(context: context)
                    
                    incomeExpenseDate.money = Int64(money)
                    incomeExpenseDate.date = date
                    incomeExpenseDate.dateString = dateString
                    incomeExpenseDate.imageSelectedName = selectedImageName

                    incomeExpenseDate.imageName = selectedImageName
                    incomeExpenseDate.title = selectedTitle
                    incomeExpenseDate.year = Int64(year)
                    incomeExpenseDate.month = Int64(month)
                    incomeExpenseDate.day = Int64(day)
                    incomeExpenseDate.beRecorded = true
                    
                    //CoreData - Save 儲存
                    do {
                        try context.save()
                    } catch {
                        print("CoreData支出儲存失敗",error)
                    }
                }
            }
        }
        
        //存檔 將新增或修改的資料，存到App內
        IncomeExpense.saveDocumentDirectory(incomeExpenseArray: incomeExpenseArray)
        DateIncomeExpense.saveDocumentDirectory(dateIncomeExpenseArray: dateIncomeExpenseArray)
        
    }
    
    //輸入完畢
    @IBAction func oneMoreInput(_ sender: UIButton) {
        
        inputComplete()
        
        let yesNoAlert = UIAlertController(title: "已新增一筆資料", message: "需要再建一筆嗎？", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "再一筆", style: .default, handler: nil)
        
        yesNoAlert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { alertAction in
            
            
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let resultTableVC = storyboard.instantiateViewController(identifier: "ResultTableViewController") as? ResultTableViewController else { return }
            
            resultTableVC.incomeArray = self.incomeArray
            resultTableVC.expenseArray = self.expenseArray
            resultTableVC.incomeExpenseArray = self.incomeExpenseArray
            resultTableVC.dateIncomeExpenseArray = self.dateIncomeExpenseArray
            
            resultTableVC.incomeListArray = self.incomeListArray
            resultTableVC.expenseListArray = self.expenseListArray
            
            self.navigationController?.pushViewController(resultTableVC, animated: true)
            
            
        }
        
        yesNoAlert.addAction(cancelAction)

       present(yesNoAlert, animated: true, completion: nil)
    }
    
    //清空
    @IBAction func deleteNumber(_ sender: UIButton) {
        
        titleArray.removeAll()
        priceTextField.text = ""
        
    }
    
    //傳資料to ResultTableVC & 存檔
    @IBSegueAction func passCaculateResult(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> ResultTableViewController? {
        
        //inputComplete()
        
        let resultTableVC = ResultTableViewController(coder: coder)
        
        resultTableVC?.incomeArray = incomeArray
        resultTableVC?.expenseArray = expenseArray
        resultTableVC?.incomeExpenseArray = incomeExpenseArray
        resultTableVC?.dateIncomeExpenseArray = dateIncomeExpenseArray
        
        resultTableVC?.incomeListArray = incomeListArray
        resultTableVC?.expenseListArray = expenseListArray
        
        resultTableVC?.delegate = self //設定delegate定義並使用resultTableVC的func拿到傳回的資料
        
        return resultTableVC
    }
    
    //傳資料to itemListCollectionVC
    @IBSegueAction func showItemList(_ coder: NSCoder) -> ItemListCollectionViewController? {
        let itemCollectionVC =  ItemListCollectionViewController(coder: coder)
        
        return itemCollectionVC
    }
    
    //接收資料from itemListCollectionVC
    @IBAction func unwindToDetailCollectionViewController(_ unwindSegue: UIStoryboardSegue) {
        
        if let sourceVC = unwindSegue.source as? ItemListCollectionViewController {
            incomeListArray = sourceVC.incomeListArray
            expenseListArray = sourceVC.expenseListArray
        }
        
        setListInfo()
        
        updateListArrayBool()//讀取資料後，先把bool改回預設
        
        List.saveDocumentDirectory(listArray: incomeListArray)
        List.saveDocumentDirectoryEx(listArray: expenseListArray)
        
        collectionView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //讀檔
        if let incomeExpenses = IncomeExpense.readDocumentDirectory(),
           let dateIncomeExpenses = DateIncomeExpense.readDocumentDirectory(){
            incomeExpenseArray = incomeExpenses
            dateIncomeExpenseArray = dateIncomeExpenses
        }
        
        incomeImageNameArray = List.returnIncomeImageNameArray()
        incomeLabelTitleArray = List.returnIncomeTitleArray()
        
        expenseImageNameArray = List.returnExpenseImageNameArray()
        expenseLabelTitleArray = List.returnExpenseTitleArray()
        
        //allItemImageNameArray = List.returnAllImageNameArray()
        
        setListInfo()
        updateListArrayBool()
        
        addView(newView: calculatorView)
        setFlowLayout(itemSpace: 3, columnCount: 4)
        
        /*
         //順時針旋轉45度
         let aDegree = CGFloat.pi/180 //一個圓弧的弧度是180度
         let transform = CGAffineTransform(rotationAngle: aDegree*(45))
         addButton.transform = transform
         */
        
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
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return incomeListArray.count
        default:
            return expenseListArray.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DetailCollectionViewCell else { return UICollectionViewCell() }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if let name = incomeListArray[indexPath.item].imageName,
               let selectedName = incomeListArray[indexPath.item].imageSelectedName,
               let title = incomeListArray[indexPath.item].title {
                
                cell.listLabel.text = title
                
                //判斷有沒有被點擊過
                if incomeListArray[indexPath.item].isTap == false {
                    cell.listImageView.image = UIImage(named: name)
                }else{
                    cell.listImageView.image = UIImage(named: selectedName)
                }
                
            }
        default:
            if let name = expenseListArray[indexPath.item].imageName,
               let selectedName = expenseListArray[indexPath.item].imageSelectedName,
               let title = expenseListArray[indexPath.item].title {
                
                cell.listLabel.text = title
                
                //判斷有沒有被點擊過
                if expenseListArray[indexPath.item].isTap == false {
                    cell.listImageView.image = UIImage(named: name)
                }else{
                    cell.listImageView.image = UIImage(named: selectedName)
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
        print("DetailCollectionViewController＿＿＿＿＿死亡")
    }
}

