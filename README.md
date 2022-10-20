# metalgpu

[![GitHub Workflow](https://github.com/mysticlgbt/metalgpu/actions/workflows/macos.yml/badge.svg)](https://github.com/mysticlgbt/metalgpu/actions/workflows/macos.yml)
[![Latest Build](https://shields.io/badge/download-nightly-blue)](https://nightly.link/mysticlgbt/metalgpu/workflows/macos/main/metalgpu.zip)
[![Latest Release](https://shields.io/github/v/release/mysticlgbt/metalgpu?display_name=tag&sort=semver)](https://github.com/mysticlgbt/metalgpu/releases/latest)

View Metal GPU information from the command-line.

```
$ metalgpu
Index: 0
  Name: Apple M1 Max
  Registry ID: 4294969661
  Location: Built-in
  Characteristics: Unified Memory
  Features:
    32-Bit Float Filtering: Supported
    32-Bit MSAA: Supported
    BC Texture Compression: Supported
    Barycentric Coordinates: Supported
    Dynamic Libraries: Supported
    Function Pointers: Supported
    Programmable Sample Position: Supported
    Pull Model Interpolation: Supported
    Query Texture LOD: Supported
    Raster Order Groups: Supported
    Shader Barycentric Coordinates: Supported
  Recommended Maximum Memory Size: 42.67 GB
  Max Buffer Length: 32 GB
  Max Threads per Thread Group: (Width: 1024, Height: 1024, Depth: 1024)
  Max Thread Group Memory Size: 32 KB
  Sparse Tile Size: 16 KB
  ```

## Usage

### Install Latest with Homebrew

1. Install [Homebrew](https://brew.sh)
2. Install metalgpu with Homebrew: `brew install mysticlgbt/made/metalgpu`

### Install Nightly With Mint

1. Install Mint: `brew install mint`
2. Install metalgpu with Mint: `mint install mysticlgbt/metalgpu@main`

### Run with SwiftPM

1. Clone the source: `git clone https://github.com/mysticlgbt/metalgpu.git metalgpu`
2. Switch to source directory: `cd metalgpu`
3. Run metalgpu with SwiftPM: `swift run metalgpu`
