//
//  ReportTableViewController.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import UIKit

class ReportTableViewController: UITableViewController {
    @IBOutlet weak var dateSegmentLabel: UILabel!
    @IBOutlet weak var incomeExpenseSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateStringLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet var startDatePicer: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    
    var incomeExpenseArray = [IncomeExpense]() //接收傳過來的 收支 陣列
    var dateIncomeExpenseArray = [DateIncomeExpense]()//接收傳過來的 每筆日期收支陣列
    
    var incomeListArray = [List]() //接收傳過來的 支出 選項清單
    var expenseListArray = [List]() //接收傳過來的 收入 選項清單
    
    var incomeArray = [IncomeExpense]() //收入 陣列
    var expenseArray = [IncomeExpense]() // 支出 陣列
    
    var newIncomeListArray = [List]() //相同標籤且含有總金額之 收入List陣列
    var newExpenseListArray = [List]() //相同標籤且含有總金額之 支出List陣列
    
    var incomeTotal = 0 //總收入
    var expenseTotal = 0 //總支出
    
    var year:Int = 0 //年
    var month:Int = 0 //月
    var day:Int = 0 //日
    
    let date = Date()//當天
    
    let aDegree = CGFloat.pi / 180 //一度單位
    let radius = CGFloat(80) //半徑
    let lineWidth = CGFloat(40) //線的寬度
    var percentPath = [CGFloat]() //百分比陣列
    var startAngle = CGFloat(270) //從時鐘的12點位置開始
    
    var startDateString = "" //起始日期 字串
    var endDateString = "" //結束日期 字串
    
    var starDate = Date() //起始日期
    var endDate = Date() //結束日期
    
    var alert = UIAlertController()
    
    var balanceLabel = UILabel() //總收入 或 總支出的label
    var donutView = UIView() // 裝甜甜圈的View
    
    //起迄年月日
    var startYear = 0
    var startMonth = 0
    var startDay = 0
    var endYear = 0
    var endMonth = 0
    var endDay = 0
    
    //建立並更新 年 月 日
    func makeYearMonthDay() {
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        
        guard let year = dateComponents.year else { return }
        guard let month = dateComponents.month else { return }
        guard let day = dateComponents.day else { return }
        
        self.year = year
        self.month = month
        self.day = day
    }
    
    //計算每個標籤的總金額，並生成ListArray
    func caculateSameTitleMoney(listArray:[List],incomeExpenseArray:[IncomeExpense]) -> [List] {
        
        var sameTitleIncomeExpenseListArray = [List]()
        
        listArray.forEach { (list) in
            //將同標籤的資料抓出來
            let sameTitleIncomeExpenseArray = incomeExpenseArray.filter { (income) -> Bool in
                return income.title == list.title
            }
            
            //計算該標籤總金額
            var sameTitleIncomeExpenseMoney = 0
            sameTitleIncomeExpenseArray.forEach { (income) in
                if let money = income.money {
                    sameTitleIncomeExpenseMoney += money
                }
            }
            print("sameTitleIncomeExpenseMoney\(sameTitleIncomeExpenseMoney)")
            
            //計算全部標籤總金額
            var totalMoney = 0
            incomeExpenseArray.forEach { (incomeExpense) in
                if let money = incomeExpense.money {
                    totalMoney += money
                }
            }
            if totalMoney > 0 {
                incomeTotal = totalMoney
            }else{
                expenseTotal = totalMoney
            }
            
            print("totalMoney\(totalMoney)")
            //該標籤百分比
            let percent = CGFloat(sameTitleIncomeExpenseMoney) / CGFloat(totalMoney) * 100
            print("percent\(percent)")
            
            //有金額的話，才加到List清單
            if sameTitleIncomeExpenseMoney != 0 {
                let incomeExpenseList = List(imageName: list.imageName, imageSelectedName: list.imageSelectedName, title: list.title, totalMoney: sameTitleIncomeExpenseMoney,percent: percent)
                
                sameTitleIncomeExpenseListArray.append(incomeExpenseList)
            }
        }
        return sameTitleIncomeExpenseListArray
    }
    
    //更新 newListArray，將濾出來的dateInExArray轉為InExArray再分成 InArray 與 ExArray
    func updateNewIncomeExpenseListArray(dateIncomeExpenseArray:[DateIncomeExpense]){
        var newIncomeExpenseArray = [IncomeExpense]() //當月的所有收支
        
        //將每個日期的收支 加到 新的陣列 產生所有收支
        dateIncomeExpenseArray.forEach { (dateIncomeExpense) in
            dateIncomeExpense.incomeExpense.forEach { (incomeExpense) in
                newIncomeExpenseArray.append(incomeExpense)
            }
        }
        
        
        print("newIncomeExpenseArray.count\(newIncomeExpenseArray.count)")
        //當月收入
        incomeArray = newIncomeExpenseArray.filter { (incomeExpense) -> Bool in
            return incomeExpense.money! >= 0
        }
        print("incomeArray.count\(incomeArray.count)")
        
        //當月支出
        expenseArray = newIncomeExpenseArray.filter { (incomeExpense) -> Bool in
            return incomeExpense.money! < 0
        }
        print("expenseArray.count\(expenseArray.count)")
        
        newIncomeListArray = caculateSameTitleMoney(listArray: incomeListArray, incomeExpenseArray: incomeArray)
        newExpenseListArray = caculateSameTitleMoney(listArray: expenseListArray, incomeExpenseArray: expenseArray)
        
    }
    
    //建立日期字串格式
    func makeDateString(date:Date,dateFormat:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    @IBAction func segmentedValueChange(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            
            //當月每個日期的紀錄
            let monthIncomeExpenseArray =  dateIncomeExpenseArray.filter { (dateIncomeExpense) -> Bool in
                return dateIncomeExpense.year == year &&
                       dateIncomeExpense.month == month
            }
            
            print("monthIncomeExpenseArray.count\(monthIncomeExpenseArray.count)")
            
            updateNewIncomeExpenseListArray(dateIncomeExpenseArray: monthIncomeExpenseArray)
            
            dateStringLabel.text = makeDateString(date: date, dateFormat: "yyyy年MM月")
            incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
        case 1:
            
            //生成一個 當年 當月 月中的日期
            guard let beginningOfMonth = DateComponents(calendar: Calendar.current,
                                       timeZone: TimeZone.current,
                                       year: year,
                                       month: month,
                                       day: 15,
                                       hour: 0,
                                       minute: 0,
                                       second: 0).date else { return }
            //該日期的時間秒數
            let timeStampSec = beginningOfMonth.timeIntervalSince1970
            //五個月的總秒數
            let fiveMonthsSec = TimeInterval(13149000)
            
            let sixMonthAgoDate = Date(timeIntervalSince1970: timeStampSec - fiveMonthsSec)
            //得到五個月前的日期
            let components = Calendar.current.dateComponents(in: TimeZone.current, from: sixMonthAgoDate)
            //得到該日期的月
            guard let sixMonthAgoMonth = components.month else { return }
            
            
            //六個月內每個日期的紀錄
            let SixMonthsIncomeExpenseArray =  dateIncomeExpenseArray.filter { (dateIncomeExpense) -> Bool in
                
                if let dateInExYear = dateIncomeExpense.year,
                   let dateInExMonth = dateIncomeExpense.month,
                   dateInExYear == year && dateInExMonth <= month || dateInExMonth >= sixMonthAgoMonth {
                    print("成功")
                    return true
                }else{
                    print("失敗")
                    return false
                }
            }
            
            print("SixMonthsIncomeExpenseArray.count\(SixMonthsIncomeExpenseArray.count)")
            
            updateNewIncomeExpenseListArray(dateIncomeExpenseArray: SixMonthsIncomeExpenseArray)
            
            let start = makeDateString(date: sixMonthAgoDate, dateFormat: "yyyy年MM月")
            let end = makeDateString(date: date, dateFormat: "yyyy年MM月")
            dateStringLabel.text = "\(start)~\(end)"
            incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
        case 2:
            
            //當年度 每個日期的紀錄
            let yearIncomeExpenseArray =  dateIncomeExpenseArray.filter { (dateIncomeExpense) -> Bool in
                return dateIncomeExpense.year == year
            }
            
            print("yearIncomeExpenseArray.count\(yearIncomeExpenseArray.count)")
            
            updateNewIncomeExpenseListArray(dateIncomeExpenseArray: yearIncomeExpenseArray)
            
            dateStringLabel.text = makeDateString(date: date, dateFormat: "yyyy年")
            incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
        default:
            
            makeAlert()
        }
        
        tableView.reloadData()
    }
    @IBAction func startDatePickerChange(_ sender: UIDatePicker) {
        
        startDateString =  makeDateString(date: sender.date, dateFormat: "yyyy年MM月dd日")
        alert.textFields![0].text = startDateString
        
        starDate = sender.date
        print(starDate)
        
        let components = Calendar.current.dateComponents(in: TimeZone.current, from: sender.date)
        
        startYear = components.year!
        startMonth = components.month!
        startDay = components.day!
        print(startYear,startMonth,startDay)
        
    }
    
    @IBAction func endDatePickerChange(_ sender: UIDatePicker) {
        
        endDateString = makeDateString(date: sender.date, dateFormat: "yyyy年MM月dd日")
        alert.textFields![1].text = endDateString
        
        endDate = sender.date
        print(endDate)
        
        let components = Calendar.current.dateComponents(in: TimeZone.current, from: sender.date)
        
        endYear = components.year!
        endMonth = components.month!
        endDay = components.day!
        print(endYear,endMonth,endDay)
        
    }
    
    func makeAlert() {
        
        startDatePicer.backgroundColor = .white

        alert = UIAlertController(title: "自訂區間", message: "請選擇日期", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "起始日期"
            textField.inputView = self.startDatePicer
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
                
                let customizeIncomeExpenseArray = dateIncomeExpenseArray.filter { (dateIncomeExpense) -> Bool in
                    if let dateInExDate = dateIncomeExpense.date {
                        let bool = dateInExDate >= starDate && dateInExDate <= endDate
                        print("成功")
                        return bool
                    }else{
                        print("失敗")
                        return false
                    }
                }
                
                updateNewIncomeExpenseListArray(dateIncomeExpenseArray: customizeIncomeExpenseArray)
                
                let start = makeDateString(date: starDate, dateFormat: "yyyy年MM月dd日")
                let end = makeDateString(date: endDate, dateFormat: "yyyy年MM月dd日")
                dateStringLabel.text = "\(start)~\(end)"
                incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
                
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
    
    func makeBalanceLable() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.backgroundColor = UIColor.clear
        
        return label
    }
    
    //畫甜甜圈圖
    func makeCircle(newIncomeExpenseListArray:[List]) -> UIView {
        
        let donutView = UIView(frame: CGRect(x: 0, y: 0, width: (radius+lineWidth)*2 , height: (radius+lineWidth)*2 ))
        donutView.backgroundColor = UIColor.clear
        
        newIncomeExpenseListArray.forEach { (list) in
            percentPath.append(list.percent)
        }
        print("percentPath\(percentPath)")
        
        percentPath.forEach { (percent) in
            let endAngle = startAngle + (360 * percent / 100) - 2 //2是為了讓頭尾有間隔
            
            let circlePath = UIBezierPath(arcCenter: donutView.center, radius: radius, startAngle: aDegree * startAngle, endAngle: aDegree * endAngle, clockwise: true)
            
            let circleShapeLayer = CAShapeLayer()
            
            circleShapeLayer.path = circlePath.cgPath
            circleShapeLayer.strokeColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1).cgColor
            circleShapeLayer.lineWidth = lineWidth
            circleShapeLayer.fillColor = UIColor.clear.cgColor
            circleShapeLayer.lineCap = .butt
            
            donutView.layer.addSublayer(circleShapeLayer)
            
            startAngle = endAngle + 2 //2是為了讓頭尾有間隔
        }

        return donutView
    }
    
    @IBAction func incomeExpenseSegmentValueChange(_ sender: UISegmentedControl) {
        
        let center = CGPoint(x: topView.bounds.midX, y: topView.bounds.midY+50)
        
        
        switch sender.selectedSegmentIndex {
        case 0:
            
            donutView.removeFromSuperview()
            print("topView.subviews.count",topView.subviews.count)
            
            donutView = makeCircle(newIncomeExpenseListArray: newIncomeListArray)
            
            balanceLabel = makeBalanceLable()
            balanceLabel.text = "總收入\n" + incomeTotal.description
            balanceLabel.center = donutView.center

            donutView.addSubview(balanceLabel)
            donutView.center = center
            
            topView.addSubview(donutView)
            print("topView.subviews.count After",topView.subviews.count)

        default:
            
            donutView.removeFromSuperview()
            print("topView.subviews.count",topView.subviews.count)
            
            donutView = makeCircle(newIncomeExpenseListArray: newExpenseListArray)
            
            balanceLabel = makeBalanceLable()
            balanceLabel.text = "總支出\n" + expenseTotal.description
            balanceLabel.center = donutView.center
            
            donutView.addSubview(balanceLabel)
            donutView.center = center
            
            topView.addSubview(donutView)
            print("topView.subviews.count After",topView.subviews.count)

        }
        
        tableView.reloadData()
    }
    @IBAction func startDateChange(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        startDateString = formatter.string(from:self.startDatePicer.date)
        
    }
    @IBAction func endDateChange(_ sender: UIDatePicker) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("incomeExpenseArray.count\(incomeExpenseArray.count)")
        print("dateIncomeExpenseArray.count\(dateIncomeExpenseArray.count)")
        
        print("incomeListArray\(incomeListArray.count)")
        print("expenseListArray\(expenseListArray.count)")
        
        makeYearMonthDay()
        segmentedValueChange(dateSegmentedControl)
        incomeExpenseSegmentValueChange(incomeExpenseSegmentedControl)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch incomeExpenseSegmentedControl.selectedSegmentIndex {
        case 0:
            print("newIncomeListArray.count\(newIncomeListArray.count)")
            return newIncomeListArray.count
        default:
            print("newExpenseListArray.count\(newExpenseListArray.count)")
            return newExpenseListArray.count
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReportTableViewCell", for: indexPath) as? ReportTableViewCell else { return UITableViewCell() }
        
        switch incomeExpenseSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.itemImageView.image = UIImage(named: newIncomeListArray[indexPath.row].imageSelectedName!)
            cell.itemLabel.text = newIncomeListArray[indexPath.row].title
            cell.moneyLabel.text = newIncomeListArray[indexPath.row].totalMoney.description
            cell.percentLabel.text = String(format: "%.1f", newIncomeListArray[indexPath.row].percent) + "%"
            
            print("newIncomeListArray[indexPath.row].totalMoney.description\(newIncomeListArray[indexPath.row].totalMoney.description)")
        default:
            cell.itemImageView.image = UIImage(named: newExpenseListArray[indexPath.row].imageSelectedName!)
            cell.itemLabel.text = newExpenseListArray[indexPath.row].title
            cell.moneyLabel.text = newExpenseListArray[indexPath.row].totalMoney.description
            cell.percentLabel.text = String(format: "%.1f", newExpenseListArray[indexPath.row].percent) + "%"
            
            
            print("newExpenseListArray[indexPath.row].totalMoney.description\(newExpenseListArray[indexPath.row].totalMoney.description)")
        }

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
    
    deinit {
        print("ReportTableViewController＿＿＿＿＿死亡")
    }

}
