//
//  GuideIntroViewController.swift
//  Coffee
//
//  Created by Michael Moore on 9/23/19.
//  Copyright © 2019 Michael Moore. All rights reserved.
//

import UIKit

class GuideIntroViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var methodImage: UIImageView!
    @IBOutlet weak var methodInfoView: UIView!
    @IBOutlet weak var methodInfo: UILabel!
    @IBOutlet weak var grindImage: UIImageView!
    @IBOutlet weak var grindLabel: UILabel!
    @IBOutlet weak var coffeeLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var prepLabel: UILabel!
    
    // MARK: - Properties
    var guide: Guide?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInstructionVC" {
            guard let destinationVC = segue.destination as? InstructionViewController else { return }
            destinationVC.guide = guide
        } else if segue.identifier == "toCustomVC" {
            guard let destinationVC = segue.destination as? CustomGuideViewController,
                let guide = guide else { return }
            if guide.userGuide == true {
                destinationVC.guide = guide
                destinationVC.editingGuide = true
            } else {
                // makes a copy of guide and steps so that it doesn't make changes to the standard guide
                let stepsCopy = guide.steps.map { step in
                    Step(title: step.title, water: step.water, time: step.time, text: step.text)
                }
                let guideCopy = Guide(userGuide: true, title: guide.title, method: guide.method, methodInfo: guide.methodInfo, coffee: guide.coffee, grind: guide.grind, prep: guide.prep, steps: stepsCopy)
                destinationVC.guide = guideCopy
                destinationVC.editingGuide = false
            }
        }
    }
    
    // MARK: - Custom Methods
    func setupUI() {
        view.backgroundColor = .background
        methodInfoView.backgroundColor = .textFieldBackground
        methodInfoView.addCornerRadius(8)
    }
    
    func loadData() {
        guard let guide = guide else { return }
        title = guide.method
        methodInfo.text = guide.methodInfo
        grindLabel.text = guide.grind
        grindImage.layer.cornerRadius = grindImage.frame.height / 2
        coffeeLabel.text = "\(guide.coffee)g"
        waterLabel.text = "\(totalWater(guide: guide))g"
        let timeString = timeAsString(time: totalTime(guide: guide))
        timeLabel.text = timeString
        let ratioNumbers = getRatio(guide: guide)
        ratioLabel.text = "\(ratioNumbers.0) : \(ratioNumbers.1)"
        prepLabel.text = guide.prep
        
        switch guide.grind {
        case GrindKeys.fineKey:
            grindImage.image = UIImage(named: AssetKeys.fineKey)
        case GrindKeys.fineMediumKey:
            grindImage.image = UIImage(named: AssetKeys.fineMediumKey)
        case GrindKeys.mediumKey:
            grindImage.image = UIImage(named: AssetKeys.mediumKey)
        case GrindKeys.mediumCoarseKey:
            grindImage.image = UIImage(named: AssetKeys.mediumCoarseKey)
        case GrindKeys.coarseKey:
            grindImage.image = UIImage(named: AssetKeys.coarseKey)
        case GrindKeys.extraCoarseKey :
            grindImage.image = UIImage(named: AssetKeys.extraCoarseKey)
        default:
            grindImage.image = nil
        }
        
        switch guide.method {
        case BrewKeys.chemexKey:
            methodImage.image = UIImage(named: AssetKeys.chemexKey)
        case BrewKeys.aeroPressKey:
            methodImage.image = UIImage(named: AssetKeys.aeroPressKey)
        case BrewKeys.frenchPressKey:
            methodImage.image = UIImage(named: AssetKeys.frenchPressKey)
        case BrewKeys.kalitaKey:
            methodImage.image = UIImage(named: AssetKeys.kalitaKey)
        case BrewKeys.v60Key:
            methodImage.image = UIImage(named: AssetKeys.v60Key)
        default:
            methodImage.image = nil
        }
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
        coffee = coffee / result
        water = water / result
        return (coffee, water)
    }
    
    func gcd(_ coffee: Int, _ water: Int) -> Int {
        guard water > 0 else { return 0 }
        let remainder = coffee % water
        return remainder != 0 ? gcd(water, remainder) : water
    }
}
