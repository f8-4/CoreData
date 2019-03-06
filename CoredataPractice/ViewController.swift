//
//  ViewController.swift
//  CoredataPractice
//
//  Created by 董 on 2019/3/1.
//  Copyright © 2019 董. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let pageSize = 5
    let TAG_Sort_Ascend = 1
    let TAG_Sort_Descend = 2
    
    @IBOutlet weak var findAllBtn: UIButton!
    @IBOutlet weak var deleteAllBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var pageFindBtn: UIButton!
    @IBOutlet weak var nextPageBtn: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var catogaryFindBtn: UIButton!
    @IBOutlet weak var manyFindBtn: UIButton!
    @IBOutlet weak var likeFindBtn: UIButton!
    @IBOutlet weak var conditionFindBtn: UIButton!
    @IBOutlet weak var matchFindBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameSortLabel: UIButton!
    @IBOutlet weak var ageSortLabel: UIButton!
    
    var lastSelectedBtn : UIButton?
    var cartoonList : [Cartoon]?
    var characterList : [Character] = []
    var currentPage: Int = 1
    var totalPage : Int?
    
    lazy var coredataUtils : CoredataUtils = {
        return CoredataUtils.init()
    }()
    
    @IBAction func btnClick(_ sender: UIButton) {
        setButtonSelected(sender)
        if sender == resetBtn {
            //重置数据
            coredataUtils.resetData()
            characterList = coredataUtils.queryCharacter()
            self.reloadData()
        } else if sender == findAllBtn {
            //查询全部
            cartoonList = coredataUtils.queryCartoon()
            characterList = coredataUtils.queryCharacter()
            self.reloadData()
        } else if sender == deleteAllBtn {
            //删除所有
            coredataUtils.deleteObjects()
            characterList = coredataUtils.queryCharacter()
            self.reloadData()
        } else if sender == pageFindBtn {
            //分页查询
            currentPage = 1
            characterList = coredataUtils.queryCharacter(pageSize: pageSize, currentPage : currentPage)
            if characterList.count >= pageSize {
                self.nextPageBtn.isEnabled = true
            } else {
                self.nextPageBtn.isEnabled = false
            }
            self.reloadData()
        } else if sender == nextPageBtn {
            //下一页
            currentPage = currentPage + 1
            characterList = coredataUtils.queryCharacter(pageSize: pageSize, currentPage : currentPage)
            if characterList.count >= pageSize {
                self.nextPageBtn.isEnabled = true
            } else {
                self.nextPageBtn.isEnabled = false
            }
            self.reloadData()
        } else if sender == catogaryFindBtn {
            //类别查询，类别一
            if cartoonList != nil && (cartoonList?.count)! > 0 {
                let catogary = cartoonList![0]
                if let array = catogary.roles {
                    characterList = Array(array) as! [Character]
                    self.reloadData()
                }
            }
        } else if sender == manyFindBtn {
            //批量查询
            let predicate = NSPredicate(format: "name IN %@", ["佩奇", "乐迪"])
            characterList = coredataUtils.queryCharacter(predicate: predicate)
            self.reloadData()
        } else if sender == likeFindBtn {
            //模糊查询
            //查询角色名称包含“小“或“猪”的记录，*号表示通配符
            //let predicate = NSPredicate(format: "name CONTAINS %@ OR name like %@", "小", "*猪*")
            //查询角色名称以猪开头的记录
            //let predicate = NSPredicate(format: "name BEGINSWITH %@", "猪")
            //查询角色名称以”迪“结尾的记录
            let predicate = NSPredicate(format: "name ENDSWITH %@", "迪")
            characterList = coredataUtils.queryCharacter(predicate: predicate)
            self.reloadData()
        } else if sender == conditionFindBtn {
            //条件查询
            //查询年龄大于18的记录
            //let predicate = NSPredicate(format: "age > %@", NSNumber(value: 18))
            //查询年龄介于5-30之间的
            let predicate = NSPredicate(format: "age BETWEEN {%@, %@}", NSNumber(value: 5), NSNumber(value: 30))
            characterList = coredataUtils.queryCharacter(predicate: predicate)
            self.reloadData()
        } else if sender == matchFindBtn {
            //精确查询
            //查询年龄等于4的记录
            let predicate = NSPredicate(format: "age == %@", NSNumber(value: 4))
            characterList = coredataUtils.queryCharacter(predicate: predicate)
            self.reloadData()
        } else if sender == nameSortLabel {
            //姓名排序
            var nameSort : NSSortDescriptor!
            
            if sender.tag == TAG_Sort_Descend {
                sender.tag = TAG_Sort_Ascend
                sender.setTitle("姓名升序", for: .normal)
                nameSort = NSSortDescriptor.init(key: "name", ascending: false)
            } else {
                sender.tag = TAG_Sort_Descend
                sender.setTitle("姓名降序", for: .normal)
                nameSort = NSSortDescriptor.init(key: "name", ascending: true)
            }
            characterList = coredataUtils.queryCharacter(sort: [nameSort])
            self.reloadData()
        } else if sender == ageSortLabel {
            //年龄排序
            var ageSort : NSSortDescriptor!
            
            if sender.tag == TAG_Sort_Descend {
                sender.tag = TAG_Sort_Ascend
                sender.setTitle("年龄升序", for: .normal)
                ageSort = NSSortDescriptor.init(key: "age", ascending: false)
                
            } else {
                sender.tag = TAG_Sort_Descend
                sender.setTitle("年龄降序", for: .normal)
                ageSort = NSSortDescriptor.init(key: "age", ascending: true)
            }
            characterList = coredataUtils.queryCharacter(sort: [ageSort])
            self.reloadData()
        }
    }
    
    func reloadData(){
        self.tableView.reloadData()
        self.resultLabel.text = String.init(format: "共查询到%i条数据", characterList.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        btnClick(findAllBtn)
        self.nextPageBtn.isEnabled = false
    }
    
    func initTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CharacterCell", bundle: nil), forCellReuseIdentifier: "CharacterCell")
        tableView.estimatedRowHeight = 100
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0
            , y: 0
            , width: self.view.bounds.width, height: 0.001))
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let data : Character = characterList[(indexPath as NSIndexPath ).row]
            if self.coredataUtils.deleteCharacter(name: data.name!) {
                characterList.remove(at: (indexPath as NSIndexPath ).row)
                self.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemData = characterList[(indexPath as NSIndexPath).row]
        let cell : CharacterCell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell") as! CharacterCell
        cell.delegate = self
        cell.data = itemData
        return cell
    }
    
    
    func setButtonSelected(_ selectedBtn: UIButton){
        if lastSelectedBtn != nil {
            lastSelectedBtn?.isSelected = false
        }
        lastSelectedBtn = selectedBtn
        selectedBtn.isSelected = true
        
    }

    func updateCellData(name: String, age: Int16){
        if self.coredataUtils.updateCharacter(name: name, age: age) {
            //只刷新当前页面上的数据，升序降序什么的就不管了
            var resultArray : [String] = []
            for item in characterList {
                resultArray.append(item.name!)
            }
            let predicate = NSPredicate(format: "name IN %@", resultArray)
            characterList = coredataUtils.queryCharacter(predicate: predicate)
            self.reloadData()
        }
    }
    
}

