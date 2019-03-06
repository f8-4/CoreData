//
//  CartoonUtils.swift
//  CoredataPractice
//
//  Created by 董 on 2019/3/4.
//  Copyright © 2019 董. All rights reserved.
//

import UIKit
import CoreData

class CoredataUtils: NSObject {
    
    let entity_Cartoon = "Cartoon"
    let entity_Character = "Character"
    
    var app : AppDelegate?
    var context : NSManagedObjectContext?
    
    override init(){
        super.init()
        app = UIApplication.shared.delegate as? AppDelegate
        context = app!.persistentContainer.viewContext
    }
    
    /// 查询Cartoon
    ///
    /// - Parameter name: 名称
    /// - Returns: 结果数组
    func queryCartoon(name : String? = nil) -> [Cartoon]{
        //声明数据的请求
        let fetchRequest = NSFetchRequest<Cartoon>(entityName: entity_Cartoon)
        if name != nil {
            //设置查询条件
            let predicate = NSPredicate(format: "name==%@", name!)
            fetchRequest.predicate = predicate
        }
        fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //查询操作
        do {
            let fetchedObjects = try context!.fetch(fetchRequest)
            print(String.init(format:"%@.count = %i", entity_Cartoon, fetchedObjects.count))
            return fetchedObjects
        }
        catch {
            fatalError("查询异常“：\(error)")
        }
        
        return []
    }
    
    /// 分页查询
    ///
    /// - Parameters:
    ///   - pageSize: 每一页条数
    ///   - currentPage: 当前页
    /// - Returns: 查询结果，两个参数同时为空，查询全部数据
    func queryCharacter(pageSize : Int? = nil, currentPage : Int? = nil) ->[Character] {
        //声明数据的请求
        let fetchRequest = NSFetchRequest<Character>(entityName : entity_Character)
        if pageSize != nil && currentPage != nil {
            fetchRequest.fetchLimit = pageSize! //限定查询结果的数量
            fetchRequest.fetchOffset = (currentPage! - 1) * pageSize!
        } else {
             fetchRequest.fetchOffset = 0 //查询的偏移量
        }
        //查询操作
        do {
            let fetchedObjects = try context!.fetch(fetchRequest)
            print(String.init(format:"%@.count = %i", entity_Character, fetchedObjects.count))
            return fetchedObjects
        }
        catch {
            fatalError("查询异常“：\(error)")
        }
        
        return []
    }
    
    /// 设置查询条件
    ///
    /// - Parameter predicate: 查询条件
    /// - Returns: 查询结果
    func queryCharacter(predicate : NSPredicate) ->[Character] {
        //声明数据的请求
        let fetchRequest = NSFetchRequest<Character>(entityName : entity_Character)
        fetchRequest.fetchOffset = 0 //查询的偏移量
        fetchRequest.predicate = predicate
        
        //查询操作
        do {
            let fetchedObjects = try context!.fetch(fetchRequest)
            print(String.init(format:"%@.count = %i", entity_Character, fetchedObjects.count))
            return fetchedObjects
        }
        catch {
            fatalError("查询异常“：\(error)")
        }
        
        return []
    }
    
    /// 对查询结果排序
    ///
    /// - Parameter sort: 排序规则
    /// - Returns: 查询结果
    func queryCharacter(sort : [NSSortDescriptor]) ->[Character] {
        //声明数据的请求
        let fetchRequest = NSFetchRequest<Character>(entityName : entity_Character)
        fetchRequest.fetchOffset = 0 //查询的偏移量
        fetchRequest.sortDescriptors = sort
        //查询操作
        do {
            let fetchedObjects = try context!.fetch(fetchRequest)
            print(String.init(format:"%@.count = %i", entity_Character, fetchedObjects.count))
            return fetchedObjects
        }
        catch {
            fatalError("查询异常“：\(error)")
        }
        
        return []
    }
    
    /// 重置数据
    func resetData(){
        //先删除表中所有数据
        deleteObjects()
        //解析plist文件数据
        let plistPath : String = Bundle.main.path(forResource: "datalist.plist", ofType:nil)!
        let plistArray : NSArray = NSArray(contentsOfFile: plistPath)!
        for item in plistArray {
            let itemDict: [String: Any] = item as! [String : Any]
            let name : String = itemDict["name"] as! String
            let age : Int16 = itemDict["age"] as! Int16
            let isProtagonist : Bool = itemDict["isProtagonist"] as! Bool
            let remark : String? = itemDict["remark"] as? String
            let cartoon : String = itemDict["cartoon"] as! String
            var cartoonItem : Cartoon!
            //插入Cartoon表之前需要先查询下是否已经存在，存在不需要再插入
            var carArray = queryCartoon(name: cartoon)
            if carArray.isEmpty {
                cartoonItem = saveCartoon(name: cartoon)
            } else {
                cartoonItem = carArray[0]
            }
            //Cartoon对象获取到之后可以插入Character表
            let character = saveCharacter(name: name,
                                          age: age,
                                          isProtagonist: isProtagonist,
                                          cartoon_name: cartoonItem,
                                          remark: remark)
            //Character表插入完成之后，需要给Cartoon设置关联关系。
            cartoonItem.addToRoles(character)
        }
    }
    
    /// Character插入数据
    ///
    /// - Parameters:
    ///   - name: 角色名称
    ///   - age: 年龄
    ///   - isProtagonist: 是否主角
    ///   - cartoon_name: 动画片对象
    ///   - remark: 备注
    /// - Returns: Character对象
    func saveCharacter(name: String,
                       age: Int16,
                       isProtagonist: Bool,
                       cartoon_name: Cartoon,
                       remark: String? = nil) -> Character {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "Character",
                                                      into: context!) as! Character
        obj.name = name
        obj.age = age
        obj.isProtagonist = isProtagonist
        obj.cartoon_name = cartoon_name
        obj.remark = remark ?? ""
        
        app?.saveContext()
        return obj
    }
    
    /// Cartoon插入记录
    ///
    /// - Parameter name: 动画片名称
    /// - Returns: Cartoon对象
    func saveCartoon(name : String) -> Cartoon {
        //创建对象
        let obj = NSEntityDescription.insertNewObject(forEntityName: "Cartoon", into: context!) as! Cartoon
        //对象赋值
        obj.name = name
        
        //保存
        app?.saveContext()
        
        return obj
    }
    
    /// 删除
    func deleteObjects() {
        let array = queryCartoon()
        for item in array {
            context?.delete(item)
        }
        app?.saveContext()
    }
    
    func deleteCharacter(name: String) -> Bool {
        let predicate = NSPredicate(format: "name == %@", name)
        let itemArr = queryCharacter(predicate: predicate)
        if itemArr.isEmpty {
            return false
        }
        for item in itemArr {
            context?.delete(item)
        }
        app?.saveContext()
        return true
    }
    
    /// 更新Character表数据
    ///
    /// - Parameters:
    ///   - name: 姓名，主键
    ///   - age: 年龄，修改项
    /// - Returns: 更新结果
    func updateCharacter(name: String, age: Int16) -> Bool {
        let predicate = NSPredicate(format: "name == %@", name)
        let itemArr = queryCharacter(predicate: predicate)
        if itemArr.isEmpty {
            return false
        }
        let item = itemArr[0]
        item.age = age
        app?.saveContext()
        return true
    }
}
