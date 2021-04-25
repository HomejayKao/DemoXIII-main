//
//  ResultTableViewController.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import UIKit
import CoreData

//將刪除過後的資料 更新 並回傳給上一頁

//Step1 delegate的資料回傳，不用跳回前頁，delegate傳資料通常只用於資料回傳到前一頁(前一頁可能有各種畫面)
protocol ResultTableViewControllerDelegate: AnyObject { //寫一個protocol delegate代理人 func的參數，用來存放資料，AnyObject限定只能是class
    func resultTableViewController(_ controller: ResultTableViewController ,incomeExpenseArray:[IncomeExpense],dateIncomeExpenseArray:[DateIncomeExpense]) //第一個參數為，讓func知道，當初是誰呼叫它，即誰呼叫這個func
}

class ResultTableViewController: UITableViewController {
    
    weak var delegate: ResultTableViewControllerDelegate? //設一個變數 遵從 protocol的delegate代理人，現在還不知道是誰，誰遵從，誰就能成為代理人
    
    @IBOutlet weak var incomeTotalLabel: UILabel!
    @IBOutlet weak var expenseTotalLabel: UILabel!
    @IBOutlet weak var totalResultLabel: UILabel!
    
    var incomeArray = [IncomeExpense]() //接收傳過來的 收入 陣列 在這邊完全沒用到
    var expenseArray = [IncomeExpense]() //接收傳過來的 支出 陣列 在這邊完全沒用到
    
    var incomeExpenseArray = [IncomeExpense]() //接收傳過來的 收支 陣列
    var dateIncomeExpenseArray = [DateIncomeExpense]()//接收傳過來的 每筆日期收支陣列
    
    var incomeListArray = [List]() //接收傳過來的 支出 選項清單 直接再傳往下一頁 在這邊完全沒用到
    var expenseListArray = [List]() //接收傳過來的 收入 選項清單 直接再傳往下一頁 在這邊完全沒用到
    
    //CoreData
    let persistenContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<IncomeExpenseDate>(entityName: "IncomeExpenseDate")
    var fetchedResultsController: NSFetchedResultsController<IncomeExpenseDate>?
    
    //CoreData - Read 擷取資料
    func fetchIncomeExpenseDate() {
        
        //建立 NSFetchedResultsController
        let sortDescriptor = NSSortDescriptor(key: "dateString", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //FRC需要排序，SectionNameKeyPath 是用來分 Fetched Object 的 Section 所屬。
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: "dateString",
                                                              cacheName: nil)
        
        //擷取資料
        do {
            try fetchedResultsController?.performFetch()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                self.setInfo()
            }
            
        }catch let error as NSError {
            print("擷取資料失敗",error.debugDescription)
        }
        
    }
    
    
    //var dataSource: UITableViewDiffableDataSource<DateIncomeExpense,IncomeExpense>? //說明它的 section 辨識型別是 Section，內容辨識型別是 IncomeExpense。
    
    //var snapshot = NSDiffableDataSourceSnapshot<DateIncomeExpense, IncomeExpense>()
    
    /*點選cell觸發
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     <#code#>
     }
     */
    /*
    func setDiffableDataSource() {
        dataSource = UITableViewDiffableDataSource<DateIncomeExpense,IncomeExpense>(tableView: tableView, cellProvider: { (tableView, indexPath, incomeExpense) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as? ResultTableViewCell else { return UITableViewCell() }
            
            cell.itemImageView.image = UIImage(systemName: incomeExpense.imageName!)
            cell.itemLabel.text = incomeExpense.title
            cell.moneyLabel.text = incomeExpense.money?.description
            
            return cell
            
        })
    }
    */
    func setInfo() {
        
        var incomeTotal = 0 //總收入
        var expenseTotal = 0 //總支出
        var resultTotal = 0 //收支總和
        
        /*
        //將每個日期的收支 進行計算
        dateIncomeExpenseArray.forEach { (dateIncomeExpense) in
            //每個日期的收入
            let incomeArray = dateIncomeExpense.incomeExpense.filter { (incomeExpense) -> Bool in
                guard let incomeMoney = incomeExpense.money else {return false}
                return incomeMoney >= 0
            }
            //每個日期的收入總和
            incomeArray.forEach { (income) in
                if let money = income.money{
                    incomeTotal += money
                }
            }
            //每個日期的支出
            let expenseArray = dateIncomeExpense.incomeExpense.filter { (incomeExpense) -> Bool in
                guard let expenseMoney = incomeExpense.money else {return false}
                return expenseMoney < 0
            }
            //每個日期的支出總和
            expenseArray.forEach { (expense) in
                if let money = expense.money{
                    expenseTotal += money
                }
            }
            
            //每個日期的收支總和
            dateIncomeExpense.incomeExpense.forEach { (incomeExpense) in
                if let money = incomeExpense.money{
                    resultTotal += money
                }
            }
        }
        
        incomeTotalLabel.text = incomeTotal.description
        expenseTotalLabel.text = expenseTotal.description
        totalResultLabel.text = resultTotal.description
        */
        
        
        //CoreData
        fetchedResultsController?.fetchedObjects?.forEach({ incomeExpenseDate in
            let money = incomeExpenseDate.money
            
            switch money >= 0 {
            
            case true :
                incomeTotal += Int(money)
            case false:
                expenseTotal += Int(money)
            default:
                break
            }
        })
        
        incomeTotalLabel.text = incomeTotal.description
        expenseTotalLabel.text = expenseTotal.description
        totalResultLabel.text = (incomeTotal + expenseTotal).description
        
        
    }
    
    //更新incomeExpenseArray 將每個日期的收支陣列，全部加到一個收支陣列 & 存檔
    func updateIncomeExpenseArray() {
        
        var newIncomeExpenseArray = [IncomeExpense]()
        
        dateIncomeExpenseArray.forEach { (dateIncomeExpense) in
            dateIncomeExpense.incomeExpense.forEach { (incomeExpense) in
                newIncomeExpenseArray.append(incomeExpense)
            }
        }
        
        incomeExpenseArray = newIncomeExpenseArray
        
        //存檔 - incomeExpenseArray
        IncomeExpense.saveDocumentDirectory(incomeExpenseArray: incomeExpenseArray)
    }
    
    //將要傳回上一頁的資料，放置delegate的func中
    func passIncomeExpense() {
        delegate?.resultTableViewController(self, incomeExpenseArray: incomeExpenseArray, dateIncomeExpenseArray: dateIncomeExpenseArray)
    }
    
    /*
    //客製化 cell 左滑 功能的 func
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
    }
    
    //客製化 cell 右滑 功能的 func
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
    }
    */
    
    //cell 向左滑刪除的功能，左滑刪除後要執行甚麼內容 & 刪除並修改存檔
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("刪除")
        /*
        
        //當刪除最後一個Cell時,不能呼叫deleteRows而應該呼叫deleteSections。
        //如果section裡面已經沒有cell內容時，則刪除整個section，但section不能為0，最少要為1
        //如果sectino裡面有cell時，執行 移除 資料陣列內成員 並刪除cell
        if dateIncomeExpenseArray[indexPath.section].incomeExpense.count > 0 {
            print("section\(indexPath.section)","cellCount\(dateIncomeExpenseArray[indexPath.section].incomeExpense.count)")
            
            dateIncomeExpenseArray[indexPath.section].incomeExpense.remove(at: indexPath.row) //移除 指定cell的內容 資料Array的成員
            tableView.deleteRows(at: [indexPath], with: .left) //刪除 指定的cell，如果前面沒有先移除Array的成員，會閃退
            
            
            
            print("執行後section\(indexPath.section)","cellCount\(dateIncomeExpenseArray[indexPath.section].incomeExpense.count)")
            
            //cell的沒有內容，成員數count為0時，要刪secion
            if dateIncomeExpenseArray[indexPath.section].incomeExpense.count == 0 {
                
                print("移除section")
                print("section\(indexPath.section)","SectionCount\(dateIncomeExpenseArray.count)")

                dateIncomeExpenseArray.remove(at: indexPath.section) //移除 指定section的內容 資料Array的成員
                tableView.deleteSections([indexPath.section], with: .left) //刪除 指定的section
                
                print("執行後section\(indexPath.section)","SectionCount\(dateIncomeExpenseArray.count)")
                
            }
            
        }
        
        //tableView.reloadData()
        //要重新整理，才會將編輯好的資料重新顯示，但有添加新增的動畫效果，則可以不用reloadData，因為反而會吃掉一些動畫效果
        
        setInfo()
        updateIncomeExpenseArray() //內含 存檔 - incomeExpenseArray
        passIncomeExpense()
        
        //存檔 - dateIncomeExpenseArray
        DateIncomeExpense.saveDocumentDirectory(dateIncomeExpenseArray: dateIncomeExpenseArray)
        
        //在呼叫deleteRows時,會自動呼叫numberOfRowsInSection和numberOfSections這兩個函式。
        //即系統會判斷刪除操作前,cell和section的個數是否已經修改,若未修改會直接crash並提示以下錯誤。
        //另外,當刪除最後一個Cell時,不能呼叫deleteRows而應該呼叫deleteSections。
        */
        /*
        reason: 'Invalid update: invalid number of rows in section 0. The number of rows contained in an existing section after the update (6) must be equal to the number of rows contained in that section before the update (6), plus or minus the number of rows inserted or deleted from that section (0 inserted, 1 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).'
         
         Thread 1: "Invalid update: invalid number of sections. The number of sections contained in the table view after the update (1) must be equal to the number of sections contained in the table view before the update (1), plus or minus the number of sections inserted or deleted (0 inserted, 1 deleted).
        */
        
        //————————————————————————————————————————————————————————————————————————————————
        
        //CoreData - Delete
        
        //得到 滑動Cell的路徑位置 對應的 資料，即是 要刪除的資料
        let removeSection = fetchedResultsController!.object(at: indexPath)
        
        //CoreData 刪除
        self.context.delete(removeSection)
        
        //CoreData 儲存
        do {
            try self.context.save()
        }
        catch {
            print("刪除後儲存失敗",error)
        }
        
        //CoreData 擷取資料
        self.fetchIncomeExpenseDate()
        
        
    }
    //自定義 section表頭 的格式
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header.textLabel?.textAlignment = .center
        header.textLabel?.textColor = UIColor.black
        print("section---------------------",section)
    }
    
    
    //為每個section上名字
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        //let dateString = formatter.string(from: dateIncomeExpenseArray[section].date!)
        //return dateString
        
        return fetchedResultsController?.sections?[section].name
    }
    
    /*
    //傳資料到下一頁 ReportTableViewController
    @IBSegueAction func analyze(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> ReportTableViewController? {
        let reportTableVC =  ReportTableViewController(coder: coder)
        
        reportTableVC?.incomeExpenseArray = incomeExpenseArray
        reportTableVC?.dateIncomeExpenseArray = dateIncomeExpenseArray
        
        reportTableVC?.incomeListArray = incomeListArray
        reportTableVC?.expenseListArray = expenseListArray
        
        return reportTableVC
    }
    */
    
    //傳資料到下一頁 AnalysisTableViewController
    @IBSegueAction func passListsToAnalyssTVC(_ coder: NSCoder) -> AnalysisTableViewController? {
        let analysisTableVC = AnalysisTableViewController(coder: coder)
        
        analysisTableVC?.incomeListArray = incomeListArray
        analysisTableVC?.expenseListArray = expenseListArray
        
        return analysisTableVC
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setInfo()
        
        //setDiffableDataSource()
        
        //snapshot.appendSections(dateIncomeExpenseArray) //加入 section ，讓列表有一個 incomeExpense section。
        
        //snapshot.appendItems(incomeExpenseArray) //將 內容 加到 指定的section
        
        //dataSource!.apply(snapshot, animatingDifferences: false)
        //dataSource?.apply(snapshot, animatingDifferences: false, completion: nil)
        //tableView.reloadData()
        
        //tableView.dataSource = dataSource
        
        //————————————————————————————————————————————————————————————————————————————————
        
        //CoreData 擷取資料
        fetchIncomeExpenseDate()
        
    }
    
    // MARK: - Table view data source
    
    
    //幾個sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("執行numberOfSections")
        
        //return dateIncomeExpenseArray.count
        return fetchedResultsController?.sections?.count ?? 0 //CoreData方式
        
    }
    
    //每個sections的內容數
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("執行numberOfRowsInSection，section為\(section)")
        
        //let rows = dateIncomeExpenseArray[section].incomeExpense.count
        
        //return rows
        
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0 //CoreData方式
    }
    
    
    //每個sections的內容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as? ResultTableViewCell else { return UITableViewCell() }
        /*
        cell.itemImageView.image = UIImage(named: dateIncomeExpenseArray[indexPath.section].incomeExpense[indexPath.row].imageSelectedName!)
        cell.itemLabel.text = dateIncomeExpenseArray[indexPath.section].incomeExpense[indexPath.row].title
        cell.moneyLabel.text = dateIncomeExpenseArray[indexPath.section].incomeExpense[indexPath.row].money?.description
        */
        
        //CoreData 方式
        if let fetchRC = fetchedResultsController {
            cell.itemImageView.image = UIImage(named: fetchRC.object(at: indexPath).imageSelectedName!)
            cell.itemLabel.text = fetchRC.object(at: indexPath).title
            cell.moneyLabel.text = fetchRC.object(at: indexPath).money.description
        }
        
        return cell
    }
    
    
    /* 表格視圖的條件編輯
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     //如果您不希望指定的項目可編輯，則返回false。
     return true
     }
     */
    
    /* 編輯表格視圖
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     //創建適當類的新實例，將其插入數組，然後在表視圖中添加新行
     }
     }
     */
    
    /* 重新排列表格視圖
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /* 表格視圖的有條件重新排列。
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
     
     //使用segue.destination獲取新的視圖控制器。
     
     // Pass the selected object to the new view controller.
     
     //將選定的對像傳遞給新的視圖控制器。
     }
     */
    deinit {
        print("ResultTableViewController＿＿＿＿＿死亡")
    }
}
