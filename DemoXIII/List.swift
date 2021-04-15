//
//  List.swift
//  DemoX
//
//  Created by homejay on 2021/2/18.
//

import Foundation
import UIKit

struct List:Codable {
    var imageName:String?
    var imageSelectedName:String?
    var title:String?
    var totalMoney = 0
    var percent:CGFloat = 0
    var isTap = false
    
    //預設的 收支item
    static func returnIncomeImageNameArray() -> [String] {
        let incomeImageNameArray = ["bars",
                                    "bookmark",
                                    "coin",
                                    "confetti",
                                    "crediCard",
                                    "dollar",
                                    "gift",
                                    "idea",
                                    "justice",
                                    "medal",
                                    "moneyBag",
                                    "pay",
                                    "piggyBank",
                                    "profit",
                                    "wallet",
                                    "house",
                                    "other"]
        
        return incomeImageNameArray
    }
    static func returnIncomeTitleArray() -> [String] {
        let incomeLabelTitleArray = ["投資",
                                     "授課",
                                     "外幣",
                                     "禮金",
                                     "卡利",
                                     "獎金",
                                     "禮物",
                                     "創意",
                                     "談判",
                                     "勳章",
                                     "回饋",
                                     "交易",
                                     "儲蓄",
                                     "增值",
                                     "薪水",
                                     "租金",
                                     "其他"]
        return incomeLabelTitleArray
    }
    
    static func returnExpenseImageNameArray() -> [String] {
        let expenseImageNameArray = ["egg",
                                     "lunch",
                                     "rice",
                                     "hospital",
                                     "appliances",
                                     "baby",
                                     "beer",
                                     "bus",
                                     "car",
                                     "cocktail",
                                     "food",
                                     "game",
                                     "hotel",
                                     "house",
                                     "iceCream",
                                     "menClothes",
                                     "womenClothes",
                                     "other"]
        return expenseImageNameArray
    }
    static func returnExpenseTitleArray() -> [String] {
        let expenseLabelTitleArray = ["早餐",
                                      "午餐",
                                      "晚餐",
                                      "醫療",
                                      "家電",
                                      "育兒",
                                      "社交",
                                      "交通",
                                      "運費",
                                      "飲料",
                                      "伙食",
                                      "娛樂",
                                      "住宿",
                                      "房租",
                                      "點心",
                                      "男服",
                                      "女服",
                                      "其他"]
        return expenseLabelTitleArray
    }
    
    static func returnAllImageNameArray() -> [String] {
        let allItemImageName = ["bars",
                                "bookmark",
                                "coin",
                                "confetti",
                                "crediCard",
                                "dollar",
                                "gift",
                                "idea",
                                "justice",
                                "medal",
                                "moneyBag",
                                "pay",
                                "piggyBank",
                                "profit",
                                "wallet",
                                "egg",
                                "lunch",
                                "rice",
                                "hospital",
                                "appliances",
                                "baby",
                                "beer",
                                "bus",
                                "car",
                                "cocktail",
                                "food",
                                "game",
                                "hotel",
                                "house",
                                "iceCream",
                                "menClothes",
                                "womenClothes",
                                "other",
                                "security",
                                "scale"]
        return allItemImageName
    }
    
    //建立基本 收入 或 支出 選項清單內容
    static func makeListItem (imageNameArray:[String],labelTitleArray:[String]) -> [List] {
        
        var listArray = [List]()
        
        for i in 0...imageNameArray.count - 1 {
            
            let list = List(imageName: imageNameArray[i],
                            imageSelectedName: imageNameArray[i]+"-1",
                            title: labelTitleArray[i])
            
            listArray.append(list)
        }
        return listArray
    }
    
    //存檔 - FileManager (可以儲存與修改檔案)
    static let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first //要存檔的資料夾路徑 陣列.first
    
    static func saveDocumentDirectory(listArray: [Self]) { // 原為[List] 改成 [Self]更好，大寫的S，這邊Self代表這個struct物件 List
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(listArray), //資料 編碼 成data
           let url = Self.documentDirectoryURL?.appendingPathComponent("incomeList"){ //取一個路徑名list，原為list.documentDirectoryURL? 改成 Self.documentDirectoryURL? 更好， 大寫的S，這邊Self代表這個struct物件 List
            
            do {
                try data.write(to: url) //呼叫write，將data寫入url路徑 即 將data存到存檔的地方
                //write為 新增 或 覆蓋，沒檔案時新增，有的話覆蓋
            } catch {
                print(error) //這邊嚴謹一點可以再寫alert跳出錯誤視窗，失敗的情況通常為容量滿了
            }
            
        }
        
    }
    
    static func saveDocumentDirectoryEx(listArray: [Self]) { // 原為[List] 改成 [Self]更好，大寫的S，這邊Self代表這個struct物件 List
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(listArray), //資料 編碼 成data
           let url = Self.documentDirectoryURL?.appendingPathComponent("expenseList"){ //取一個路徑名list，原為list.documentDirectoryURL? 改成 Self.documentDirectoryURL? 更好， 大寫的S，這邊Self代表這個struct物件 List
            
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
        if let url = Self.documentDirectoryURL?.appendingPathComponent("incomeList"), //存檔的資料夾路徑，其路徑名list
           let data = try? Data(contentsOf: url), // URL 轉 Data
           let dateIncomeExpenseArray = try? decoder.decode([Self].self, from: data){ //data解碼，得資料
            return dateIncomeExpenseArray
        }else{
            return nil
        }
    }
    
    static func readDocumentDirectoryEx() -> [Self]? { //回傳的資料要加optional，不然 nil 會不兼容
        let decoder = JSONDecoder()
        if let url = Self.documentDirectoryURL?.appendingPathComponent("expenseList"), //存檔的資料夾路徑，其路徑名list
           let data = try? Data(contentsOf: url), // URL 轉 Data
           let dateIncomeExpenseArray = try? decoder.decode([Self].self, from: data){ //data解碼，得資料
            return dateIncomeExpenseArray
        }else{
            return nil
        }
    }
    
    //刪除 - FileManager
    static func removeDocumentDirectory() {
        if let url = Self.documentDirectoryURL?.appendingPathComponent("list"){
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }
        }
    }
    
    
}


