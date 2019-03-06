//
//  CharacterCell.swift
//  CoredataPractice
//
//  Created by 董 on 2019/3/4.
//  Copyright © 2019 董. All rights reserved.
//

import UIKit

class CharacterCell: UITableViewCell, UITextFieldDelegate {

    var delegate : ViewController?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cartoonLabel: UILabel!
    
    var data : Character! {
        didSet {
            nameLabel.text = data.name
            ageField.text = String.init(describing: data.age)
            cartoonLabel.text = data.cartoon_name?.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ageField.returnKeyType = UIReturnKeyType.done
        ageField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let content : String = textField.text!
        if content.count > 0 && isNumberOnly(content){
            let newAge : Int16 = Int16(content)!
            if newAge != data.age {
                if delegate != nil {
                    delegate!.updateCellData(name: data.name!, age: newAge)
                }
            }
        } else {
            print("输入内容为空或不为纯数字")
        }
        textField.resignFirstResponder()
        return true
    }
    
    func isNumberOnly(_ text: String) -> Bool {
        let scan: Scanner = Scanner(string: text)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
    }
    
}
