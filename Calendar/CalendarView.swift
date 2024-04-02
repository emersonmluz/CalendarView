//
//  CalendarView.swift
//  Calendar
//
//  Created by Émerson M Luz on 30/03/24.
//

import UIKit

protocol CalendarViewDelegate {
    func savedDates(transfer dates: [Date])
}

final class CalendarView: UIView {
    private let contentVStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private let headerHStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .systemRed
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return stackView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return view
    }()
    
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let backMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let arrow = UIImageView()
        arrow.image = UIImage(systemName: "arrowtriangle.left.fill")
        button.setImage(arrow.image, for: .normal)
        button.tintColor = .white
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let arrow = UIImageView()
        arrow.image = UIImage(systemName: "arrowtriangle.right.fill")
        button.setImage(arrow.image, for: .normal)
        button.tintColor = .white
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return button
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    private let daysOfWeekHStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.backgroundColor = .white
        stackView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return stackView
    }()
    
    private let daysVStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    //MARK: - Property
    private var calendarMonth = Date()
    private var savedDates: [Date] = []
    private var numberOfDays: Int = 0
    private var dateNowPlusDays = -1
    private var buttonTag = 1000
    var delegate: CalendarViewDelegate?
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupMonthNavigationButtons()
        setupDaysOfWeekHStack()
        setupHierarchy()
        setupConstraints()
        updateCalendar(nextMonth: false, isBrowsing: false)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.borderWidth = 1
        let customGrey = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        layer.borderColor = customGrey
        layer.cornerRadius = 6
        clipsToBounds = true
    }
    
    private func setupMonthNavigationButtons() {
        backMonthButton.addTarget(self, action: #selector(monthNavigationAction), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(monthNavigationAction), for: .touchUpInside)
    }
    
    private func setupDaysOfWeekHStack() {
        let daysOfWeek = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"]
        for day in daysOfWeek {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = day
            label.font = .systemFont(ofSize: 14, weight: .bold)
            if day == "Dom" {
                label.textColor = .systemRed
            } else {
                label.textColor = .systemGray
            }
            label.numberOfLines = 1
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            daysOfWeekHStack.addArrangedSubview(label)
        }
    }
    
    //MARK: - Hierarchy
    private func setupHierarchy() {
        addSubview(contentVStack)
        setupHeaderHierarchy()
        contentVStack.addArrangedSubview(daysOfWeekHStack)
        contentVStack.setCustomSpacing(0, after: daysOfWeekHStack)
        contentVStack.addArrangedSubview(daysVStack)
        addSubview(lineView)
    }
    
    //MARK: - Header Hierarchy
    private func setupHeaderHierarchy() {
        contentVStack.addArrangedSubview(headerHStack)
        headerHStack.addArrangedSubview(headerView)
        headerView.addSubview(monthYearLabel)
        headerView.addSubview(backMonthButton)
        headerView.addSubview(nextMonthButton)
        contentVStack.setCustomSpacing(0, after: headerHStack)
    }
    
    //MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentVStack.topAnchor.constraint(equalTo: topAnchor),
            contentVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentVStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            
            monthYearLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            monthYearLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            backMonthButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backMonthButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            nextMonthButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            lineView.topAnchor.constraint(equalTo: headerHStack.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    //MARK: - Update
    private func updateCalendar(nextMonth: Bool, isBrowsing: Bool) {
        daysVStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttonTag = 1000
        monthYearLabel.text = getFormatMonth(date: calendarMonth)
        
        var currentStackView: UIStackView?
        let daysPreviousMonth = getPreviousDays(date: calendarMonth)
        let totalDaysInMonth = numberOfDaysInMonth(date: calendarMonth)
        
        for day in 1...totalDaysInMonth {
            if currentStackView == nil || currentStackView?.arrangedSubviews.count == 7 {
                currentStackView = createDaysHStack()
                guard let currentStackView else { return }
                daysVStack.addArrangedSubview(currentStackView)
            }
            
            if day == 1 {
                for index in 0..<daysPreviousMonth {
                    if let dayPrevious = createAlternativeDays(previousToCurrent: true, adjustDayWithIndex: (daysPreviousMonth - 1) - index) {
                        let container = createContainerView(to: dayPrevious)
                        currentStackView?.addArrangedSubview(container)
                    }
                }
            }
            
            let button = createDayButton(day: day)
            let container = createContainerView(to: button)
            currentStackView?.addArrangedSubview(container)
        }
        
        let remainingSpaces = 7 - (currentStackView?.arrangedSubviews.count ?? 0)
        for index in 0..<remainingSpaces {
            if let dayFuture = createAlternativeDays(previousToCurrent: false, adjustDayWithIndex: index) {
                let container = createContainerView(to: dayFuture)
                currentStackView?.addArrangedSubview(container)
            }
        }
        
        updateSelection(nextMonth: nextMonth, isBrowsing: isBrowsing)
    }
    
    //MARK: - Create
    private func createDayButton(day: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(String(day), for: .normal)
        let customBlack = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)
        button.setTitleColor(customBlack, for: .normal)
        button.titleLabel?.textColor = customBlack
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.tag = buttonTag
        buttonTag += 1
        button.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createDaysHStack() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return stackView
    }
    
    private func createAlternativeDays(previousToCurrent: Bool, adjustDayWithIndex: Int) -> UIButton? {
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendarMonth),
              let monthInterval = Calendar.current.range(of: .day, in: .month, for: previousMonth) else {
            return nil }
        let adjustBound = 1
        let adjustDaysOfTheMonth = adjustDayWithIndex + adjustBound
        let dayPreviousMonth = previousToCurrent
        ? monthInterval.upperBound - adjustDaysOfTheMonth
        : monthInterval.lowerBound + adjustDaysOfTheMonth - adjustBound
        
        let button = createDayButton(day: dayPreviousMonth)
        let customGrey = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
        button.setTitleColor(customGrey, for: .normal)
        return button
    }
    
    private func createContainerView(to component: UIView) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(component)
        component.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        component.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        return containerView
    }
    
    private func createShapeMask(bounds: CGRect, cornerTop: UIRectCorner, cornerBotton: UIRectCorner) -> CAShapeLayer {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [cornerTop, cornerBotton],
                                    cornerRadii: CGSize(width: 15, height: 15))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        return maskLayer
    }
    
    //MARK: - Actions
    @objc func dayButtonTapped(_ sender: UIButton) {
        guard numberOfDays > 1 else { return }
        guard validateSelection(sender) else { return }
        clearSelection()
        
        let (_, selectionColor) = selectionColor()
        sender.backgroundColor = selectionColor
        sender.titleLabel?.textColor = .white
        sender.setTitleColor(.white, for: .normal)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let adjustMonth: Int = 0
            let day: String = String(Int(sender.titleLabel?.text ?? "1") ?? 1)
            
            saveSelection(dayInit: day, adjustMonth: adjustMonth)
            updateCalendar(nextMonth: false, isBrowsing: false)
        }
    }
    
    //MARK: - Navigation
    @objc func monthNavigationAction(_ sender: UIButton) {
        let valueToCalcMonth = sender === backMonthButton ? -1 : 1
        calendarMonth = Calendar.current.date(byAdding: .month, value: valueToCalcMonth, to: calendarMonth) ?? Date()
        
        let lastMonth = Calendar.current.component(.month, from: savedDates.last ?? Date())
        let monthCalendar = Calendar.current.component(.month, from: calendarMonth)
        
        if sender === backMonthButton {
            if lastMonth == monthCalendar {
                updateCalendar(nextMonth: true, isBrowsing: true)
            } else {
                updateCalendar(nextMonth: false, isBrowsing: true)
            }
        } else {
            updateCalendar(nextMonth: true, isBrowsing: true)
        }
    }
    
    //MARK: - Functions
    private func saveSelection(dayInit: String, adjustMonth: Int = 0) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var month = Calendar.current.component(.month, from: calendarMonth)
        var year = Calendar.current.component(.year, from: calendarMonth)
        month += adjustMonth
        
        if month == 0 {
            month = 12
            year += -1
        } else if month == 13 {
            month = 1
            year += 1
        }
        
        let date = "\(year)-\(month)-\(dayInit)"
        if let date = dateFormatter.date(from: date) {
            saveDateSelection(dateInit: date, daysOfNumber: numberOfDays)
        }
    }
    
    private func saveDateSelection(dateInit: Date, daysOfNumber: Int) {
        var dates = [Date]()
        let calendar = Calendar.current
        for day in 0..<daysOfNumber {
            if let date = calendar.date(byAdding: .day, value: day, to: dateInit) {
                dates.append(date)
            }
        }
        savedDates = dates
        delegate?.savedDates(transfer: savedDates)
    }
    
    private func updateSelection(nextMonth: Bool, isBrowsing: Bool) {
        guard !savedDates.isEmpty, let firstDate = savedDates.first, let lastDate = savedDates.last else { return }
        
        let firstMonth = Calendar.current.component(.month, from: firstDate)
        let lastMonth = Calendar.current.component(.month, from: lastDate)
        let yearSave = Calendar.current.component(.year, from: firstDate)
        let yearCalendar = Calendar.current.component(.year, from: calendarMonth)
        let monthCalendar = Calendar.current.component(.month, from: calendarMonth)
        
        guard yearSave == yearCalendar || (firstMonth == 12 && lastMonth == 1 && yearCalendar == yearSave + 1 && monthCalendar == 1) else { return }
        
        let (intervalColor, selectionColor) = selectionColor()
        var daysRemaining = 0
        var daysFuture = 0
        
        for date in savedDates {
            let dayBase = Calendar.current.component(.day, from: date)
            let monthBase = Calendar.current.component(.month, from: date)
            let monthCalendar = Calendar.current.component(.month, from: calendarMonth)
            let yearBase = Calendar.current.component(.year, from: date)
            let yearCalendar = Calendar.current.component(.year, from: calendarMonth)
            
            for horizontalStack in daysVStack.arrangedSubviews {
                for container in horizontalStack.subviews {
                    if let button = container.subviews.first as? UIButton {
                        let dayCalendar = button.titleLabel?.text
                        let customBlack = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)
                        
                        if dayCalendar == String(dayBase), monthCalendar == monthBase, button.currentTitleColor == customBlack {
                            
                            guard !existSelection(dayCalendar ?? "") else { return }
                            let dateFirst = savedDates.first
                            let dateLast = savedDates.last
                            
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                container.backgroundColor = intervalColor
                                
                                if date == dateFirst || date == dateLast {
                                    button.backgroundColor = selectionColor
                                    button.titleLabel?.textColor = .white
                                    button.setTitleColor(.white, for: .normal)
                                    if date == dateFirst {
                                        DispatchQueue.main.async { [weak self] in
                                            container.layer.mask = self?.shapeLeft(container)
                                        }
                                        
                                    }
                                    if date == dateLast {
                                        DispatchQueue.main.async { [weak self] in
                                            container.layer.mask = self?.shapeRight(container)
                                        }
                                        daysRemaining = numberOfDays - (Int(dayCalendar ?? "0") ?? 0)
                                    }
                                } else {
                                    if container == horizontalStack.subviews.first {
                                        DispatchQueue.main.async { [weak self] in
                                            container.layer.mask = self?.shapeLeft(container)
                                        }
                                    }
                                    if container == horizontalStack.subviews.last {
                                        DispatchQueue.main.async { [weak self] in
                                            container.layer.mask = self?.shapeRight(container)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if monthBase == monthCalendar + 1 || yearBase == yearCalendar + 1 {
                daysFuture += 1
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            fillFutureDays(daysFuture)
            fillRemainingDays(nextMonth: nextMonth, daysRemaining: daysRemaining)
        }
    }
    
    private func fillFutureDays(_ days: Int) {
        guard let horizontalStack = daysVStack.arrangedSubviews.last, days > 0, let firstDate = savedDates.first, let lastDate = savedDates.last else { return }
        let firstDay = Calendar.current.component(.day, from: firstDate)
        let lastDay = Calendar.current.component(.day, from: lastDate)
        let firstMonth = Calendar.current.component(.month, from: firstDate)
        let lastMonth = Calendar.current.component(.month, from: lastDate)
        let monthCalendar = Calendar.current.component(.month, from: calendarMonth)
        let (intervalColor, selectionColor) = selectionColor()
        let customGrey = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
        var futureDays = days
        for container in horizontalStack.subviews {
            if let button = container.subviews.first as? UIButton {
                let day: Int = Int(button.titleLabel?.text ?? "0") ?? 0
                if container.backgroundColor != intervalColor, futureDays > 0, day < 7 {
                    container.backgroundColor = intervalColor
                    futureDays -= 1
                    if firstDay < 7, day < firstDay, lastMonth == monthCalendar {
                        container.backgroundColor = .clear
                    } else if firstDay < 7, day == firstDay {
                        button.backgroundColor = selectionColor
                        button.titleLabel?.textColor = .white
                        button.setTitleColor(.white, for: .normal)
                        DispatchQueue.main.async { [weak self] in
                            container.layer.mask = self?.shapeLeft(container)
                        }
                    }
                    if day == lastDay, container.backgroundColor == intervalColor, monthCalendar == firstMonth {
                        button.backgroundColor = selectionColor
                        button.titleLabel?.textColor = .white
                        button.setTitleColor(.white, for: .normal)
                        DispatchQueue.main.async { [weak self] in
                            container.layer.mask = self?.shapeRight(container)
                            if monthCalendar == 1 {
                                container.layer.mask = self?.clearShape(bounds: container.bounds)
                                
                            }
                        }
                    }
                    if monthCalendar < firstMonth, day < firstDay, button.titleLabel?.textColor == customGrey {
                        container.backgroundColor = .clear
                        button.backgroundColor = .clear
                    }
                }
            }
        }
    }
    
    private func fillRemainingDays(nextMonth: Bool, daysRemaining: Int) {
        guard let horizontalStack = daysVStack.arrangedSubviews.first, nextMonth else { return }
        let (intervalColor, selectionColor) = selectionColor()
        let customBlack = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)
        var numberRemaining = 0
        for container in horizontalStack.subviews {
            if let button = container.subviews.first as? UIButton {
                if button.currentTitleColor != customBlack {
                    numberRemaining += 1
                }
            }
        }
        let rangeInit = numberRemaining - daysRemaining
        guard rangeInit < numberRemaining else { return }
        for incrementTag in rangeInit...numberRemaining - 1 {
            for container in horizontalStack.subviews {
                if let button = container.subviews.first as? UIButton {
                    if button.tag == 1000 + incrementTag {
                        container.backgroundColor = intervalColor
                        if incrementTag == rangeInit {
                            button.backgroundColor = selectionColor
                            button.titleLabel?.textColor = .white
                            button.setTitleColor(.white, for: .normal)
                            DispatchQueue.main.async { [weak self] in
                                container.layer.mask = self?.shapeLeft(container)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func existSelection(_ day: String?) -> Bool {
        let secondaryColor = UIColor.systemRed
        for horizontalStack in daysVStack.arrangedSubviews {
            for container in horizontalStack.subviews {
                if let button = container.subviews.first as? UIButton {
                    if button.titleLabel?.text == day, button.backgroundColor == secondaryColor {
                        return true
                    }
                    if button.backgroundColor == secondaryColor, day == nil {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func numberOfDaysInMonth(date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }
    
    private func getPreviousDays(date: Date) -> Int {
        let calendar = Calendar.current
        guard let firstDayOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let lastDayOfPreviousMonth = calendar.date(byAdding: DateComponents(day: -1), to: firstDayOfCurrentMonth) else {
            return 0
        }
        let weekday = calendar.component(.weekday, from: lastDayOfPreviousMonth)
        var previousSpace = weekday - calendar.firstWeekday
        if previousSpace < 0 {
            previousSpace += 7
        }
        return previousSpace
    }
    
    private func getFormatMonth(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "MMMM yyyy"
        let month = dateFormatter.string(from: date)
        return month.prefix(1).capitalized + month.suffix(month.count - 1)
    }
    
    private func formatStringToDate(with date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFormat = dateFormatter.date(from: date)
        return dateFormat ?? Date()
    }
    
    private func selectionColor() -> (UIColor, UIColor) {
        let intervalColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        return (intervalColor, .systemRed)
    }
    
    private func validateSelection(_ sender: UIButton) -> Bool {
        guard let day = Int(sender.currentTitle ?? "") else {
            return false
        }
        let customBlack = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)
        let month = Calendar.current.component(.month, from: calendarMonth)
        let year = Calendar.current.component(.year, from: calendarMonth)
        let dateSuggestionString = "\(year)-\(month)-\(day)"
        let dateSuggestion = formatStringToDate(with: dateSuggestionString)
        let datePlus = Calendar.current.date(byAdding: .day, value: dateNowPlusDays, to: Date())
        guard let dateMinimum = datePlus, dateSuggestion >= dateMinimum, sender.titleLabel?.textColor == customBlack else { return false }
        return true
    }
    
    private func shapeLeft(_ view: UIView) -> CAShapeLayer {
        let maskLayer = createShapeMask(bounds: view.bounds, cornerTop: .topLeft, cornerBotton: .bottomLeft)
        return maskLayer
    }
    
    private func shapeRight(_ view: UIView) -> CAShapeLayer {
        let maskLayer = createShapeMask(bounds: view.bounds, cornerTop: .topRight, cornerBotton: .bottomRight)
        return maskLayer
    }
    
    private func clearShape(bounds: CGRect) -> CAShapeLayer {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topRight, .topLeft, .bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 0, height: 0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        return maskLayer
    }
    
    //MARK: - Methods
    func calendarMonthInit(nowPlus: Int) {
        let date = Date()
        calendarMonth = Calendar.current.date(byAdding: .month, value: nowPlus, to: date) ?? Date()
        updateCalendar(nextMonth: false, isBrowsing: false)
    }
    
    func updateNumberOfDays(_ value: Int) {
        numberOfDays = value
        savedDates = []
        updateCalendar(nextMonth: false, isBrowsing: false)
    }
    
    func enabledCalendar(_ isEnabled: Bool) {
        if isEnabled {
            self.alpha = 1
            self.isUserInteractionEnabled = true
        } else {
            self.alpha = 0.5
            self.isUserInteractionEnabled = false
        }
    }
    
    func clearSelection() {
        for horizontalStack in daysVStack.arrangedSubviews {
            for container in horizontalStack.subviews {
                container.backgroundColor = .clear
                container.subviews.first?.backgroundColor = .clear
                container.layer.mask = clearShape(bounds: container.bounds)
            }
        }
        savedDates = []
        updateCalendar(nextMonth: false, isBrowsing: false)
    }
}
