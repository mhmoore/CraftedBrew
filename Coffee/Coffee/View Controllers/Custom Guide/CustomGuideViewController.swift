//
//  CustomGuideViewController.swift
//  Coffee
//
//  Created by Michael Moore on 9/23/19.
//  Copyright © 2019 Michael Moore. All rights reserved.
//

import UIKit

class CustomGuideViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var coffeeTextField: UITextField!
    @IBOutlet weak var grindTextField: UITextField!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addStepButton: ActionButton!
    @IBOutlet weak var stepsTableView: UITableView!
    
    // MARK: - Properties
    var guide: Guide?
    var editingGuide: Bool?
    var coffeeRange: [String] = []
    let grinds = [GrindKeys.fineKey,
                  GrindKeys.fineMediumKey,
                  GrindKeys.mediumKey,
                  GrindKeys.mediumCoarseKey,
                  GrindKeys.coarseKey,
                  GrindKeys.extraCoarseKey]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        stepsTableView.tableFooterView = UIView()
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        titleTextField.delegate = self
        coffeeTextField.delegate = self
        grindTextField.delegate = self
        stepsTableView.isEditing = false
        updateViews()
        setupUI()
        guard let guide = guide else { return }
        coffeeRange = createCoffeeRange(guide: guide)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stepsTableView.reloadData()
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        stepsTableView.isEditing.toggle()
        if stepsTableView.isEditing == true {
            editButton.setTitle("Done", for: .normal)
        } else {
            editButton.setTitle("Edit", for: .normal)
        }
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let guide = guide,
            let title = titleTextField.text else { return }
        guide.title = title
        for standardGuide in GuideController.shared.standardGuides {
            if standardGuide == guide {
                return
            }
        }
        
        if title.isEmpty || waterLabel.text == "0.0" {
            let alert = UIAlertController(title: "Empty Fields", message: "Please fill in all fields before saving", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(okay)
            present(alert, animated: true)
            return
        }
        
        if editingGuide == true {
            GuideController.shared.saveToPersistentStorage()
            navigationController?.popToRootViewController(animated: true)
            return
        }
        
        if GuideController.shared.userGuides == nil {
            GuideController.shared.userGuides = []
            GuideController.shared.userGuides?.append(guide)
        } else {
            GuideController.shared.userGuides?.insert(guide, at: 0)
        }
        
        GuideController.shared.saveToPersistentStorage()
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Custom Methods
    func setupUI() {
        view.backgroundColor = .background
        stepsTableView.backgroundColor = .textFieldBackground
        editButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        addStepButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        
    }
    
    func updateViews() {
        guard let guide = guide else { return }
        methodLabel.text = guide.method
        titleTextField.text = guide.title
        grindTextField.text = guide.grind
        coffeeTextField.text = String(guide.coffee)
        waterLabel.text = "\(totalWater(guide: guide))"
        let ratioNumbers = getRatio(guide: guide)
        ratioLabel.text = "\(ratioNumbers.0) : \(ratioNumbers.1)"
        let time = totalTime(guide: guide)
        timeLabel.text = timeAsString(time: time)
        createGrindPicker()
        createCoffeePicker()
        createToolBar()
    }
    
    func totalWater(guide: Guide) -> Double {
        var array: [Double] = []
        for step in guide.steps {
            guard let water = step.water else { return 0.0 }
            array.append(water)
        }
        return array.reduce(0, +)
    }
    
    func totalTime(guide: Guide) -> TimeInterval {
        var array: [TimeInterval] = []
        for step in guide.steps {
            guard let time = step.time else { return 0.0 }
            array.append(time)
        }
        return array.reduce(0, +)
    }
    
    func timeAsString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        return timeString
    }
    
    func getRatio(guide: Guide) -> (Int, Int) {
        var coffee = Int(guide.coffee)
        var water = Int(totalWater(guide: guide))
        let result = gcd(coffee, water)
        if result == 0 {
            return (0,0)
        }
        coffee = coffee / result
        water = water / result
        return (coffee, water)
    }
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        if a == 0 || b == 0 {
            return 0
        }
        let remainder = a % b
        if remainder != 0 {
            return gcd(b, remainder)
        } else {
            return b
        }
    }
    
    func createCoffeeRange(guide: Guide) -> [String] {
        let less = guide.coffee - 3
        let more = guide.coffee + 3.3
        let pickerArray = Array(stride(from: round(less), to: round(more), by: 0.3))
        for value in pickerArray {
            coffeeRange.append("\(value)")
        }
        return coffeeRange
    }
    
    func createCoffeePicker() {
        let coffeePicker = UIPickerView()
        coffeePicker.tintColor = .generalType
        coffeePicker.backgroundColor = .textFieldBackground
        coffeePicker.delegate = self
        coffeeTextField.inputView = coffeePicker
    }
    
    func createGrindPicker() {
        let grindPicker = UIPickerView()
        grindPicker.tintColor = .generalType
        grindPicker.backgroundColor = .textFieldBackground
        grindPicker.delegate = self
        grindTextField.inputView = grindPicker
    }
    
    func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.backgroundColor = .textFieldBackground
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        doneButton.tintColor = .accent
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        grindTextField.inputAccessoryView = toolBar
        coffeeTextField.inputAccessoryView = toolBar
        titleTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editStepSegue" {
            guard let indexPath = stepsTableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? StepViewController,
                let guide = guide else { return }
            let step = guide.steps[indexPath.row]
            destinationVC.guide = guide
            destinationVC.step = step
            destinationVC.stepToggle = true
        } else if segue.identifier == "addStepSegue" {
            guard let destinationVC = segue.destination as? StepViewController,
                let guide = guide else { return }
            destinationVC.guide = guide
        }
    }
}

    // MARK: - TableView Delegate and DataSource
extension CustomGuideViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guide?.steps.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell", for: indexPath) as? CustomStepTableViewCell,
        let guide = guide else { return UITableViewCell() }
        let step = guide.steps[indexPath.row]
        cell.step = step
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let guide = guide else { return }
            let step = guide.steps[indexPath.row]
            GuideController.shared.remove(step: step, from: guide)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateViews()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let guide = guide else { return }
        if stepsTableView.isEditing == true {
            let step = guide.steps[sourceIndexPath.row]
            guide.steps.remove(at: sourceIndexPath.row)
            guide.steps.insert(step, at: destinationIndexPath.row)
        }
    }
}

    // MARK: - PickerView Delegate and DataSource
extension CustomGuideViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if grindTextField.isEditing {
            return grinds.count
        } else if coffeeTextField.isEditing {
            return coffeeRange.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if grindTextField.isEditing {
            return grinds[row]
        } else if coffeeTextField.isEditing {
            return coffeeRange[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let guide = guide else { return }
        var selectedCoffee: Double = guide.coffee
        var selectedGrind: String = guide.grind
        if grindTextField.isEditing {
            selectedGrind = grinds[row]
            grindTextField.text = selectedGrind
        } else if coffeeTextField.isEditing {
            guard let coffee = Double(coffeeRange[row]) else { return }
            selectedCoffee = coffee
            coffeeTextField.text = coffeeRange[row]
        }
        guide.grind = selectedGrind
        guide.coffee = selectedCoffee
    }
}
