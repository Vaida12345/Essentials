# ``Essentials``

Integrating the Foundation and Swift with Apple’s shipped frameworks.

## Overview

This package provides a collection of essential structures & extensions by highly integrating the Foundation and Swift with the shipped frameworks on Apple platforms.

## Getting Started

`Essentials` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://www.github.com/Vaida12345/Essentials", from: "1.0.1")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
https://www.github.com/Vaida12345/Essentials
```

## Topics

### Structures

- ``JSONParser``
- ``KeyChainManager``

### Error Handling

- ``GenericError``
- ``LocalizableError``
- ``AlertManager``
- ``TimeoutError``


### Auxiliary Structures
You do not usually interact with these structures directly

- <doc:Auxiliary>
