//
//  SettingsViewController.swift
//  CardFlip
//
//  Created by Jordan Doczy on 11/20/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {

    // MARK: Members
    @IBOutlet weak var audioSwitch: UISwitch!
    @IBOutlet weak var difficultySelector: UISegmentedControl!

    // MARK: IBActions
    @IBAction func audioToggle(_ sender: UISwitch) {
        UserSettings.shared.sound = audioSwitch.isOn
        SoundPlayer.shared.play(Assets.Sounds.Click)
    }

    @IBAction func close(_ sender: AnyObject) {
        if let presenter = presentingViewController as? MatchGameViewController {
            presenter.difficulty = UserSettings.shared.difficulty
        }
        dismiss(animated: true)
    }

    @IBAction func difficultySelection(_ sender: UISegmentedControl) {
        SoundPlayer.shared.play(Assets.Sounds.Click)
        if let difficulty = UserSettings.Difficulty(rawValue: difficultySelector.selectedSegmentIndex) {
            UserSettings.shared.difficulty = difficulty
        }
    }

    @IBAction func linkToFreepik(_ sender: UIButton) {
        if let url = URL(string: "https://www.freepik.com/free-vector/animals-flat-vector-set_715458.htm") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        audioSwitch.isOn = UserSettings.shared.sound
        difficultySelector.selectedSegmentIndex = UserSettings.shared.difficulty.rawValue
    }
}
