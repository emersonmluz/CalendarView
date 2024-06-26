import UIKit

protocol CalendarViewDelegate {
    func savedDates(transfer dates: [Date])
}

//MARK: - CalendarView
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
    private var interval = false
    private var dayPlus = -1
    private var buttonTag = 1000
    var enableInteraction = false
    var delegate: CalendarViewDelegate?
    
    private var numberOfDays: Int = 0 {
        didSet {
            if numberOfDays <= 0 {
                interval = false
            } else {
                interval = true
            }
        }
    }
    
    var colors: (
        monthTitle: UIColor,
        headerBackground: UIColor,
        weekTitles: UIColor,
        weekBackground: UIColor,
        sundayColor: UIColor,
        calendarBackground: UIColor,
        daySelected: UIColor,
        daySelectedBackground: UIColor,
        daysIntervalBackground: UIColor,
        daysOfMonth: UIColor,
        otherDays: UIColor
    ) = (
        .white,
        .systemRed,
        .systemGray,
        .clear,
        .systemRed,
        .white,
        .white,
        UIColor.systemRed,
        UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1),
        UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1),
        UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1)
    ) {
        didSet {
            if monthYearLabel.textColor != colors.monthTitle {
                monthYearLabel.textColor = colors.monthTitle
                backMonthButton.tintColor = colors.monthTitle
                nextMonthButton.tintColor = colors.monthTitle
            }
            if headerHStack.backgroundColor != colors.headerBackground {
                headerHStack.backgroundColor = colors.headerBackground
            }
            if daysOfWeekHStack.backgroundColor != colors.weekBackground {
                daysOfWeekHStack.backgroundColor = colors.weekBackground
            }
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            setupViews()
            setupMonthNavigationButtons()
            setupDaysOfWeekHStack()
            setupHierarchy()
            setupConstraints()
            updateCalendar(nextMonth: false, isBrowsing: false)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = colors.calendarBackground
        layer.borderWidth = 1
        let customGrey = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        layer.borderColor = customGrey
        layer.cornerRadius = 6
        clipsToBounds = true
    }
    
    //MARK: - Month Navigation Button
    private func setupMonthNavigationButtons() {
        backMonthButton.addTarget(self, action: #selector(monthNavigationAction), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(monthNavigationAction), for: .touchUpInside)
    }
    
    //MARK: - Days of Week
    private func setupDaysOfWeekHStack() {
        let daysOfWeek: [DaysOfWeek] = [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday,
            .sunday
        ]
        
        for day in daysOfWeek {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = day.rawValue
            label.font = .systemFont(ofSize: 14, weight: .bold)
            if day == .sunday {
                label.textColor = colors.sundayColor
            } else {
                label.textColor = colors.weekTitles
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
    
    //MARK: - Update Calendar
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
                        let containerButton = createContainerView(to: dayPrevious)
                        currentStackView?.addArrangedSubview(containerButton)
                    }
                }
            }
            let button = createDayButton(day: day)
            let containerButton = createContainerView(to: button)
            currentStackView?.addArrangedSubview(containerButton)
        }
        
        let remainingSpaces = 7 - (currentStackView?.arrangedSubviews.count ?? 0)
        for index in 0..<remainingSpaces {
            if let dayFuture = createAlternativeDays(previousToCurrent: false, adjustDayWithIndex: index) {
                let containerButton = createContainerView(to: dayFuture)
                currentStackView?.addArrangedSubview(containerButton)
            }
        }
        
        if interval {
            updateSelection(nextMonth: nextMonth, isBrowsing: isBrowsing)
        } else {
            updateOneSelection(nextMonth: nextMonth, isBrowsing: isBrowsing)
        }
        
    }
    
    //MARK: - Actions Day Tapped
    @objc private func dayContinuousAction(_ sender: UIButton) {
        guard enableInteraction == true else { return }
        guard validateSelection(sender) else { return }
        clearSelection()
        
        let (_, selectionColor) = selectionColor()
        sender.backgroundColor = selectionColor
        sender.titleLabel?.textColor = colors.daySelected
        sender.setTitleColor(colors.daySelected, for: .normal)
        
        DispatchQueue.main.async { [weak self] in
            guard let self, let titleLabel = sender.titleLabel, let day = titleLabel.text else { return }
            let adjustMonth: Int = 0
            saveSelection(dayInit: day, adjustMonth: adjustMonth)
            updateCalendar(nextMonth: false, isBrowsing: false)
        }
    }
    
    //MARK: - Actions Select one day
    @objc private func selectOneDayAction(_ sender: UIButton) {
        guard enableInteraction == true, let day = sender.titleLabel?.text, !existSelection(day), sender.titleLabel?.textColor == colors.daysOfMonth, validateSelection(sender)
        else {
            sender.backgroundColor = .clear
            if sender.titleLabel?.textColor == colors.daySelected {
                sender.titleLabel?.textColor = colors.daysOfMonth
                sender.setTitleColor(colors.daysOfMonth, for: .normal)
            }
            let year = Calendar.current.component(.year, from: calendarMonth)
            let month = Calendar.current.component(.month, from: calendarMonth)
            let dateString = "\(year)-\(month)-\(sender.titleLabel?.text ?? "")"
            let date = formatStringToDate(with: dateString)
            if savedDates.count > 0 {
                for index in 0...savedDates.count - 1 {
                    if savedDates[index] == date {
                        savedDates.remove(at: index)
                        break
                    }
                }
            }
            return
        }
        
        let (_, selectionColor) = selectionColor()
        sender.backgroundColor = selectionColor
        sender.titleLabel?.textColor = colors.daySelected
        sender.setTitleColor(colors.daySelected, for: .normal)
        
        DispatchQueue.main.async { [weak self] in
            guard let self, let titleLabel = sender.titleLabel, let day = titleLabel.text else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formatDate = formatDateToSave(dayInit: day)
            if let date = dateFormatter.date(from: formatDate) {
                savedDates.append(date)
                let removeDuplicates = Set(savedDates)
                savedDates = Array(removeDuplicates)
                let dates = savedDates.sorted()
                delegate?.savedDates(transfer: dates)
                updateCalendar(nextMonth: false, isBrowsing: false)
            }
        }
    }
    
    //MARK: - Action Navigation
    @objc private func monthNavigationAction(_ sender: UIButton) {
        let previousMonth = -1
        let nextMonth = 1
        let valueToCalcMonth = sender === backMonthButton ? previousMonth : nextMonth
        
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
    
    //MARK: - Func Save Selection
    private func saveSelection(dayInit: String, adjustMonth: Int = 0) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = formatDateToSave(dayInit: dayInit, adjustMonth: adjustMonth)
        if let dateInit = dateFormatter.date(from: date) {
            saveDates(dateInit: dateInit, daysOfNumber: numberOfDays)
        }
    }
    
    //MARK: - Func Format Date To Save
    private func formatDateToSave(dayInit: String, adjustMonth: Int = 0) -> String {
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
        
        return "\(year)-\(month)-\(dayInit)"
    }
    
    //MARK: - Func Save Dates
    private func saveDates(dateInit: Date, daysOfNumber: Int) {
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
    
    //MARK: - Func Update Selection
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
                        
                        if dayCalendar == String(dayBase), monthCalendar == monthBase, button.currentTitleColor == colors.daysOfMonth {
                            
                            guard !existSelection(dayCalendar ?? "") else { return }
                            let dateFirst = savedDates.first
                            let dateLast = savedDates.last
                            
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                if numberOfDays > 1 {
                                    container.backgroundColor = intervalColor
                                }
                                
                                if date == dateFirst || date == dateLast {
                                    button.backgroundColor = selectionColor
                                    button.titleLabel?.textColor = colors.daySelected
                                    button.setTitleColor(colors.daySelected, for: .normal)
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
    
    //MARK: - Update One Selection
    private func updateOneSelection(nextMonth: Bool, isBrowsing: Bool) {
        guard !savedDates.isEmpty else { return }
        
        let (_, selectionColor) = selectionColor()
        
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
                        
                        if dayCalendar == String(dayBase), monthCalendar == monthBase, yearBase == yearCalendar, button.currentTitleColor == colors.daysOfMonth {
                            
                            guard !existSelection(dayCalendar ?? "") else { return }
                            
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                button.backgroundColor = selectionColor
                                button.titleLabel?.textColor = colors.daySelected
                                button.setTitleColor(colors.daySelected, for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Func Fill Future Days
    private func fillFutureDays(_ days: Int) {
        guard let horizontalStack = daysVStack.arrangedSubviews.last, days > 0, let firstDate = savedDates.first, let lastDate = savedDates.last else { return }
        
        let firstDay = Calendar.current.component(.day, from: firstDate)
        let lastDay = Calendar.current.component(.day, from: lastDate)
        let firstMonth = Calendar.current.component(.month, from: firstDate)
        let lastMonth = Calendar.current.component(.month, from: lastDate)
        let monthCalendar = Calendar.current.component(.month, from: calendarMonth)
        let (intervalColor, selectionColor) = selectionColor()
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
                        button.titleLabel?.textColor = colors.daySelected
                        button.setTitleColor(colors.daySelected, for: .normal)
                        DispatchQueue.main.async { [weak self] in
                            container.layer.mask = self?.shapeLeft(container)
                        }
                    }
                    if day == lastDay, container.backgroundColor == intervalColor, monthCalendar == firstMonth {
                        button.backgroundColor = selectionColor
                        button.titleLabel?.textColor = colors.daySelected
                        button.setTitleColor(colors.daySelected, for: .normal)
                        DispatchQueue.main.async { [weak self] in
                            container.layer.mask = self?.shapeRight(container)
                            if monthCalendar == 1 {
                                container.layer.mask = self?.clearShape(bounds: container.bounds)
                                
                            }
                        }
                    }
                    if monthCalendar < firstMonth, day < firstDay, button.titleLabel?.textColor == colors.otherDays {
                        container.backgroundColor = .clear
                        button.backgroundColor = .clear
                    }
                }
            }
        }
    }
    
    //MARK: - Func Fill Remaining Days
    private func fillRemainingDays(nextMonth: Bool, daysRemaining: Int) {
        guard let horizontalStack = daysVStack.arrangedSubviews.first, nextMonth else { return }
        let (intervalColor, selectionColor) = selectionColor()
        var numberRemaining = 0
        for container in horizontalStack.subviews {
            if let button = container.subviews.first as? UIButton {
                if button.currentTitleColor != colors.daysOfMonth {
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
                            button.titleLabel?.textColor = colors.daySelected
                            button.setTitleColor(colors.daySelected, for: .normal)
                            DispatchQueue.main.async { [weak self] in
                                container.layer.mask = self?.shapeLeft(container)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Func Exist Selection
    private func existSelection(_ day: String?) -> Bool {
        let daySelected = colors.daySelectedBackground
        for horizontalStack in daysVStack.arrangedSubviews {
            for container in horizontalStack.subviews {
                if let button = container.subviews.first as? UIButton {
                    if button.titleLabel?.text == day, button.backgroundColor == daySelected {
                        return true
                    }
                    if button.backgroundColor == daySelected, day == nil {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    //MARK: - Func Number of Days
    private func numberOfDaysInMonth(date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }
    
    //MARK: - Func Get Previous Day
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
    
    //MARK: - Func Format Month
    private func getFormatMonth(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "MMMM yyyy"
        let month = dateFormatter.string(from: date)
        return month.prefix(1).capitalized + month.suffix(month.count - 1)
    }
    
    //MARK: - Func Convert To Date
    private func formatStringToDate(with date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFormat = dateFormatter.date(from: date)
        return dateFormat ?? Date()
    }
    
    //MARK: - Func Selection Color
    private func selectionColor() -> (UIColor, UIColor) {
        return (colors.daysIntervalBackground, colors.daySelectedBackground)
    }
    
    //MARK: - Func Validate Selection
    private func validateSelection(_ sender: UIButton) -> Bool {
        guard let day = Int(sender.currentTitle ?? "") else {
            return false
        }
        let month = Calendar.current.component(.month, from: calendarMonth)
        let year = Calendar.current.component(.year, from: calendarMonth)
        let dateSuggestionString = "\(year)-\(month)-\(day)"
        let dateSuggestion = formatStringToDate(with: dateSuggestionString)
        let datePlus = Calendar.current.date(byAdding: .day, value: dayPlus, to: Date())
        guard let dateMinimum = datePlus, dateSuggestion >= dateMinimum, sender.titleLabel?.textColor == colors.daysOfMonth else { return false }
        return true
    }
    
    //MARK: - Func Shape Left
    private func shapeLeft(_ view: UIView) -> CAShapeLayer {
        let maskLayer = createShapeMask(bounds: view.bounds, cornerTop: .topLeft, cornerBotton: .bottomLeft)
        return maskLayer
    }
    
    //MARK: - Func Shape Right
    private func shapeRight(_ view: UIView) -> CAShapeLayer {
        let maskLayer = createShapeMask(bounds: view.bounds, cornerTop: .topRight, cornerBotton: .bottomRight)
        return maskLayer
    }
    
    //MARK: - Func Clear Shape
    private func clearShape(bounds: CGRect) -> CAShapeLayer {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topRight, .topLeft, .bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 0, height: 0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        return maskLayer
    }
    
    //MARK: - Create Day Button
    private func createDayButton(day: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(String(day), for: .normal)
        button.setTitleColor(colors.daysOfMonth, for: .normal)
        button.titleLabel?.textColor = colors.daysOfMonth
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.tag = buttonTag
        buttonTag += 1
        button.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        if interval {
            button.addTarget(self, action: #selector(dayContinuousAction(_:)), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(selectOneDayAction(_:)), for: .touchUpInside)
        }
        return button
    }
    
    //MARK: - Create Days Stack
    private func createDaysHStack() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return stackView
    }
    
    //MARK: - Create Alternative Days
    private func createAlternativeDays(previousToCurrent: Bool, adjustDayWithIndex: Int) -> UIButton? {
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendarMonth),
              let monthInterval = Calendar.current.range(of: .day, in: .month, for: previousMonth)
        else {
            return nil
        }
        
        let adjustBound = 1
        let adjustDaysOfTheMonth = adjustDayWithIndex + adjustBound
        let dayPreviousMonth = previousToCurrent
            ? monthInterval.upperBound - adjustDaysOfTheMonth
            : monthInterval.lowerBound + adjustDaysOfTheMonth - adjustBound
        let button = createDayButton(day: dayPreviousMonth)
        button.setTitleColor(colors.otherDays, for: .normal)
        button.titleLabel?.textColor = colors.otherDays
        return button
    }
    
    //MARK: - Create ContainerView
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
    
    //MARK: - Methods
    func dateInit(month: Int, year: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            calendarMonth = date
        }
        updateCalendar(nextMonth: false, isBrowsing: false)
    }
    
    func dayPlus(_ dplus: Int) {
        dayPlus = dplus <= 0 ? -1 : dplus - 1
        if let date = Calendar.current.date(byAdding: .day, value: dayPlus, to: calendarMonth) {
            calendarMonth = date
        }
    }
    
    func numberOfContinuousDays(_ value: Int) {
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
    
    //MARK: - Enum Days of Week
    private enum DaysOfWeek: String {
        case sunday = "Dom"
        case monday = "Seg"
        case tuesday = "Ter"
        case wednesday = "Qua"
        case thursday = "Qui"
        case friday = "Sex"
        case saturday = "Sáb"
    }
}
