//
//  GestureRecognizer+Block.swift
//  DebugSystem
//
//  Created by Alexander on 17/02/2020.
//  Copyright © 2019 Alexander Sivash. All rights reserved.
//

import Foundation
import UIKit

@objc protocol GestureRecognizerBlockWrapperInterface: NSObjectProtocol {
    func handleGesture(with: UIGestureRecognizer)
}

class GestureRecognizerBlockWrapper<T: UIGestureRecognizer>: NSObject, GestureRecognizerBlockWrapperInterface {
    
    var block: ((_ sender: T) -> Void)
    
    init(block: @escaping ((_ sender: T) -> Void)) {
        self.block = block
        super.init()
    }
    
    func handleGesture(with: UIGestureRecognizer) {
        guard let gesture = with as? T else { return }
        block(gesture)
    }
}

public protocol UIGestureRecognizerClosureActionable: UIGestureRecognizer { } //forward

//implementation
extension UIGestureRecognizerClosureActionable {

    public func setBlock(_ block: @escaping ((_ sender: Self) -> Void)) {
        let wrapper = GestureRecognizerBlockWrapper<Self>(block: block)
        objc_setAssociatedObject(self, &UIGestureRecognizer.recognizerBlockAssociatedKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(Self.handleGestureAction(sender:)))
    }
}

extension UIGestureRecognizer: UIGestureRecognizerClosureActionable { } //backward

public extension UIGestureRecognizer {
    
    static var recognizerBlockAssociatedKey: String = "kUIGestureRecognizerBlockAssociatedKey"
    
    @objc func handleGestureAction(sender: UIGestureRecognizer) {
        guard let wrapper = objc_getAssociatedObject(self, &UIGestureRecognizer.recognizerBlockAssociatedKey) as? GestureRecognizerBlockWrapperInterface else { return }
        wrapper.handleGesture(with: sender)
    }
}
