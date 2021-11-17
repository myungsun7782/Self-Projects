//
//  TodoDetailViewController.swift
//  TodoListApp
//
//  Created by user on 2021/11/16.
//

import UIKit
import CoreData

protocol TodoDetailViewControllerDelegate: AnyObject {
    func didFinishSaveData()
}


class TodoDetailViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    weak var delegate:TodoDetailViewControllerDelegate?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var lowButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var highButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var selectedTodoList: TodoList? // 사용자에 의해 선택된 TodoList 타입의 entity 변수?
    
    var priority: PriorityLevel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let hasData = selectedTodoList {
            titleTextField.text = hasData.title
            
            priority = PriorityLevel(rawValue: hasData.priorityLevel)
            makePriorityButtonDesign()
            
            deleteButton.isHidden = false
            saveButton.setTitle("update", for: .normal)
            
        }else {
            deleteButton.isHidden = true
            saveButton.setTitle("save", for: .normal)
        }
        
    }
    
    
    // 레이아웃이 결정되고 나서 아래와 같은 일을 수행하고자 할 때 이 메서드를 override하여 사용
    /// 다른 뷰들의 컨텐트 업데이트
    /// 뷰들의 크기나 위치를 최종적으로 조정
    /// 테이블의 데이터를 reload
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 버튼을 둥글게 하는 로직
        lowButton.layer.cornerRadius = lowButton.bounds.height / 2
        normalButton.layer.cornerRadius = normalButton.bounds.height / 2
        highButton.layer.cornerRadius = highButton.bounds.height / 2
    }

    @IBAction func setPriority(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            priority = .level1
        case 2:
            priority = .level2
        case 3:
            priority = .level3
        default:
            break
        }
        
        makePriorityButtonDesign()
        
    }
    // priority button 들의 색깔을 디자인하는 함수
    func makePriorityButtonDesign() {
        lowButton.backgroundColor = .clear
        normalButton.backgroundColor = .clear
        highButton.backgroundColor = .clear
        
        switch self.priority {
        case .level1:
            lowButton.backgroundColor = priority?.color
        case .level2:
            normalButton.backgroundColor = priority?.color
        case .level3:
            highButton.backgroundColor = priority?.color
        default:
            break
        }
        
        
    }
    
    @IBAction func saveTodo(_ sender: Any) {
        
        if selectedTodoList != nil {
            updateTodo()
        }else {
            saveTodo()
        }
        
       
        
        delegate?.didFinishSaveData()
        
        self.dismiss(animated: true)
        
        
        
    }
    
    // 새로운 정보를 저장하는 함수
    func saveTodo() {
        // core Data 안에 있는 entity에 대한 정보
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "TodoList", in: context) else { return }
       
        // TodoList entity 안에 있는 key-value 형태로 가져온다.
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? TodoList else { return }
        
        object.title = titleTextField.text
        object.date = Date()
        object.uuid = UUID()
        
        object.priorityLevel = priority?.rawValue ?? PriorityLevel.level1.rawValue
        
        
        
        //  saveContext를 해야 로컬 db에 최종적으로 저장이 완료된다!
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        appDelegate.saveContext()
    }
    
    // 기존의 정보를 갱신하여 저장하는 함수
    func updateTodo() {
        
        guard let hasData = selectedTodoList else {
            return
        }
        
        guard let hasUUID = hasData.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        
     
        // 로컬 DB에 있는 해당 attribute만 가져오고 싶을 때 predicate를 사용한다.
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        
        do {
            
            let loadedData = try context.fetch(fetchRequest)
            
            loadedData.first?.title = titleTextField.text
            loadedData.first?.date = Date()
            loadedData.first?.priorityLevel = self.priority?.rawValue ?? PriorityLevel.level1.rawValue
            
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
            appDelegate.saveContext()
        }catch {
            print(error)
        }
        
        
    }
    
    
    // 해당 to-do-list 데이터를 삭제하는 함수
    @IBAction func deleteTodo(_ sender: UIButton){
        guard let hasData = selectedTodoList else {
            return
        }
        
        guard let hasUUID = hasData.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        
     
        // 로컬 DB에 있는 해당 attribute만 가져오고 싶을 때 predicate를 사용한다.
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        
        do {
            
            let loadedData = try context.fetch(fetchRequest)
            if let loadFirstData = loadedData.first {
                context.delete(loadFirstData)
                
                
                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                
                appDelegate.saveContext()
                
                
            }
            
        }catch {
            print(error)
        }
        
        delegate?.didFinishSaveData()
        
        self.dismiss(animated: true)
        
    }
     

}
