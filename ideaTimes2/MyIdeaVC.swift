//
//  MyIdeaVC.swift
//  ideaTimes2
//
//  Created by Elvina Jacia on 27/04/22.
//

import UIKit
import CoreData

class MyIdeaVC: UIViewController{
    
    @IBOutlet weak var ideasPageBackground: UIImageView!
    
    //navbar button
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //field
    
    @IBOutlet weak var ideaTitleField: UITextField!
    
    @IBOutlet weak var ideaCategoriesField: UITextField!
    
    @IBOutlet weak var executionDateField: UITextField!
    
    @IBOutlet weak var ideaDescriptionField: UITextView!
    
    //Category Picker View
    let category = ["Personal", "Work"]
    var categoryPickerView = UIPickerView()
    
    //Date Picker
    let datePicker = UIDatePicker()
    
    //TextView
    @IBOutlet var ideaDescription: UITextView!
    
    var selectedIdeas: IdeasData? = nil
 //////

    let ideaTV = IdeasTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To blur background
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView()
        blurEffectView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        blurEffectView.center = view.center
        self.ideasPageBackground.addSubview(blurEffectView)
        UIView.animate(withDuration: 2) {
            blurEffectView.effect = blurEffect
        }
        
        //set ideaTitle
        ideaTitleField.returnKeyType = .done
        ideaTitleField.delegate = self
        
        //set pickerview delegate & datasource
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
            //set input viewn untuk field category = category pickerview
        ideaCategoriesField.text = "Personal"
        ideaCategoriesField.inputView = categoryPickerView
            //set input textnya ke left
        ideaCategoriesField.textAlignment = .left
        
        //set datepicker (call func create datepicker)
        createDatePicker()
        
        //set text view idea description di awal
        ideaDescription.text = "Idea Description"
        ideaDescription.textColor = UIColor.lightGray
        ideaDescription.returnKeyType = .done
       
        ideaDescription.delegate = self
        
        if(selectedIdeas != nil){
            ideaTitleField.text = selectedIdeas?.ideasTitle
            ideaCategoriesField.text = selectedIdeas?.ideasCategory
           
            let dateFormatter = DateFormatter()
//INI DATENYA MASIH HARUS DIPERBAIKI, KARENA HARUSNYA AMBIL DATA DATE SEBENARNYA
            executionDateField.text = dateFormatter.string(from:selectedIdeas?.execDate ?? Date())
            ideaDescriptionField.text = selectedIdeas?.ideasDesc
        }
        
    }
    
    //DatePicker
    func createDatePicker(){
        //set datepicker frame size
        datePicker.frame.size = CGSize(width: 0, height: 300)
        
        //set datenpicker style yang wheels
        datePicker.preferredDatePickerStyle = .wheels
        
        //biar text alignmentnya rata kiri
        executionDateField.textAlignment = .left
        
        //create tool bar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        //bar button done
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: true)
        
        //assign toolbar
        executionDateField.inputAccessoryView = toolBar
        
        //assign date picker to textfield
        executionDateField.inputView = datePicker
        
        //DatePickerMode (assign date picker just to show date)
        datePicker.datePickerMode = .date
    }
    
    //func doneButtonPressed in datepicker
    @objc func donePressed(){
        //bikin formatter biar tanggal yang muncul di textfield rapi
        let dformatter = DateFormatter()
        dformatter.dateStyle = .medium
        dformatter.timeStyle = .none
        
        
        //set tanggal di field biar jadi yang dipilih (kalau gapake formatter)
        //executionDateField.text = "\(datePicker.date)"
        
        //set execDatefield biar muncul tanggal saja sesuai format yang sudah ditentukan oleh dformatter
        executionDateField.text = dformatter.string(from: datePicker.date)
        
        self.view.endEditing(true)
    }
    

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveButtonAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        if(selectedIdeas == nil){
            let entity = NSEntityDescription.entity(forEntityName: "IdeasData", in: context)
        
                //kalo personal & kalo work, pisah savenya
                if ideaCategoriesField.text == "Personal"{
                    let newIdeas =  IdeasData(entity: entity!, insertInto: context)
                    newIdeas.ideasID = Int32(truncating: personalIdeasList.count as NSNumber)
                    newIdeas.ideasTitle = ideaTitleField.text
                    newIdeas.ideasCategory = ideaCategoriesField.text
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy"
                    // Convert Date to String
                    newIdeas.execDate = dateFormatter.date(from: executionDateField.text!)
   //                 print(newIdeas.execDate)
                    newIdeas.ideasDesc = ideaDescriptionField.text
                    
                    do{
                        try context.save()
                        personalIdeasList.append(newIdeas)
                        //back to idea dump
                       // navigationController?.popViewController(animated: true)
                        navigationController?.popToRootViewController(animated: true)
                        
                    } catch{
                        print("context save error")
                    }
            
        }else if ideaCategoriesField.text == "Work"{
                    let newIdeas =  IdeasData(entity: entity!, insertInto: context)
                    newIdeas.ideasID = Int32(truncating: workIdeasList.count as NSNumber)
                    newIdeas.ideasTitle = ideaTitleField.text
                    newIdeas.ideasCategory = ideaCategoriesField.text
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy"
                    // Convert Date to String
                    newIdeas.execDate = dateFormatter.date(from: executionDateField.text!)
                    newIdeas.ideasDesc = ideaDescriptionField.text
            
                    
                    do{
                        try context.save()
                        workIdeasList.append(newIdeas)
                        //back to idea dump
                        //navigationController?.popViewController(animated: true)
                        navigationController?.popToRootViewController(animated: true)

                      } catch{
                        print("context save error")
                      }
      
        }
        
            
        //edit ideas
        }else{
            //ini buat nampung previous category yang di select
            let categoryPrevValue = selectedIdeas?.ideasCategory
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "IdeasData")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results{
                    let idea = result as! IdeasData

  
                    
// INI MASIH BELUM WORK yg category masih belum keganti di tampilannya
                    //pakai if else personal atau work
                            if(idea == selectedIdeas){
                                idea.ideasTitle = ideaTitleField.text
                                idea.ideasCategory = ideaCategoriesField.text

                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM d, yyyy"
                                idea.execDate = dateFormatter.date(from: executionDateField.text!)
                                
                                idea.ideasDesc = ideaDescriptionField.text
                                
                                    try context.save()
                                
                                
                                if(categoryPrevValue == "Personal"){
                                   // showIdeasList = personalIdeasList
                                  //removesemuaarraynya
                                    if(idea.ideasCategory != categoryPrevValue){
                                        showIdeasList.remove(at: selectedIndex)
                                        personalIdeasList.remove(at: selectedIndex)
                                    
                                    workIdeasList.append(idea)
                                    }
                                } else if(categoryPrevValue == "Work"){
                                    if(idea.ideasCategory != categoryPrevValue){
                                        showIdeasList.remove(at: selectedIndex)
                                        workIdeasList.remove(at: selectedIndex)
                                    
                                    personalIdeasList.append(idea)
                                    }
                                }
                                
                                //buat cek aja
                               // print(showIdeasList)
                                
                        //backtoideasdump
                            // navigationController?.popViewController(animated: true)
                                navigationController?.popToRootViewController(animated: true)
                            }
    
                    
                }
            } catch  {
                print("Fetch failed")
            }
            
            
        }
    }
}

//EXTENSION

//extension for text field
extension MyIdeaVC: UITextFieldDelegate{
    
    // Func delegate ketika text field idea title ketika selesai edit, keyboard akan dismiss
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ideaTitleField.resignFirstResponder()
        return true
    }
    
}

//extension for text view
    extension MyIdeaVC : UITextViewDelegate{
        //  Func delegate ketika text view idea desc diedit
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text ==  "Idea Description"{
                textView.text = ""
                textView.textColor = UIColor(red: 0.40, green: 0.23, blue: 0.02, alpha: 1.00)
            }
        }
          
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
              if text == "\n"{
                  textView.resignFirstResponder()
              }
              return true
          }
          
          func textViewDidEndEditing(_ textView: UITextView) {
              if textView.text == ""{
                ideaDescription.text = "Idea Description"
                  ideaDescription.textColor = UIColor.gray
                ideaDescription.returnKeyType = .done
              }
          }
    }

//extension for pickerView
    extension MyIdeaVC: UIPickerViewDelegate, UIPickerViewDataSource{
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return category.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return category[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            //ambil text dari pickerview dan assign ke textfield [swift auto tau row yg mana]:
            ideaCategoriesField.text = category[row]
            ideaCategoriesField.resignFirstResponder()
            
        }
        
    }

