//
//  Helpers.swift
//  GrainChain1
//
//  Created by José Cadena on 09/03/20.
//  Copyright © 2020 GranChain. All rights reserved.
//

import Foundation
import UIKit
class Helpers{
    static func showAlertOk(vc:UIViewController, title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            
        }
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func calculateDurations(start:Date,end:Date)->String{
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let string = formatter.string(from: start, to: end)
        return string!
    }
}
