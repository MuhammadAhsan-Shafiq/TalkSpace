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

extension String {
    func boundingRect(with size: CGSize, options: NSStringDrawingOptions, attributes: [NSAttributedString.Key: Any]?, context: NSStringDrawingContext?) -> CGRect {
        return (self as NSString).boundingRect(with: size, options: options, attributes: attributes, context: context)
    }
}
