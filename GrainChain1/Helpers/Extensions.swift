//
//  Extensions.swift
//  GrainChain1
//
//  Created by José Cadena on 09/03/20.
//  Copyright © 2020 GranChain. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func addBorderColorRounded(width: CGFloat, color: UIColor, round:CGFloat){
        let colorCG = color.cgColor
        self.layer.cornerRadius = round
        self.layer.borderWidth = width
        self.layer.borderColor = colorCG
    }
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
