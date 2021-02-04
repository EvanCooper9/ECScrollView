# ECScrollView

A SwiftUI ScrollView supporting offset & deceleration callbacks

## Installation
### SPM

```swift
.package(url: "https://github.com/EvanCooper9/ECScrollView", from: "1.0.0")
```

## Usage

Initialize like a regular `ScrollView`, and optionally handle offset changes & deceleration

```swift
import ECScrollView

ECScrollView() {
    // content ...
}
.onContentOffsetChanged { offset, size, proxy in
    // handle content offset
}
.didEndDecelerating { offset, proxy in
    // handle deceleration ending
}
```