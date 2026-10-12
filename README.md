# Elements Editor

A native macOS and Apple platform visual level designer and entity inspector for the **Elements** C++ primitives engine, built with **SwiftUI** and **Swift 5.9+ C++ Interoperability**.

## Features

- **Direct C++ Engine Interop:** Instantiates and manages C++ `Elements`, `Element` characters, and `IntMatrix` 2D grid structures without Objective-C wrappers.
- **Analogue Pocket & Game Boy Viewport:** 20 × 18 tile grid canvas matching the authentic Game Boy 160×144 resolution.
- **Entity Inspector:** Live manipulation of character attributes (`hitPoints`, speed, size, position) backed by the C++ core.
- **GB Studio Exporter:** Exports tilemaps and actor layouts directly to GB Studio 4.1 `.gbsres` scene files.

## Building & Running

```bash
swift build
swift run ElementsEditor
```
