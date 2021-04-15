//
//  AnalysisTableViewController.swift
//  DemoXIII
//
//  Created by homejay on 2021/4/15.
//

import UIKit
import CoreData

class AnalysisTableViewController: UITableViewController {
    @IBOutlet weak var incomeExpenseSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateSegmentedControl: UISegmentedControl!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    @IBOutlet weak var topView: UIView!
    
    var incomeListArray = [List]() //接收傳過來的 支出 選項清單
    var expenseListArray = [List]() //接收傳過來的 收入 選項清單
    
    var newIncomeListArray = [List]() //相同標籤且含有總金額之 收入List陣列
    var newExpenseListArray = [List]() //相同標籤且含有總金額之 支出List陣列
    
    var newListArray = [List]()
    
    var incomeTotal = 0 //總收入
    var expenseTotal = 0 //總支出
    
    var startDateString = "" //起始日期 字串
    var endDateString = "" //結束日期 字串
    var starDate = Date() //起始日期
    var endDate = Date() //結束日期
    var date = Date() //當天
    var year:Int = 0 //年
    var month:Int = 0 //月
    var day:Int = 0 //日
    
    var alert = UIAlertController()
    
    //CoreData
    let persistenContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<IncomeExpenseDate>(entityName: "IncomeExpenseDate")
    var fetchedResultsController: NSFetchedResultsController<IncomeExpenseDate>?
    
    //CoreData - Read 篩選並擷取資料
    func fetchFilteredData(format:NSPredicate? ) {
        
        //Date as CVarArg 意思是 要轉成NS格式
        //fetchRequest.predicate = NSPredicate(format: <#T##String#>, <#T##args: CVarArg...##CVarArg#>)
        // https://nspredicate.xyz/#contains-certain-string //NSPredicate 條件寫法的參考網址
        // %@ 可代表 String Date
        // %i 可代表 Int
        //request.predicate = NSPredicate(format: "name CONTAINS %@", "homejay")//屬性 name 包含 字串，字串為homejay
        //最多只能兩個比 再用 NSCompoundPredicate 接起來
        
        
        
        fetchRequest.predicate = format
        
        //建立 NSFetchedResultsController
        let sortDescriptor = NSSortDescriptor(key: "money", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //FRC需要排序，SectionNameKeyPath 是用來分 Fetched Object 的 Section 所屬。
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        //擷取資料
        do {
            try fetchedResultsController?.performFetch()
            
        }catch {
            print("擷取資料失敗")
        }
        
    }
    
    //建立 新的tableView清單(各標籤 總金額 與 百分比 的清單)
    func caculateSameTitleMoney(_ listArray:[List]) -> [List] {
        
        var sameTitleIncomeExpenseListArray = [List]()
        
        //將同標籤的資料抓出來
        listArray.forEach { list in
            
            guard let title = list.title else {return}
            
            guard let sameTitleArray = (fetchedResultsController?.fetchedObjects?.filter({ incomeExpenseDate in
                return incomeExpenseDate.title == title
            })) else {return}
            
            print("sameTitleArray.count",sameTitleArray.count)
            
            //計算該標籤總金額
            var sameTitleMoney = 0
            sameTitleArray.forEach({ incomeExpense in
                sameTitleMoney += Int(incomeExpense.money)
            })
            
            print("sameTitleMoney",sameTitleMoney)
            
            //計算全部標籤總金額
            var totalMoney = 0
            fetchedResultsController?.fetchedObjects?.forEach { (incomeExpense) in
                totalMoney += Int(incomeExpense.money)
            }
            
            if totalMoney > 0 {
                incomeTotal = totalMoney
            }else{
                expenseTotal = totalMoney
            }
            
            print("totalMoney\(totalMoney)")
            
            //該標籤百分比
            let percent = CGFloat(sameTitleMoney) / CGFloat(totalMoney) * 100
            print("percent\(percent)")
            
            //有金額的話，才加到List清單
            if sameTitleMoney != 0 {
                let incomeExpenseList = List(imageName: list.imageName, imageSelectedName: list.imageSelectedName, title: list.title, totalMoney: sameTitleMoney,percent: percent)
                
                sameTitleIncomeExpenseListArray.append(incomeExpenseList)
            }
        }
        print("sameTitleIncomeExpenseListArray.count",sameTitleIncomeExpenseListArray.count)
        return sameTitleIncomeExpenseListArray
    }
    
    
    //建立並更新 年 月 日
    func makeYearMonthDay(_ specificDate:Date) {
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: specificDate)
        
        guard let year = dateComponents.year else { return }
        guard let month = dateComponents.month else { return }
        guard let day = dateComponents.day else { return }
        
        self.year = year
        self.month = month
        self.day = day
    }
    
    //切換日期
    @IBAction func dateSegmentValueChange(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0: //月
            
            //得到該日期的月
            makeYearMonthDay(date)
            let currentMonth = Int64(month)
            
            switch incomeExpenseSegmentedControl.selectedSegmentIndex {
            case 0: //篩選 收入
    
                let predicate = NSPredicate(format: "month == %i AND money >= %i", currentMonth,0)
                fetchFilteredData(format: predicate)
                
                newListArray = caculateSameTitleMoney(incomeListArray)
            default: //篩選 支出

                let predicate = NSPredicate(format: "month == %i AND money < %i", currentMonth,0)
                fetchFilteredData(format: predicate)
                
                newListArray = caculateSameTitleMoney(expenseListArray)
            }
            
            dateLabel.text = makeDateString(date: date, dateFormat: "yyyy年MM月")
            //incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
            
        case 1: //半年
            
            makeYearMonthDay(date)
            
            //生成一個 當年 當月 月中的日期
            guard let beginningOfMonth = DateComponents(calendar: Calendar.current,
                                                        timeZone: TimeZone.current,
                                                        year: year,
                                                        month: month,
                                                        day: 15,
                                                        hour: 0,
                                                        minute: 0,
                                                        second: 0).date else { return }
            
            let timeStampSec = beginningOfMonth.timeIntervalSince1970 //該日期的時間秒數
            
            let fiveMonthsSec = TimeInterval(13149000) //五個月的總秒數
            
            let sixMonthAgoDate = Date(timeIntervalSince1970: timeStampSec - fiveMonthsSec) //得到五個月前的日期
            
            let components = Calendar.current.dateComponents(in: TimeZone.current, from: sixMonthAgoDate)
           
            guard let sixMonthAgoYear = components.year else { return } //得到該日期的年
            guard let sixMonthAgoMonth = components.month else { return } //得到該日期的月

            let yearOfSixMonthAgo = Int64(sixMonthAgoYear)
            let monthOfSixMonthAgo = Int64(sixMonthAgoMonth)
            
            let currentYear = Int64(year)
            
            switch incomeExpenseSegmentedControl.selectedSegmentIndex {
            case 0: //篩選 收入
                let predicate = NSPredicate(format: "year == %i AND month <= %i AND money >= %i",
                                            currentYear,monthOfSixMonthAgo,0)
                
                //如果橫跨年度
                if currentYear - yearOfSixMonthAgo == 1 {
                    let predicate2 = NSPredicate(format: "year == %i AND month >= %i AND money >= %i",
                                                 yearOfSixMonthAgo,monthOfSixMonthAgo,0)
                    
                    let predicateCompound = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate,predicate2])
                    
                    fetchFilteredData(format: predicateCompound)
                }else{
                    fetchFilteredData(format: predicate)
                }
                
                newListArray = caculateSameTitleMoney(incomeListArray)
            default:// 篩選 支出
                let predicate = NSPredicate(format: "year == %i AND month <= %i AND money < %i",
                                            currentYear,monthOfSixMonthAgo,0)
                
                //如果橫跨年度
                if currentYear - yearOfSixMonthAgo == 1 {
                    let predicate2 = NSPredicate(format: "year == %i AND month >= %i AND money < %i",
                                                 yearOfSixMonthAgo,monthOfSixMonthAgo,0)
                    
                    let predicateCompound = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate,predicate2])
                    
                    fetchFilteredData(format: predicateCompound)
                }else{
                    fetchFilteredData(format: predicate)
                }
                
                newListArray = caculateSameTitleMoney(expenseListArray)
            }
            
            let start = makeDateString(date: sixMonthAgoDate, dateFormat: "yyyy年MM月")
            let end = makeDateString(date: date, dateFormat: "yyyy年MM月")
            dateLabel.text = "\(start)~\(end)"
            //incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
            
        case 2: //今年
            
            makeYearMonthDay(date)
            let currentYear = Int64(year)
            
            switch incomeExpenseSegmentedControl.selectedSegmentIndex {
            case 0: //篩選 收入
                
                let predicate = NSPredicate(format: "year == %i AND money >= %i", currentYear,0)
                fetchFilteredData(format: predicate)
                
                newListArray = caculateSameTitleMoney(incomeListArray)
            default: //篩選 支出
                
                let predicate = NSPredicate(format: "year == %i AND money < %i", currentYear,0)
                fetchFilteredData(format: predicate)
                
                newListArray = caculateSameTitleMoney(expenseListArray)
            }
            
            dateLabel.text = makeDateString(date: date, dateFormat: "yyyy年")
            //incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
        default:
            
            makeDateToDateAlert()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //切換收支
    @IBAction func incomeExpenseSegmentValueChange(_ sender: UISegmentedControl) {
        
        dateSegmentValueChange(dateSegmentedControl)
        
    }
    
    //建立日期字串格式
    func makeDateString(date:Date,dateFormat:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    @IBAction func startDatePickerChange(_ sender: UIDatePicker) {
        
        startDateString =  makeDateString(date: sender.date, dateFormat: "yyyy年MM月dd日")
        alert.textFields![0].text = startDateString
        
        starDate = sender.date
        print(starDate)
    }
    
    @IBAction func endDatePickerChange(_ sender: UIDatePicker) {
        
        endDateString = makeDateString(date: sender.date, dateFormat: "yyyy年MM月dd日")
        alert.textFields![1].text = endDateString
        
        endDate = sender.date
        print(endDate)
    }
    
    func makeDateToDateAlert() {
        
        startDatePicker.backgroundColor = .white

        alert = UIAlertController(title: "自訂區間", message: "請選擇日期", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "起始日期"
            textField.inputView = self.startDatePicker
            textField.text = self.startDateString
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "結束日期"
            textField.inputView = self.endDatePicker
            textField.text = self.endDateString
        }
        
        //let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        let okAction = UIAlertAction(title: "ok", style: .default) { [self] (action) in
            if endDate >= starDate{
                
                let dateStart = starDate as NSDate
                let dateEnd = endDate as NSDate
                
                //starDate as CVarArg 意思是 要轉成NS格式
                switch incomeExpenseSegmentedControl.selectedSegmentIndex {
                case 0: //篩選 收入
                    let predicate = NSPredicate(format: "date >= %@ AND money >= %i", dateStart,0)
                    let predicate2 = NSPredicate(format: "date <= %@ AND money >= %i", dateEnd,0)
                    let predicateCompound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicate2])
                    fetchFilteredData(format: predicateCompound)
                    newListArray = caculateSameTitleMoney(incomeListArray)
                    tableView.reloadData()
                default: //篩選 支出
                    let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND money < %i", dateStart,dateEnd,0)
                    fetchFilteredData(format: predicate)
                    newListArray = caculateSameTitleMoney(expenseListArray)
                }
                
                let start = makeDateString(date: starDate, dateFormat: "yyyy年MM月dd日")
                let end = makeDateString(date: endDate, dateFormat: "yyyy年MM月dd日")
                dateLabel.text = "\(start)~\(end)"
                //incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
                
            }else{
                print("起訖日有誤唷")
                let errorAlert = AlertController.shared.makeSingleAlert(title: "提醒您", message: "起始日不可大於結束日唷～")
                present(errorAlert, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeYearMonthDay(date)
        
        dateSegmentValueChange(dateSegmentedControl)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        newListArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnalysisTableViewCell", for: indexPath) as? AnalysisTableViewCell else { return UITableViewCell()}

        cell.itemImageView.image = UIImage(named: newListArray[indexPath.row].imageSelectedName!)
        cell.itemLabel.text = newListArray[indexPath.row].title
        cell.moneyLabel.text = newListArray[indexPath.row].totalMoney.description
        cell.percentLabel.text = String(format: "%.1f", newListArray[indexPath.row].percent) + "%"
        
        print("newListArray[indexPath.row].totalMoney.description\(newListArray[indexPath.row].totalMoney.description)")

        return cell
    }
    

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

}
