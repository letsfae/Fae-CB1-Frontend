//
//  SetNamecardViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/17.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetInfoNamecard: UIViewController, UITableViewDelegate, UITableViewDataSource, ViewControllerNameDelegate, ViewControllerIntroDelegate {
 
    func protSaveName(txtName: String?) {
        textName = txtName
        // Vicky 09/17/17 在delegate=self之后，你的值是可以传回来了，那你这步操作是在干嘛？你需要更新的label是在table里面，不是在View里面，所以table需要重新reloadData才可以显示值，试试把这句话注释掉的结果。同样，这样地方table命名改一下吧，tblNameCard?或者其他的  以tbl开头
        uitableviewInfo.reloadData()
    }
    
    func protSaveIntro(txtIntro: String?) {
        textIntro = txtIntro
        uitableviewInfo.reloadData()
    }

    var faeNavBar: FaeNavBar!
    var uiviewNameCard: UIView!
    var uiviewInterval: UIView!
    var uitableviewInfo: UITableView!
    var arrInfo: [String] = ["Display Name", "Short Info", "Change Profile Picture", "Change Cover Photo"]
    var textName: String? = nil
    var textIntro: String? = nil
    // Vicky 09/17/71 不要在这个地方单独操作，当你进入SetDisplayName()的时候，有一个push操作，直接在那个地方delegate=self。你在这个地方，是给了SetDisplayName()一个叫做vc的引用，在viewDidLoad里给这个引用的delegate=self,但你在pushViewController里是push了另一个引用，那个引用里需要将vc.delegate=self，否则是无效的。如果还不理解，周一再问我。
//    var vc = SetDisplayName()
    
    
    override func viewDidLoad() {
//        vc.delegate = self
        view.backgroundColor = .white
        faeNavBar = FaeNavBar()
        view.addSubview(faeNavBar)
        faeNavBar.lblTitle.text = "Edit NameCard"
        faeNavBar.loadBtnConstraints()
        faeNavBar.rightBtn.setImage(nil, for: .normal)
        faeNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        uiviewNameCard = UIView(frame:CGRect(x: screenWidth/2-134, y: 114, width: 268, height: 226))
        view.addSubview(uiviewNameCard)
        
        uiviewInterval = UIView(frame: CGRect(x: 0, y: 390, width: screenWidth, height: 5))
        view.addSubview(uiviewInterval)
        uiviewInterval.backgroundColor = UIColor._241241241()
        
        uitableviewInfo = UITableView(frame: CGRect(x: 0, y: 395, width: screenWidth, height: screenHeight-395))
        view.addSubview(uitableviewInfo)
        uitableviewInfo.delegate = self
        uitableviewInfo.dataSource = self
        uitableviewInfo.register(SetAccountCell.self, forCellReuseIdentifier: "cell")
        uitableviewInfo.separatorStyle = .none
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfo.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! SetAccountCell
        cell.lblTitle.text = arrInfo[indexPath.row]
        if indexPath.row == 0 {
            cell.lblContent.text = textName
        }
        if indexPath.row == 1 {
            cell.lblContent.text = textIntro
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // Vicky 09/17/17
            let vc = SetDisplayName()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            // Vicky 09/17/17 End
            break
        case 1:
            let vc = SetShortIntro()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
