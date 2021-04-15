//
//  IncomeExpenseRecord.swift
//  DemoX
//
//  Created by homejay on 2021/2/20.
//

import Foundation

struct IncomeExpense:Hashable,Codable {
    let money:Int? //紀錄時的金額
    let time:Date? //紀錄時的日期
    let imageName:String? //紀錄時的圖像名
    let imageSelectedName:String? //紀錄被點擊時的圖像名
    let title:String? //紀錄項目名稱
    let year:Int? //紀錄時的年
    let month:Int? //紀錄時的月
    let day:Int? //紀錄時的日
    
    //暫存位置
    static let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first //要存檔的資料夾路徑 陣列.first
    //存檔 - FileManager (可以儲存與修改檔案)
    static func saveDocumentDirectory(incomeExpenseArray: [Self]) { // 原為[IncomeExpense] 改成 [Self]更好，大寫的S，這邊Self代表這個struct物件 IncomeExpense
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(incomeExpenseArray), //資料 編碼 成data
           let url = Self.documentDirectoryURL?.appendingPathComponent("incomeExpense"){ //取一個路徑名incomeExpense，原為incomeExpense.documentDirectoryURL? 改成 Self.documentDirectoryURL? 更好， 大寫的S，這邊Self代表這個struct物件 IncomeExpense
            
            do {
                try data.write(to: url) //呼叫write，將data寫入url路徑 即 將data存到存檔的地方
                //write為 新增 或 覆蓋，沒檔案時新增，有的話覆蓋
            } catch {
                print(error) //這邊嚴謹一點可以再寫alert跳出錯誤視窗，失敗的情況通常為容量滿了
            }
            
        }
        
    }
    
    //讀檔 - FileManager (可以儲存與修改檔案)，東西有讀出來，才會佔記憶體，不會像UserDefaults.standard那樣
    static func readDocumentDirectory() -> [Self]? { //回傳的資料要加optional，不然 nil 會不兼容
        let decoder = JSONDecoder()
        if let url = Self.documentDirectoryURL?.appendingPathComponent("incomeExpense"), //存檔的資料夾路徑，其路徑名incomeExpense
           let data = try? Data(contentsOf: url), // URL 轉 Data
           let dateIncomeExpenseArray = try? decoder.decode([Self].self, from: data){ //data解碼，得資料
            return dateIncomeExpenseArray
        }else{
            return nil
        }
    }
    
    //刪除 - FileManager
    static func removeDocumentDirectory() {
        if let url = Self.documentDirectoryURL?.appendingPathComponent("incomeExpense"){
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }
        }
    }
    
}

struct DateIncomeExpense:Hashable,Codable {
    var incomeExpense:[IncomeExpense]
    let date:Date?
    let year:Int?
    let month:Int?
    let day:Int?
    var beRecorded = false

    //存檔 - FileManager (可以儲存與修改檔案)
    static let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first //要存檔的資料夾路徑 陣列.first
    
    static func saveDocumentDirectory(dateIncomeExpenseArray: [Self]) { // 原為[DateIncomeExpense] 改成 [Self]更好，大寫的S，這邊Self代表這個struct物件 DateIncomeExpense
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(dateIncomeExpenseArray), //資料 編碼 成data
           let url = Self.documentDirectoryURL?.appendingPathComponent("dateIncomeExpense"){ //取一個路徑名dateIncomeExpense，原為dateIncomeExpense.documentDirectoryURL? 改成 Self.documentDirectoryURL? 更好， 大寫的S，這邊Self代表這個struct物件 DateIncomeExpense
            
            do {
                try data.write(to: url) //呼叫write，將data寫入url路徑 即 將data存到存檔的地方
                //write為 新增 或 覆蓋，沒檔案時新增，有的話覆蓋
            } catch {
                print(error) //這邊嚴謹一點可以再寫alert跳出錯誤視窗，失敗的情況通常為容量滿了
            }
        }
    }
    
    //讀檔 - FileManager (可以儲存與修改檔案)，東西有讀出來，才會佔記憶體，不會像UserDefaults.standard那樣
    static func readDocumentDirectory() -> [Self]? { //回傳的資料要加optional，不然 nil 會不兼容
        let decoder = JSONDecoder()
        if let url = Self.documentDirectoryURL?.appendingPathComponent("dateIncomeExpense"), //存檔的資料夾路徑，其路徑名dateIncomeExpense
           let data = try? Data(contentsOf: url), // URL 轉 Data
           let dateIncomeExpenseArray = try? decoder.decode([Self].self, from: data){ //data解碼，得資料
            return dateIncomeExpenseArray
        }else{
            return nil
        }
    }
    
    //刪除 - FileManager
    static func removeDocumentDirectory() {
        if let url = Self.documentDirectoryURL?.appendingPathComponent("dateIncomeExpense"){
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }
        }
    }
}


//以下是研究 UITableViewDiffableDataSource 用的
enum Section {
   case incomeExpense
}

enum OutlineItem: Hashable {
case dateInEx(DateIncomeExpense)
case inEx(IncomeExpense)
}


