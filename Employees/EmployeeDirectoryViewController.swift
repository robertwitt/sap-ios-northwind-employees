//
//  EmployeeDirectoryViewController.swift
//  Employees
//
//  Created by Robert Witt on 08.01.19.
//  Copyright © 2019 SAP. All rights reserved.
//

import UIKit
import SAPFiori
import SAPOData

class EmployeeDirectoryViewController: UITableViewController {
    
    // MARK: Properties
    
    private var directory = [Employee]()
    
    // MARK: View Lidecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        refreshDirectory()
    }
    
    private func configureTableView() {
        tableView.register(FUIContactCell.self, forCellReuseIdentifier: FUIContactCell.reuseIdentifier)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let employee = directory[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FUIContactCell.reuseIdentifier, for: indexPath) as! FUIContactCell
        cell.headlineText = employee.fullName
        cell.subheadlineText = employee.title
        if let photo = employee.photo {
            cell.detailImage = UIImage(data: photo)
        }
        cell.detailImage = UIImage(data: employee.photo!)
        cell.accessoryType = presentedInSplitView ? .none : .disclosureIndicator
        cell.isMomentarySelection = !presentedInSplitView
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employee = directory[indexPath.row]
        let employeeDetailsStoryboard = UIStoryboard(name: "EmployeeDetails", bundle: nil)
        let employeeDetailsViewController = employeeDetailsStoryboard.instantiateViewController(withIdentifier: "EmployeeDetails") as! EmployeeDetailsViewController
        employeeDetailsViewController.employeeID = employee.employeeID
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rightNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "RightNavigationController") as! UINavigationController
        rightNavigationController.viewControllers = [employeeDetailsViewController]
        splitViewController?.showDetailViewController(rightNavigationController, sender: nil)
    }
    
    // MARK: Data Access
    
    private func refreshDirectory() {
        let loadingIndicator = FUIModalLoadingIndicatorView()
        loadingIndicator.show(inView: view, animated: true)
        var query = DataQuery().orderBy(Employee.lastName)
        query = query.select(Employee.employeeID, Employee.lastName, Employee.firstName, Employee.title, Employee.titleOfCourtesy, Employee.photo)
        dataService.fetchEmployees(matching: query) { (employees, error) in
            if let error = error {
                self.showAlert(withError: error)
            }
            self.directory = employees ?? []
            self.tableView.reloadData()
            loadingIndicator.dismiss()
        }
    }

}
