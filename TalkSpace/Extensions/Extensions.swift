//
//  Extensions.swift
//  TalkSpace
//
//  Created by MacBook Pro on 22/09/2024.
//

import UIKit

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
