//
//  IdeasDataa.swift
//  ideaTimes2
//
//  Created by Elvina Jacia on 27/04/22.
//

import CoreData

@objc(IdeasData)
public class IdeasData: NSManagedObject {

    @NSManaged public var ideasID: Int32
    @NSManaged public var ideasDesc: String?
    @NSManaged public var ideasCategory: String?
    @NSManaged public var ideasTitle: String?
    @NSManaged public var execDate: Date?
    
}
