//
//  IncomeExpenseDate+CoreDataProperties.swift
//  DemoXIII
//
//  Created by homejay on 2021/4/14.
//
//

import Foundation
import CoreData


extension IncomeExpenseDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IncomeExpenseDate> {
        return NSFetchRequest<IncomeExpenseDate>(entityName: "IncomeExpenseDate")
    }

    @NSManaged public var beRecorded: Bool
    @NSManaged public var day: Int64
    @NSManaged public var imageName: String?
    @NSManaged public var imageSelectedName: String?
    @NSManaged public var money: Int64
    @NSManaged public var month: Int64
    @NSManaged public var title: String?
    @NSManaged public var year: Int64
    @NSManaged public var dateString: String?
    @NSManaged public var date: Date?
}

extension IncomeExpenseDate : Identifiable {

}
