//
//  ViewController.swift
//  Calendar
//
//  Created by Émerson M Luz on 30/03/24.
//

import UIKit

class ViewController: UIViewController {
    
    private let calendarView: CalendarView = CalendarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate = self
        view.addSubview(calendarView)
        
        calendarView.enableInteraction = false
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
    }
}

extension ViewController: CalendarViewDelegate {
    func savedDates(transfer dates: [Date]) {
        print("asd ", dates)
    }
}
