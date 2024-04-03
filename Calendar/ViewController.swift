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
        view.addSubview(calendarView)
        calendarView.numberOfDaysToSelec(5)
        calendarView.colors(CalendarColor(headerTitleColor: .orange, headerBackgroundColor: .blue, weekBackgroundColor: .red, backgroundColor: .systemBlue, selectionColor: (selected: .yellow, interval: .red)))
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }


}

