//
//  OnboardViewController.swift
//  AppLaunch
//
//  Created by mac on 22/09/18.
//  Copyright © 2018 Ideabeez. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {
    
    @IBOutlet weak var onboardScreen: OnboardingView!
    @IBOutlet weak var getStartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardScreen.dataSource = self
        onboardScreen.delegate = self
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let backgroundColorOne = UIColor(red: 217/255, green: 72/255, blue: 89/255, alpha: 1)
        let backgroundColorTwo = UIColor(red: 106/255, green: 166/255, blue: 211/255, alpha: 1)
        let backgroundColorThree = UIColor(red: 168/255, green: 200/255, blue: 78/255, alpha: 1)
        
        let titleFont = UIFont(name: "HelveticaNeue-Light", size: 24)!
        let descriptionFont = UIFont(name: "HelveticaNeue-Light", size: 14)!
        
        return [
            
            OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "Onboard-S3"),
                               title: "Hello, Let Started",
                               description: "This is for viewing; thus, giving users the opportunity to learn how to get started in the growing.",
                               pageIcon: #imageLiteral(resourceName: "if_Paul-05_2524735"),
                               color: backgroundColorOne,
                               titleColor: UIColor.white,
                               descriptionColor: UIColor.white,
                               titleFont: titleFont,
                               descriptionFont: descriptionFont),
            
            OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "Onboard-S1"),
                               title: "Read Articles",
                               description: "This is for viewing; thus, giving users the opportunity to learn how to get started in the growing.",
                               pageIcon: #imageLiteral(resourceName: "if_Paul-05_2524735"),
                               color: backgroundColorTwo,
                               titleColor: UIColor.white,
                               descriptionColor: UIColor.white,
                               titleFont: titleFont,
                               descriptionFont: descriptionFont),
            
            OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "Onboard-S2"),
                               title: "Photography",
                               description: "This is for viewing; thus, giving users the opportunity to learn how to get started in the growing.",
                               pageIcon: #imageLiteral(resourceName: "if_Paul-05_2524735"),
                               color: backgroundColorThree,
                               titleColor: UIColor.white,
                               descriptionColor: UIColor.white,
                               titleFont: titleFont,
                               descriptionFont: descriptionFont)
            
        ][index]
        
    }
    
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index _: Int) {
        //you can configure the custom item attributes.
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        
        if index == 1 {
            if self.getStartButton.alpha == 1 {
                UIView.animate(withDuration: 0.2) {
                    self.getStartButton.alpha = 0
                }
            }
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2 {
            UIView.animate(withDuration: 0.4) {
                self.getStartButton.alpha = 1
            }
        }
    }
    
    
    @IBAction func getStarted(_ sender: Any) {
        
            let userdefaults = UserDefaults.standard
            userdefaults.set(true, forKey: "OnboardingCompleted")
            userdefaults.synchronize()
    }
    

}

/* (UIImage.init(imageLiteralResourceName: "Onboard-S1"), "Hello, Let Started", "This is for viewing; thus, giving users the opportunity to learn how to get started in the growing and researching for free", UIImage.init(imageLiteralResourceName: "Onboard-S1"), backgroundColorOne, UIColor.white, UIColor.white, titleFont, descriptionFont) */
