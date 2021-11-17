//
//  ViewController.swift
//  TodoListApp
//
//  Created by user on 2021/11/16.
//

import UIKit
import CoreData

enum PriorityLevel: Int64 {
    case level1
    case level2
    case level3
    
}

extension PriorityLevel {
    var color:UIColor {
        switch self {
        case .level1 :
            return .green
        case .level2:
            return .orange
        case .level3:
            return .red
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var todoTableView: UITableView! // 테이블 뷰 변수
    
    // 싱글톤으로 가져오는 개념
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    // TodoList entity 형의 배열
    var todoList = [TodoList]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "To Do List"
        self.makeNavigationBar()
        
        
        // 테이블 뷰 연결
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        fetchData()
        todoTableView.reloadData() // 데이터를 가져왔으면 reload (데이터를 뿌려준다.)
        
        
    }
    
    // local DB에 저장되어 있는 데이터를 불러오는 함수
    func fetchData() {
        let fetchRequest:NSFetchRequest<TodoList> = TodoList.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        
        do {
            
            self.todoList = try context.fetch(fetchRequest)
            
            
        }catch {
            print(error)
        }
        
    }
    
    
    // + 버튼 누르면 호출되는 함수
    @objc func addNewTodo(){
        let detailVC = TodoDetailViewController.init(nibName: "TodoDetailViewController", bundle: nil)
        detailVC.delegate = self
        self.present(detailVC,animated: true, completion: nil)
        
    }
    
    // 네비게이션바에 대한 구체적인 속성 값을 지정해주는 함수
    func makeNavigationBar() {
        
        // 네비게이션 바에 들어갈 버튼 아이템 생성
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTodo))
        item.tintColor = .black
        navigationItem.rightBarButtonItem = item // 네비게이션 바 오른쪽 아이템에  item 추가
        
        // 네비게이션바 배경 색 설정
        self.navigationController?.navigationBar.backgroundColor = .orange
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        // status bar design
        // window는 모든 화면의 밑바탕 (화면 계층 맨 아래에 존재한다)
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        
        sceneDelegate?.statusBarView.backgroundColor = .orange
        
        
        
        // SceneDelegate 안에 있는 window를 가져오는 과정
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if let hasStatusBar = sceneDelegate?.statusBarView{
          

//            self.view.addSubview(hasStatusBar) -> 현재 화면에서의 statusbar에만 적용이 되고, 화면이 이동된 뒤의 statusbar에는 적용이 안 된다.
            window?.addSubview(hasStatusBar)
        }
        
        
        
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 셀 등록하는 과정
        // TodoCell 안에 있는 컴포넌트에 접근 하기 위해 TodoCell로 형 변환
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        
        // 셀 안에 있는 topTitle 값 설정
        cell.topTitleLabel.text = todoList[indexPath.row].title
        
        // 셀 안에 있는 date 값 설정
        // dateFormatter 사용
        if let hasDate = todoList[indexPath.row].date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd hh:mm:ss"
            let dateString = formatter.string(from: hasDate)
            
            cell.dateLabel.text = dateString
        }else {
            cell.dateLabel.text = ""
        }
        
        
        // 로컬 DB에 저장되어 있는 우선순위에 따라서 셀에 있는 priority가 표시되는 로직
        let priority = todoList[indexPath.row].priorityLevel
        
        let priorityColor = PriorityLevel(rawValue: priority)?.color
        
        cell.priorityView.backgroundColor = priorityColor
        
        // priorityView를 둥글게 만들기!
        cell.priorityView.layer.cornerRadius = cell.priorityView.bounds.height / 2
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = TodoDetailViewController.init(nibName: "TodoDetailViewController", bundle: nil)
        detailVC.delegate = self
        detailVC.selectedTodoList = todoList[indexPath.row]
        self.present(detailVC,animated: true, completion: nil)
        
    }
    
  
 

}

extension ViewController: TodoDetailViewControllerDelegate {
    func didFinishSaveData() {
        fetchData()
        self.todoTableView.reloadData()
    }
    
    
}

