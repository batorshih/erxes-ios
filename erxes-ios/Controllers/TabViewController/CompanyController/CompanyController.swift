//
//  CompanyController.swift
//  erxes-ios
//
//  Created by alternate on 8/14/18.
//  Copyright © 2018 soyombo bat-erdene. All rights reserved.
//

import UIKit
import Apollo
import Eureka

class CompanyController: FormViewController {
    
    var companyId:String?
    var company:CompanyDetailQuery.Data.CompanyDetail? {
        didSet {
            buildForm()
        }
    }
    let client: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        let currentUser = ErxesUser.sharedUserInfo()
        configuration.httpAdditionalHeaders = ["x-token": currentUser.token as Any,
                                               "x-refresh-token": currentUser.refreshToken as Any]
        let url = URL(string: Constants.API_ENDPOINT + "/graphql")!
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    var loader: ErxesLoader = {
        let loader = ErxesLoader()
        loader.lineWidth = 3
        return loader
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Company"
        configureViews()
        queryCompanyDetail()
        queryFields()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
        }
        
        loader.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.center.equalTo(self.view.snp.center)
        }
    }
    
    convenience init(id:String) {
        self.init()
        self.companyId = id
    }
    
    @objc func editAction(sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            for row in form.allRows {
                row.baseCell.alpha = 0.7
                row.baseCell.isUserInteractionEnabled = false
                
            }
//            saveAction()
        } else {
            sender.isSelected = true
            for row in form.allRows {
                row.baseCell.alpha = 1.0
                row.baseCell.isUserInteractionEnabled = true
                
            }
            let firstRow = form.rowBy(tag: "firstName")
            firstRow?.baseCell.cellBecomeFirstResponder()
        }
    }
    
    func configureViews() {
        
        let rightItem: UIBarButtonItem = {
            var rightImage = #imageLiteral(resourceName: "ic_edit")
            var saveImage = #imageLiteral(resourceName: "ic_saveCustomer")
            rightImage = rightImage.withRenderingMode(.alwaysTemplate)
            saveImage = saveImage.withRenderingMode(.alwaysTemplate)
            let barButtomItem = UIBarButtonItem()
            let button = UIButton()
            button.setBackgroundImage(rightImage, for: .normal)
            button.setBackgroundImage(saveImage, for: .selected)
            button.tintColor = Constants.ERXES_COLOR
            button.addTarget(self, action: #selector(editAction(sender:)), for: .touchUpInside)
            barButtomItem.customView = button
            return barButtomItem
        }()
        self.navigationItem.rightBarButtonItem = rightItem
        
        NameRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.textField.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.textField.textColor = Constants.TEXT_COLOR
        }
        TextRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.textField.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.textField.textColor = Constants.TEXT_COLOR
        }
        PhoneRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.textField.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.textField.textColor = Constants.TEXT_COLOR
        }
        
        EmailRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.textField.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.textField.textColor = Constants.TEXT_COLOR
        }
        
        DateRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.detailTextLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.detailTextLabel?.textColor = Constants.ERXES_COLOR
        }
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.switchControl.tintColor = Constants.ERXES_COLOR
            cell.switchControl.onTintColor = Constants.ERXES_COLOR
        }
        IntRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.detailTextLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.detailTextLabel?.textColor = Constants.ERXES_COLOR
        }
        ActionSheetRow<String>.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.detailTextLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.detailTextLabel?.textColor = Constants.ERXES_COLOR
        }
        ButtonRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.tintColor = Constants.ERXES_COLOR
            cell.accessoryView?.tintColor = Constants.ERXES_COLOR
            
        }
        PushRow<String>.defaultCellUpdate = {cell, row in
            cell.textLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            cell.tintColor = Constants.ERXES_COLOR
            cell.accessoryView?.tintColor = Constants.ERXES_COLOR
            cell.detailTextLabel?.font = Constants.LIGHT
        }
        
        PushRow<CompanyDetail>.defaultCellUpdate = { cell, row in
            row.options = self.companies
            cell.textLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR

        }

        PushRow<UserData>.defaultCellUpdate = { cell, row in
            row.options = self.users
            cell.textLabel?.font = Constants.LIGHT
            cell.textLabel?.textColor = Constants.ERXES_COLOR
            row.displayValueFor = {
                if let t = $0 {
                    print("owner = ", t)
                    return t.details?.fullName
                }
                return nil
            }
        }
        
        SuggestionTableRow<UserData>.defaultCellUpdate = { cell, row in
            row.cell.textLabel?.font = Constants.LIGHT
            row.cell.textLabel?.textColor = Constants.ERXES_COLOR
            row.placeholder = "Type to search user"
            cell.textField.textColor = Constants.ERXES_COLOR
            cell.textField.font = Constants.LIGHT
            cell.detailTextLabel?.font = Constants.LIGHT
            cell.detailTextLabel?.textColor = Constants.TEXT_COLOR
            row.filterFunction = { [unowned self] text in
                self.users.filter({ ($0.details?.fullName?.lowercased().contains(text.lowercased()))! })
            }
        }
//
        SuggestionTableRow<CompanyDetail>.defaultCellUpdate = { cell, row in
            row.cell.textLabel?.font = Constants.LIGHT
            row.cell.textLabel?.textColor = Constants.ERXES_COLOR
            row.placeholder = "Type to search companies"
            cell.textField.textColor = Constants.ERXES_COLOR
            cell.textField.font = Constants.LIGHT
            cell.detailTextLabel?.font = Constants.LIGHT
            cell.detailTextLabel?.textColor = Constants.TEXT_COLOR
            row.filterFunction = { [unowned self] text in
                self.companies.filter({ ($0.name?.lowercased().contains(text.lowercased()))! })
            }

        }
        
        self.view.addSubview(loader)
    }
    
    func buildForm() {
        
        form +++ Section("PROFILE"){
                $0.header?.height = { 30 }
                $0.footer = HeaderFooterView(title: "")
                $0.footer?.height = { 0 }
            }
            <<< NameRow("name") { row in
                row.title = "Name:"
                row.placeholder = "-"
                if let item = company?.name {
                    row.value = item
                }
            }
        
            <<< NameRow("email") { row in
                row.title = "email:"
                row.placeholder = "-"
                if let item = company?.email {
                    row.value = item
                }
            }
        
            <<< NameRow("size") { row in
                row.title = "size:"
                row.placeholder = "-"
                if let item = company?.size {
                    row.value = "\(item)"
                }
            }
        
        //industry
            <<< PushRow<String>() {
                $0.title = "industry"
                $0.selectorTitle = "industry"
                $0.options = self.industries
                if let item = company?.industry {
                    $0.value = item
                }
            }
        
            <<< NameRow("plan") { row in
                row.title = "plan:"
                row.placeholder = "-"
                if let item = company?.plan {
                    row.value = item
                }
            }
            <<< NameRow("phone") { row in
                row.title = "phone:"
                row.placeholder = "-"
                if let item = company?.phone {
                    row.value = item
                }
            }
        
        //leadstatus
            <<< PushRow<String>() {
                $0.title = "lead status"
                $0.selectorTitle = "lead status"
                $0.options = self.leadStatus
                if let item = company?.leadStatus {
                    $0.value = item
                }
            }
            
        //lifecycle state
            <<< PushRow<String>() {
                $0.title = "lifecycle state"
                $0.selectorTitle = "lifecycle state"
                $0.options = self.lifecycleStates
                if let item = company?.lifecycleState {
                    $0.value = item
                }
            }
        //business type
            <<< PushRow<String>() {
                $0.title = "business type"
                $0.selectorTitle = "business type"
                $0.options = self.industries
                if let item = company?.businessType {
                    $0.value = item
                }
            }
        //description
        //employee count
        //do not disturb radiobox
            
            <<< SwitchRow("donotdisturb") { row in
                row.title = "Do not disturb"

            }
            
            +++ Section("Owner"){
                $0.header?.height = { 30 }
                $0.footer = HeaderFooterView(title: "")
                $0.footer?.height = { 0 }
            }
            
            //owner
            <<< SuggestionTableRow<UserData>() {
                $0.filterFunction = { [unowned self] text in
                    self.users.filter({ ($0.details?.fullName?.lowercased().contains(text.lowercased()))! })
                }
                $0.placeholder = "Search for a user"
                if let item = company?.owner?.details?.fullName {
                    let owner = UserData(id: "", details: UserData.Detail(fullName: item))
                    $0.value = owner
                }
            }
            //parent
            
            +++ Section("Parent company"){
                $0.header?.height = { 30 }
                $0.footer = HeaderFooterView(title: "")
                $0.footer?.height = { 0 }
            }
            
            <<< SuggestionTableRow<CompanyDetail>() {
                $0.filterFunction = { [unowned self] text in
                    self.companies.filter({ ($0.name?.lowercased().contains(text.lowercased()))! })
                }
                $0.placeholder = "Search for a company"
                if let item = company?.parentCompany?.name {
                    let parent = CompanyDetail(id: "", name: item)
                    $0.value = parent
                }
            }
        
            +++ Section("Links"){
                $0.footer = HeaderFooterView(title: "")
                $0.header?.height = { 30 }
                $0.footer?.height = { 0 }
            }
        
            <<< NameRow("linkedin") { row in
                row.title = "linkedin:"
                row.placeholder = "-"
                if let item = company?.links?.linkedIn {
                    row.value = item
                }
        }
        
            <<< NameRow("twitter") { row in
                row.title = "twitter:"
                row.placeholder = "-"
                if let item = company?.links?.twitter {
                    row.value = item
                }
        }
        
            <<< NameRow("facebook") { row in
                row.title = "facebook:"
                row.placeholder = "-"
                if let item = company?.links?.facebook {
                    row.value = item
                }
        }
        
            <<< NameRow("github") { row in
                row.title = "github:"
                row.placeholder = "-"
                if let item = company?.links?.github {
                    row.value = item
                }
        }
        
            <<< NameRow("youtube") { row in
                row.title = "youtube:"
                row.placeholder = "-"
                if let item = company?.links?.youtube {
                    row.value = item
                }
        }
        
            <<< NameRow("website") { row in
                row.title = "website:"
                row.placeholder = "-"
                if let item = company?.links?.website {
                    row.value = item
                }
        }
        
        self.getCompanies()
        self.getUsers()
        for row in form.allRows {
            row.baseCell.alpha = 0.7
            row.baseCell.isUserInteractionEnabled = false
        }
    }
    
    func queryCompanyDetail() {
        guard let comId = self.companyId else {
            return
        }
        
        let query = CompanyDetailQuery(id: comId)
        
        client.fetch(query: query) { [weak self] result,error in
            if let error = error {
                print(error.localizedDescription)
                let alert = FailureAlert(message: error.localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
                return
            }
            
            if let err = result?.errors {
                let alert = FailureAlert(message: err[0].localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
            }
            
            if result?.data != nil {
                self?.company = result?.data?.companyDetail
            }
        }
    }
    
    func queryFields() {
        let query = FieldsGroupsQuery(contentType: "company")
        
        client.fetch(query: query) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
                let alert = FailureAlert(message: error.localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
                return
            }
            
            if let err = result?.errors {
                let alert = FailureAlert(message: err[0].localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
            }
            
            if result?.data != nil {
                print(result)
            }
        }
    }
    
    var industries = [String]()
    var leadStatus = [String]()
    var lifecycleStates = [String]()
    var businessTypes = [String]()
    
    func loadData() {
        if let path = Bundle.main.path(forResource: "Industry", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String] {
                    industries = jsonResult
                }
            } catch {
                // handle error
                print(error)
            }
        }
        
        if let path = Bundle.main.path(forResource: "LeadStatus", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String] {
                    leadStatus = jsonResult
                }
            } catch {
                // handle error
                print(error)
            }
        }
        
        if let path = Bundle.main.path(forResource: "LifecycleState", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String] {
                    lifecycleStates = jsonResult
                }
            } catch {
                // handle error
                print(error)
            }
        }
        
        if let path = Bundle.main.path(forResource: "BusinessType", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String] {
                    businessTypes = jsonResult
                }
            } catch {
                // handle error
                print(error)
            }
        }
    }
    
    var companies = [CompanyDetail]()
    var users = [UserData]()
    
    func getCompanies() {
        loader.startAnimating()
        
        let query = CompaniesQuery()
        client.fetch(query: query, cachePolicy: CachePolicy.returnCacheDataAndFetch) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
                let alert = FailureAlert(message: error.localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
                return
            }
            
            if let err = result?.errors {
                let alert = FailureAlert(message: err[0].localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
            }
            
            if result?.data != nil {
                if let allCompanies = result?.data?.companies {
                    
                    self?.companies = allCompanies.map { ($0?.fragments.companyDetail)! }
                    
                    self?.loader.stopAnimating()
                    
                    
                }
            }
        }
        
    }
    
    func getUsers() {
        loader.startAnimating()
        let query = GetUsersQuery()
        client.fetch(query: query, cachePolicy: CachePolicy.returnCacheDataAndFetch) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
                let alert = FailureAlert(message: error.localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
                return
            }
            
            if let err = result?.errors {
                let alert = FailureAlert(message: err[0].localizedDescription)
                alert.show(animated: true)
                self?.loader.stopAnimating()
            }
            
            if result?.data != nil {
                if let result = result?.data?.users {
                    self?.users = result.map { ($0?.fragments.userData)! }
                    self?.loader.stopAnimating()
                }
            }
        }
        
    }

}

extension UserData: SuggestionValue {
    public init?(string stringValue: String) {
        return nil
    }
    
    // Text that is displayed as a completion suggestion.
    public var suggestionString: String {
        return (details?.fullName)!
    }
}
