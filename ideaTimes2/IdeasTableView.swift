//
//  IdeasTableView.swift
//  ideaTimes2
//
//  Created by Elvina Jacia on 27/04/22.
//

import UIKit
import CoreData

//struct sbg datasource table view
//struct ideasStruct{
//    var ideasID : Int32
//    var ideasTitle : String
//    var ideasCategory : String
//    var ideasDesc : String
//    var execDate : Date
//}

//declare array of ideas globally untuk bisa diakses di swift file lain
//var personalIdeasList = [ideasStruct]()
//var workIdeasList = [ideasStruct]()
//
//var showIdeasList = [ideasStruct]()

var personalIdeasList = [IdeasData]()
var workIdeasList = [IdeasData]()

var showIdeasList = [IdeasData]()

var selectedIndex = 0

class IdeasTableView: UITableViewController{
    
    var firstLoad = true
    
    @IBOutlet var ideaTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var noIdeasAvailable: UILabel!
    
    @IBOutlet weak var composeButton: UIButton!
    
    //////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(firstLoad){
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "IdeasData")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results{
                    let idea = result as! IdeasData
                    
                    //bisa jadi juga pakai if else personal atau work
                    //personalIdeasList.append(idea)
                    //workIdeasList.append(idea)
                    
                    //MASIH NGACO
                    if(segmentControl.selectedSegmentIndex==0 ){
                        
                        //kalo segment control 0 dan ideanya tipenya personal baru dia masuk sini
                        showIdeasList=personalIdeasList
                        //showIdeasList.append(idea)
                        personalIdeasList.append(idea)
                        ideaTableView.reloadData()
                    }else if(segmentControl.selectedSegmentIndex==1){
                        showIdeasList=workIdeasList
                        //showIdeasList.append(idea)
                        workIdeasList.append(idea)
                        ideaTableView.reloadData()
                    }
                }
            } catch  {
                print("Fetch failed")
            }
        }
        
        print(personalIdeasList)
    
        //self.view.backgroundColor = UIColor(red: 1.00, green: 0.98, blue: 0.95, alpha: 1.00)
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        //add searchbar
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
       
        //set cancel button color on search bar to chocolate (#6C4817)
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 108/255, green: 72/255, blue: 23/255, alpha: 1)]
         UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        //TESTING ADD ARRAY AJA
        //add personalidealist ke tableview
       // personalIdeasList.append(ideasStruct(ideasID: 1, ideasTitle: "Test", ideasCategory: "Personal", ideasDesc: "Testing", execDate: Date()))
        
        showIdeasList = personalIdeasList

        // munculin no ideas available klo ga ad data ide yg tersedia
             if showIdeasList.count == 0 {
                 noIdeasAvailable.isHidden = false
             } else if showIdeasList.count > 0 {
                 noIdeasAvailable.isHidden = true
             }
        print(showIdeasList)
    }
    //////////////
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ideasCellID", for: indexPath) as! IdeasCell
        cell.ideaTitle.text =  showIdeasList[indexPath.row].ideasTitle
        cell.ideaDesc.text = showIdeasList[indexPath.row].ideasDesc
        
        //time
        let dateFormatter = DateFormatter()
        
        //date format
        dateFormatter.dateFormat = "MM/dd/yyyy"
        // Convert Date to String
       
        //TANGGAL MASIH NGACO
        cell.executionDate.text = dateFormatter.string(from: showIdeasList[indexPath.row].execDate ?? Date())
                                                 
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showIdeasList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToMyIdeas", sender: self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        ideaTableView.reloadData()
    }
    
    
    @IBAction func composeButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "goToMyIdeas", sender: composeButton)
    }
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        selectedIndex = self.segmentControl.selectedSegmentIndex
        switch selectedIndex{
          case 0:
              //return peopleArray.count
           
            showIdeasList = personalIdeasList
            ideaTableView.reloadData()
            
            if showIdeasList.count == 0 {
                noIdeasAvailable.isHidden = false
            } else if showIdeasList.count > 0 {
                noIdeasAvailable.isHidden = true
            }
           
          
            print("Personal")
            
          case 1:
             //return imagesArray.count
            showIdeasList = workIdeasList
            ideaTableView.reloadData()
            
            if showIdeasList.count == 0 {
                noIdeasAvailable.isHidden = false
            } else if showIdeasList.count > 0 {
                noIdeasAvailable.isHidden = true
            }
            
            print("Work")
            
          default:
            //defaultnya sama kaya case 0
            print("Personal")
            showIdeasList = personalIdeasList
            ideaTableView.reloadData()
            
          }
    }
    
    
    
    
    
}
