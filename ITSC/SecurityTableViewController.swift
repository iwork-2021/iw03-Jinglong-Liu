//
//  SecurityTableViewController.swift
//  ITSC
//
//  Created by mac on 2021/11/6.
//

import UIKit

class SecurityTableViewController: UITableViewController {

    @IBOutlet weak var pageController: UIPageControl!
    var newsList:Array<Array<News>>=[]
    var currentPage:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWeb()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    func loadWeb() {
        let loadingPage=self.currentPage
        while self.newsList.count < loadingPage + 1{
            self.newsList.append([])
        }
        if self.newsList[self.currentPage].count > 0{
            self.tableView.reloadData()
            return
        }
        let url = URL(string: "https://itsc.nju.edu.cn/aqtg/list\(self.currentPage+1).htm")!
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
                                    if self.newsList[self.currentPage].count>0{
                                        self.tableView.reloadData()
                                        return
                                    }
                                    self.parseHtml(string: string)
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
        if self.newsList[self.currentPage].count >= indexPath.row + 1{
            cell.date.text = self.newsList[self.currentPage][indexPath.row].date
            cell.title.text = self.newsList[self.currentPage][indexPath.row].title
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
        (segue.destination as! PageViewController).myURL = newsList[self.currentPage][tableView.indexPath(for: sender as! NewsTableViewCell)!.row].url
    }

    

    @IBAction func change_page(_ sender: Any) {
        self.currentPage = (sender as! UIPageControl).currentPage
        self.loadWeb()
    }
    private func parseHtml(string:String){
        let lines=string.replacingOccurrences(of: "\t", with: "").split(separator: "\r\n")
        for i in lines{
            let contents=i.split(separator: ">")
            if contents[0] == "<span class=\"news_title\""{
                let news=News()
                .setTitle(title: contents[2].replacingOccurrences(of: "</a", with: ""))
                .setUrl(url: "https://itsc.nju.edu.cn"+contents[1].split(separator: "\'")[1])
                self.newsList[self.currentPage].append(news)
            }
            else if contents[0] == "<span class=\"news_meta\""{
                if self.newsList[self.currentPage].count > 0{
                    self.newsList[self.currentPage].last?.setDate(date: contents[1].replacingOccurrences(of: "</span", with: ""))
                   
                }
            }else if contents[0] == "         <span class=\"pages\""{
                self.pageController.numberOfPages = ((contents[4].replacingOccurrences(of: "</em", with: "")) as NSString).integerValue
                if self.pageController.numberOfPages < 2{
                    self.pageController.isHidden = true
                }
            }
        }
    }
}
