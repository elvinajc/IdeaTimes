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

var selectedIdeas : IdeasData? = nil


class IdeasTableView: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate{

    
    //search bar
    let searchController = UISearchController(searchResultsController: nil)
    var filteredIdeas = [IdeasData]()
    
    var firstLoad = true

    
    @IBOutlet var ideaTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var noIdeasAvailable: UILabel!
    
    @IBOutlet weak var composeButton: UIButton!
    
    //////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
        if(firstLoad){
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
         
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "IdeasData")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results{
                    let idea = result as! IdeasData
                    
                    //pakai if else personal atau work
                    
                        if(idea.ideasCategory == "Personal"){
                        showIdeasList=personalIdeasList
                        personalIdeasList.append(idea)
                        ideaTableView.reloadData()
                        
                        
                        }else if(idea.ideasCategory == "Work"){
                        showIdeasList=workIdeasList
                        workIdeasList.append(idea)
                        ideaTableView.reloadData()
                        
                    }
                }
            } catch  {
                print("Fetch failed")
            }
        }
    
    
        
        showIdeasList = personalIdeasList

        // munculin no ideas available klo ga ad data ide yg tersedia
             if showIdeasList.count == 0 {
                 noIdeasAvailable.isHidden = false
             } else if showIdeasList.count > 0 {
                 noIdeasAvailable.isHidden = true
             }
       // print(showIdeasList)
        
      
    }
    //////////////

    
    func initSearchController(){
        searchController.loadViewIfNeeded()
//        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
       
        //set cancel button color on search bar to chocolate (#6C4817)
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 108/255, green: 72/255, blue: 23/255, alpha: 1)]
         UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        searchController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        print("searchText", searchText)
       filteredIdeas = searchText.isEmpty ? showIdeasList: showIdeasList.filter {
        (item: IdeasData) -> Bool in
      //  If data = searchText, return true to include it
           return item.ideasTitle!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
       }
                tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ideasCellID", for: indexPath) as! IdeasCell
        if searchController.isActive{
            cell.ideaTitle.text = filteredIdeas[indexPath.row].ideasTitle
            cell.ideaDesc.text = filteredIdeas[indexPath.row].ideasDesc
            
            //time
            let dateFormatter = DateFormatter()
            
            //date format
            dateFormatter.dateFormat = "MMM d, yyyy"
            // Convert Date to String
           
            cell.executionDate.text = dateFormatter.string(from: filteredIdeas[indexPath.row].execDate ?? Date())
            return cell
            
        }else{
        cell.ideaTitle.text =  showIdeasList[indexPath.row].ideasTitle
        cell.ideaDesc.text = showIdeasList[indexPath.row].ideasDesc
        
        //time
        let dateFormatter = DateFormatter()
        
        //date format
        dateFormatter.dateFormat = "MMM d, yyyy"
        // Convert Date to String
       
        cell.executionDate.text = dateFormatter.string(from: showIdeasList[indexPath.row].execDate ?? Date())
                                                 
        
        return cell
            
        }
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive){
        return filteredIdeas.count
        }else{
        return showIdeasList.count
        }
    }
    
    
    ///DELETE TRAILING ACTION
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Component Delete action
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteData(ideaTitle: showIdeasList[indexPath.row].ideasTitle!)
            
            showIdeasList.remove(at: indexPath.row)
            
            if(self!.segmentControl.selectedSegmentIndex==0){
                personalIdeasList.remove(at: indexPath.row)
                tableView.reloadData()
            }else if (self!.segmentControl.selectedSegmentIndex==1){
                workIdeasList.remove(at: indexPath.row)
                tableView.reloadData()
            }

            completionHandler(true)
        }
        delete.backgroundColor = UIColor(red: 0.42, green: 0.28, blue: 0.09, alpha: 1.00)

        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    ///////
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editIdeas", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editIdeas"){
            let indexPath = tableView.indexPathForSelectedRow!
            let myIdea = segue.destination as? MyIdeaVC
            let selectedIdeas : IdeasData!
 
                selectedIdeas = showIdeasList[indexPath.row]
            
            myIdea!.selectedIdeas = selectedIdeas
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
    
 func deleteData(ideaTitle: String) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let manageContext = appDelegate.persistentContainer.viewContext
     
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
     let request = NSFetchRequest<NSFetchRequestResult>(entityName: "IdeasData")
     
     //set obj yang mau di delete
       request.predicate = NSPredicate(format: "ideasTitle == %@", ideaTitle)
        
        do {
            let objectFrom = try context.fetch(request)
            
            let objectToDelete = objectFrom[0] as! NSManagedObject
            context.delete(objectToDelete)
            
            do {
                try context.save()
            } catch {
                print(error)
            }

        } catch let error as NSError {
            print("Error due to : \(error.localizedDescription)")
        }
        
    }
    
    

}



