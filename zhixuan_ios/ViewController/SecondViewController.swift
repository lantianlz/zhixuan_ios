//
//  SecondViewController.swift
//  zhixuan_ios
//
//  Created by simplejoy on 14-9-24.
//  Copyright (c) 2014年 simplejoy. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpRequestProtocol {

    @IBOutlet weak var departmentTableView: UITableView!
    @IBOutlet weak var departmentNavItem: UINavigationItem!
    
    var httpRequest = HttpRequest()
    var departmentObjs = NSMutableArray()
    var departmentAddObjs = NSArray()
    var departmentCount = 0
    var pageCount = 1
    let pageMaxCount = 10
    var pullView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("start2")
        self.httpRequest.delegate = self
        self.httpRequest.getResultsWithJson("\(MAINDOMAIN)/kaihu/api_get_department_list?page=\(self.pageCount)")
        
        //注册动画
        setupRefresh()
    }
    
    
    func setupRefresh(){
        self.departmentTableView.addFooterWithCallback({
            self.httpRequest.getResultsWithJson("\(MAINDOMAIN)/kaihu/api_get_department_list?page=\(self.pageCount)")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.departmentObjs.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let rowData:NSDictionary = self.departmentObjs[indexPath.row] as NSDictionary
        
        let cell = tableView.dequeueReusableCellWithIdentifier("department") as DepartmentCell
        
        cell.nameLabel?.text = rowData["short_name"] as? String
        let tel = rowData["tel"] as String
        cell.telLabel?.text = "电话: \(tel)"
        let cmCount = String(rowData["cm_count"] as Int)
        if(cmCount == "0"){
            cell.cmCountLabel.hidden = true
        }
        else{
            cell.cmCountLabel.text = cmCount
            cell.cmCountLabel.hidden = false
        }
        
        let img = httpRequest.getImage(rowData["img"] as String)
        cell.departmentImageView?.image = img
        cell.departmentObj = rowData
        
        departmentNavItem.title = "营业部(共\(self.departmentCount)家)"
        return cell
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    func didRecieveResults(results:NSDictionary){
        departmentAddObjs = results["departments"] as NSArray
        self.departmentCount = results["department_count"] as Int

        if(self.pageCount == 1)
        {
            self.departmentObjs = departmentAddObjs as NSMutableArray
            self.departmentTableView.reloadData()
        }
        else if(departmentAddObjs.count > 0) {
            let originCount = departmentObjs.count
            let newCount = departmentAddObjs.count - 1
            for i in 0...newCount {
                self.departmentObjs.insertObject(self.departmentAddObjs[i], atIndex: self.departmentObjs.count)
            }
            
            var indexPaths:Array = []
            for i in 0...newCount {
                indexPaths.append(NSIndexPath(forRow: originCount + i, inSection: 0))
            }
            self.departmentTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
        }
        
        self.departmentTableView.footerEndRefreshing()
        // 最后一页隐藏
        if(departmentAddObjs.count < self.pageMaxCount){
            self.departmentTableView.setFooterHidden(true)
        }
        self.pageCount += 1
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //跳转到营业部详情页面
        let ddc = segue.destinationViewController as DepartmentDetailController
        ddc.departmentObj = sender!.departmentObj
        ddc.img = sender!.departmentImageView!.image
    }
}



