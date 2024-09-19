//
//  UIControl+Block.swift
//  NewsAlertUI
//
//  Created by A. A. Sivash on 15.06.17.
//  Copyright © 2017 A. A. Sivash. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ActionBlockWrapperInteface: NSObjectProtocol { }
public final class ActionBlockWrapper<T: UIControl> : NSObject, ActionBlockWrapperInteface {
    var block : (_ sender: T) -> Void
    
    let signature: String
    init(signature: String, block: @escaping (_ sender: T) -> Void) {
        self.block = block
        self.signature = signature
        super.init()
    }
    
    @objc func handleBlockInteraction(control: UIControl) {
        guard let accessibleControl = control as? T else { return }
        block(accessibleControl)
    }
    
    public override var debugDescription: String {
        return "ActionBlockWrapper: T:\(String(describing: T.self)) \(signature)"
    }
}

//MARK: - 📦 set block

let eventHandlersMap = NSMapTable< UIControl, NSMapTable<NSNumber, ActionBlockWrapperInteface>>(keyOptions: .weakMemory, valueOptions: .strongMemory)

public protocol UIControlClosureActionable: UIControl { } //Forward conform

extension UIControlClosureActionable {
    
    public func setBlock(file: String = #file, line: Int = #line, block: @escaping (_ sender: Self) -> Void, forEvent event: Self.Event) {
        let mapTableKey = NSNumber(value: event.rawValue)
        let controlMapTable = eventHandlersMap.object(forKey: self) ?? NSMapTable(keyOptions: .strongMemory, valueOptions: .strongMemory)
        let wrapper = ActionBlockWrapper<Self>(signature: "\(file):\(line)", block: block)
        controlMapTable.setObject(wrapper, forKey: mapTableKey)
        eventHandlersMap.setObject(controlMapTable, forKey: self)
        addTarget(wrapper, action: #selector(ActionBlockWrapper<Self>.handleBlockInteraction(control:)), for: event)
    }
    
    public func removeBlock(forEvent event: Event) {
        let mapTableKey = NSNumber(value: event.rawValue)
        eventHandlersMap.object(forKey: self)?.removeObject(forKey: mapTableKey)
        removeTarget(self, action: #selector(ActionBlockWrapper<Self>.handleBlockInteraction(control:)), for: event)
    }
    
    public func removeBlocksForAllEvents() {
        eventHandlersMap.removeObject(forKey: self)
    }
}

extension UIControl: UIControlClosureActionable { } //Backward conform
