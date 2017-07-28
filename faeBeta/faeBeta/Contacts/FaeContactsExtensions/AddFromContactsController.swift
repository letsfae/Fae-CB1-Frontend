//
//  AddFromContactsController.swift
//  FaeContacts
//
//  Created by Justin He on 6/22/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class AddFromContactsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var uiviewNavBar: FaeNavBar!
    var uiviewSchbar: UIView!
    var schbarUsernames: FaeSearchBar!
    var tblUsernames: UITableView!
    var filtered: [String] = [] // for search bar results
    var testArray = ["Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia (Hrvatska)", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea"]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSearchTable()
        loadNavBar()
        tblUsernames.separatorStyle = .none
        definesPresentationContext = true
        view.backgroundColor = .white
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "Add From Contacts"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadSearchTable() {
        let uiviewSchbar = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 50))
        schbarUsernames = FaeSearchBar(frame: CGRect(x: 9, y: 1, width: screenWidth, height: 49), font: UIFont(name: "AvenirNext-Medium", size: 18)!, textColor: UIColor._898989())
        schbarUsernames.barTintColor = .white
        schbarUsernames.tintColor = UIColor._898989()
        schbarUsernames.placeholder = "Search Contacts                                                  "
        schbarUsernames.delegate = self
        uiviewSchbar.addSubview(schbarUsernames)
        
        let schBarTopLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        schBarTopLine.layer.borderWidth = 1
        schBarTopLine.layer.borderColor = UIColor.white.cgColor
        schbarUsernames.addSubview(schBarTopLine)
        
        let imgBarIconSubview = UIView(frame: CGRect(x: 0, y: 0, width: 41, height: 50))
        imgBarIconSubview.backgroundColor = .white
        uiviewSchbar.addSubview(imgBarIconSubview)
        
        let imgBarIcon = UIImageView(frame: CGRect(x: 15, y: 17, width: 15, height: 15))
        imgBarIcon.image = #imageLiteral(resourceName: "searchBarIcon")
        uiviewSchbar.addSubview(imgBarIcon)
        
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        topLine.layer.borderWidth = 1
        topLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(topLine)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 49, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = 1
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(bottomLine)
        
        view.addSubview(uiviewSchbar)
        
        /* Joshua 06/16/17
         y should be 114 not 113
         tblUsernames' height should be screenHeight - 65 - height of schbar
         */
        tblUsernames = UITableView()
        tblUsernames.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 65 - 50)
        tblUsernames.dataSource = self
        tblUsernames.delegate = self
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        tblUsernames.addGestureRecognizer(tapToDismissKeyboard)
        tblUsernames.register(FaeAddUsernameCell.self, forCellReuseIdentifier: "myCell")
        tblUsernames.register(FaeInviteCell.self, forCellReuseIdentifier: "myInviteCell")
        tblUsernames.isHidden = false
        tblUsernames.indicatorStyle = .white
        view.addSubview(tblUsernames)
    }
    // UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter(searchText: searchText)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        schbarUsernames.becomeFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        schbarUsernames.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        schbarUsernames.resignFirstResponder()
    }
    // End of UISearchBarDelegate
    
    func filter(searchText: String, scope: String = "All") {
        filtered = testArray.filter { text in
            (text.lowercased()).range(of: searchText.lowercased()) != nil
        }
        tblUsernames.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if schbarUsernames.text != "" {
            return filtered.count
        }
        else {
            //return testArray.count
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = FaeAddUsernameCell(style: UITableViewCellStyle.default, reuseIdentifier: "myCell", isFriend: false)
            if schbarUsernames.text != "" {
                cell.lblUserName.text = filtered[indexPath.row]
                cell.lblUserSaying.text = filtered[indexPath.row]
                cell.isFriend = true // enabled manual togging for testing; for real, we implement API calls.
            } else {
                cell.lblUserName.text = testArray[indexPath.row]
            }
            if indexPath.row == tblUsernames.numberOfRows(inSection: 0)-1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        }
        else {
            let cell = FaeInviteCell(style: UITableViewCellStyle.default, reuseIdentifier: "myInviteCell")
            cell.lblName.text = "Wenjia Liu"
            cell.lblTel.text = "2132969405"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected table row \(indexPath.row) and item \(testArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        if schbarUsernames.text != "" && filtered.count == 0 {
            return headerView
        }
        headerView.backgroundColor = UIColor._248248248()
        if section != 0 {
            let borderTop = UIView()
            borderTop.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 1)
            borderTop.layer.borderWidth = 1
            borderTop.layer.borderColor = UIColor._200199204cg()
            headerView.addSubview(borderTop)
        }
        let borderBottom = UIView()
        borderBottom.frame = CGRect(x: 0, y: 25, width: tableView.bounds.size.width, height: 1)
        borderBottom.layer.borderWidth = 1
        borderBottom.layer.borderColor = UIColor._200199204cg()
        headerView.addSubview(borderBottom)
        
        let label = UILabel()
        label.textColor = UIColor._155155155()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        headerView.addSubview(label)
        if section == 0 {
            label.text = "Already on Fae"
        }
        else {
            label.text = "Invite to Fae"
        }
        headerView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: label)
        headerView.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: label)
        return headerView
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        schbarUsernames.resignFirstResponder()
    }

}
