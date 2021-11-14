# metalgpu

[![macOS](https://github.com/kendfinger/metalgpu/actions/workflows/macos.yml/badge.svg)](https://github.com/kendfinger/metalgpu/actions/workflows/macos.yml)

View Metal GPU information from the command-line.

```
$ metalgpu
Index: 0
  Name: Apple M1 Max
  Registry ID: 4294969670
  Location: Built-in
  Characteristics: Unified Memory
  Features:
    BC Texture Compression: Supported
    32-Bit Float Filtering: Supported
    32-Bit MSAA: Supported
    Dynamic Libraries: Supported
    Ray Tracing: Supported
    Query Texture LOD: Supported
    Primitive Motion Blur: Supported
    Pull Model Interopolation: Supported
    Function Pointers: Supported
    Barycentric Coordinates: Supported
    Ray Tracing from Render: Supported
    Function Pointers from Render: Supported
  Recommended Maximum Memory Size: 42.67 GB
  Max Buffer Length: 32 GB
  Max Threads per Thread Group: (Width: 1024, Height: 1024, Depth: 1024)
  Max Thread Group Memory Size: 32 KB
  ```

## Usage

### Install With Mint

1. Install Mint: `brew install mint`
2. Install metalgpu with Mint: `mint install kendfinger/metalgpu@main`

### Run with SwiftPM

1. Clone the source: `git clone https://github.com/kendfinger/metalgpu.git metalgpu`
2. Switch to source directory: `cd metalgpu`
3. Run metalgpu with SwiftPM: `swift run metalgpu`
