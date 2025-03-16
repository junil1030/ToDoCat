//
//  HomeViewModel.swift
//  ToDoCat
//
//  Created by 서준일 on 3/13/25.
//
import UIKit

class HomeViewModel {
    
    //MARK: - Properties
    private var allToDoList: [ToDoItem] = []
    private var selectedDate: Date = Date()
    
    var navigateToDetailView: (() -> Void)?
    
    var filteredToDoList: [ToDoItem] {
        return allToDoList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    //MARK: - Methods
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }
    
    func loadData() {
        //        let today = Date()
        //        let calendar = Calendar.current
        //
        //        // 샘플 이미지 생성 (실제 앱에서는 이미지를 로드하거나 사용자가 추가할 것)
        //        let sampleImage1 = createSampleImage(withColor: .systemBlue)
        //        let sampleImage2 = createSampleImage(withColor: .systemGreen)
        //        let sampleImage3 = createSampleImage(withColor: .systemOrange)
        //
        //        // 예시 텍스트 (100자 제한 보여주기 위해 긴 텍스트)
        //        let longText = "이것은 100자까지 입력이 가능한 콘텐츠 예시입니다. 테이블 뷰 셀에서는 최대 2줄까지만 표시되고, 나머지 내용은 생략됩니다. 이렇게 하면 사용자 인터페이스가 깔끔하게 유지되면서도 더 많은 내용을 볼 수 있는 상세 화면으로 이동할 수 있는 인터페이스를 제공합니다."
        //
        //        // 오늘 데이터
        //        allToDoList.append(ToDoItem(
        //            id: UUID(),
        //            date: today,
        //            content: longText,
        //            image: sampleImage1
        //        ))
        //
        //        // 어제 데이터
        //        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
        //            allToDoList.append(ToDoItem(
        //                id: UUID(),
        //                date: yesterday,
        //                content: "어제 콘텐츠 글",
        //                image: sampleImage2
        //            ))
        //        }
        //
        //        // 내일 데이터
        //        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
        //            allToDoList.append(ToDoItem(
        //                id: UUID(),
        //                date: tomorrow,
        //                content: "내일 콘텐츠 글",
        //                image: sampleImage3
        //            ))
        //        }
    }
    
    // 새 항목 추가 메서드
    func addEntry(title: String, content: String, image: UIImage? = nil) {
        let newToDo = ToDoItem(
            id: UUID(),
            date: selectedDate,
            content: content,
            image: image
        )
        allToDoList.append(newToDo)
    }
    
    func addTaskButtonTapped() {
        navigateToDetailView?()
    }
    
    // 샘플 이미지 생성 (실제 앱에서는 사용자가 제공하는 이미지 사용)
    private func createSampleImage(withColor color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 60, height: 60))
        }
    }
}
