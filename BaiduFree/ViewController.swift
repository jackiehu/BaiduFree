//
//  ViewController.swift
//  BaiduFree
//
//  Created by iOS on 2021/12/6.
//

import UIKit
import Kanna
import SwiftBrick
import ListDataSource
import SwiftEmptyData
import SwiftShow
import EFQRCode
enum Section {
    case main
}

struct Item: Hashable {
    let url: String
    let title: String
}

class ViewController: JHTableViewController {
    
    lazy var dataSource = TableViewDataSource<Section, Item>.init(tableView!, needDelegate: true) { tableView, indexPath, model in
        let cell = tableView.dequeueReusableCell(JHTableViewCell.self)
        cell.textLabel?.text = model.title
        return cell
    }
    
    var shot = DataSourceSnapshot<Section,Item>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.em.emptyView = EmptyView.empty(deploy: { (config) in
            config.title = "暂无数据"
        })
        Show.showLoading("正在挖掘...")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for index in 1998...2150 {
            let string = "https://pan.baidu.com/component/view/" + "\(index)"
            let result = self.fetchHtml(string: string)
            if let item = result{
                shot.appendItems([item],toSection: .main)
            }
        }

        dataSource.apply(shot)
        Show.hiddenLoading()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        shot.appendSections([.main])
        tableViewConfig()
    }
    
    
    func tableViewConfig(){
        dataSource.didSelectRow { tableView, index, model in
            if let image = EFQRCode.generate(for: model.url, size: EFIntSize.init(width: 200, height: 200)) {
                let content = UIImageView.init(frame: CGRect.init(x: 300, y: 100, width: 200, height: 200))
                content.image = UIImage(cgImage: image)
                Show.showPopView(contentView: content)
            }
        }.setHeightForRow { tableView, indexpath, item in
            return 70
        }
    }
    
    func fetchHtml(string: String) -> Item? {
        guard let url = URL(string: string) else {
            return nil
        }
        let html = try? HTML(url: url, encoding: .utf8)
        
        if let title = html?.title, title.hasPrefix("百度网盘 | ") == true{
            print("可用 : \(title)")
            return Item(url: string, title: title)
        }
        return nil
    }

}
