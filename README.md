# Library Documentation: Simplify Event Handling with Closures

## Overview

This library enhances the `UIControl` and `UIGestureRecognizer` classes by adding a `setBlock` function. This function allows developers to assign a closure that executes when the control or gesture recognizer triggers an event, streamlining event handling by eliminating the need for traditional target-action patterns or delegate methods.

## Features

- **Simplified Event Handling**: Attach closures directly to controls and gesture recognizers.
- **Enhanced Readability**: Write cleaner and more maintainable code.
- **Flexibility**: Easily manage events without extensive boilerplate code.
- **Compatibility**: Works with all subclasses of `UIControl` and `UIGestureRecognizer`.
- **Type Consistent**: sender's type is not lost inside of a block.


## Installation
#### Cocoapods
```podfile 
  pod 'UIControlBlocks', :git => 'git@github.com:Donny1995/UIControlBlocks.git'
```

## Usage

### Adding a Closure to a UIControl

Instead of using selectors and target-action patterns, you can directly assign a closure to a control.
```swift
  let customButton = UIButtonWithSomeExtraStuff()
  customButton.setBlock { [weak self] button in
      guard let self else { return }
      print(button is UIButtonWithSomeExtraStuff) //true

      // Your code here
  }
  ```
UIGestureRecognizer is handled the same way
