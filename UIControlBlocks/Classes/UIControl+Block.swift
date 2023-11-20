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
public class ActionBlockWrapper<T: UIControl> : NSObject, ActionBlockWrapperInteface {
    var block : (_ sender: T) -> Void
    init(block: @escaping (_ sender: T) -> Void) {
        self.block = block
        super.init()
    }
    
    @objc func handleBlockInteraction(control: UIControl) {
        guard let accessibleControl = control as? T else { return }
        block(accessibleControl)
    }
}

let eventHandlersMap = NSMapTable< UIControl, NSMapTable<NSNumber, ActionBlockWrapperInteface>>(keyOptions: .weakMemory, valueOptions: .strongMemory)

public protocol UIControlClosureActionable: UIControl { } //Forward conform

extension UIControlClosureActionable {
    
    public func setBlock(block: @escaping (_ sender: Self) -> Void, forEvent event: Self.Event) {
        let mapTableKey = NSNumber(value: event.rawValue)
        let controlMapTable = eventHandlersMap.object(forKey: self) ?? NSMapTable(keyOptions: .strongMemory, valueOptions: .strongMemory)
        let wrapper = ActionBlockWrapper<Self>(block: block)
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
