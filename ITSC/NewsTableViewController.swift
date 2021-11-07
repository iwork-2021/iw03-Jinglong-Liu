//
//  NewsTableViewController.swift
//  ITSC
//
//  Created by mac on 2021/11/6.
//

import UIKit

class NewsTableViewController: UITableViewController {
    @IBOutlet weak var pageController: UIPageControl!
    var newsList:Array<Array<News>>=[]
    var currentPage:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeb()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    func loadWeb() {
        let loadingPage=self.currentPage
        while self.newsList.count < loadingPage+1{
            self.newsList.append([])
        }
        if self.newsList[loadingPage].count>0{
            self.tableView.reloadData()
            return
        }
        let url = URL(string: "https://itsc.nju.edu.cn/xwdt/list\(self.currentPage+1).htm")!
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, response, error in
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("server error")
                    return
                }
                if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                            let data = data,
                            let string = String(data: data, encoding: .utf8) {
                                DispatchQueue.main.async {
                                    if self.newsList[loadingPage].count>0{
                                        self.tableView.reloadData()
                                        return
                                    }
                                    let lines=string.replacingOccurrences(of: "\t", with: "").split(separator: "\r\n")
                                    for i in lines{
                                        let contents=i.split(separator: ">")
                                        if contents[0] == "<span class=\"news_title\""{
                                            let news=News().setTitle(title: contents[2].replacingOccurrences(of: "</a", with: ""))
                                                .setUrl(url: "https://itsc.nju.edu.cn"+contents[1].split(separator: "\'")[1])
                                            self.newsList[loadingPage].append(news)
                                        }
                                        else if contents[0] == "<span class=\"news_meta\""{
                                            if self.newsList[loadingPage].count>0{
                                                self.newsList[loadingPage].last?.date=contents[1].replacingOccurrences(of: "</span", with: "")
                                            }
                                        }else if contents[0]=="         <span class=\"pages\""{
                                            self.pageController.numberOfPages=((contents[4].replacingOccurrences(of: "</em", with: "")) as NSString).integerValue
                                            if self.pageController.numberOfPages<2{
                                                self.pageController.isHidden=true
                                            }
                                        }
                                }
                                    self.tableView.reloadData()
                            }
                }
            })
        task.resume()
        task.priority=1
        }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.newsList[self.currentPage].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        if self.newsList[self.currentPage].count>=indexPath.row+1{
            cell.date.text=self.newsList[self.currentPage][indexPath.row].date
            cell.title.text=self.newsList[self.currentPage][indexPath.row].title
            cell.backgroundColor=UIColor(red: 0.2+0.03*CGFloat(indexPath.row%16)+0.02*CGFloat(self.currentPage%16), green: 0.2, blue: 0.6, alpha: 0.5)
        }
        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        (segue.destination as! InfoViewController).myURL = newsList[self.currentPage][tableView.indexPath(for: sender as! NewsTableViewCell)!.row].url
    }

    
    
    @IBAction func page_change(_ sender: UIPageControl) {
        self.currentPage = sender.currentPage
        loadWeb()
    }
}
