//
//  QNButtonView.swift
//  qplayer2demo
//
//  Created by Dynasty Dream on 2022/12/20.
//

import Foundation
class QNButtonView:UIButton {
    init(frame: CGRect, title:String, target : Any , action : Selector) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1)
        self.layer.cornerRadius = 10
        self.isSelected = false
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
