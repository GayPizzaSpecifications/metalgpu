//
//  MetalGpuTool.swift
//  metalgpu
//
//  Created by Kenneth Endfinger on 10/29/21.
//

import ArgumentParser
import Foundation
import Metal

struct MetalGpuTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "metalgpu",
        abstract: "View Metal GPU Information"
    )

    @Flag(name: [.customShort("d"), .customLong("default")], help: "View Default GPU")
    var isDefaultOnly = false

    @Option(name: [.customShort("i"), .customLong("index")], help: "View GPU of Specified Index")
    var onlySelectedIndex: Int?

    func run() throws {
        var gpus: [MTLDevice] = []
        if isDefaultOnly {
            guard let gpu = MTLCreateSystemDefaultDevice() else {
                throw DefaultDeviceNotFound()
            }
            gpus.append(gpu)
        } else {
            gpus.append(contentsOf: MTLCopyAllDevices())
        }

        if let onlySelectedIndex = onlySelectedIndex {
            let gpu = gpus[onlySelectedIndex]
            gpus = [gpu]
        }

        for (index, gpu) in gpus.enumerated() {
            printGpuInfo(gpu, index: index)
            if index != gpus.count - 1 {
                print()
            }
        }
    }

    func printGpuInfo(_ gpu: MTLDevice, index: Int? = nil) {
        let characteristics = collectGpuCharacteristics(gpu)
        let features = collectFeatureSupport(gpu).sorted(by: {
            $0.key.compare($1.key) == .orderedAscending
        })

        if index != nil {
            print("Index: \(index!)")
        }

        print("  Name: \(gpu.name)")
        if #available(macOS 10.13, *) {
            print("  Registry ID: \(gpu.registryID)")
        }

        if #available(macOS 10.15, *) {
            print("  Location: \(locationAsString(gpu.location))")
        }
        print("  Characteristics: \(joinedOrEmpty(characteristics, "(None)"))")
        print("  Features:")
        for (name, supported) in features {
            print("    \(name): \(supported ? "Supported" : "Unsupported")")
        }

        if #available(macOS 10.15, *) {
            if gpu.location != .builtIn {
                print("  Max Transfer Rate: \(byteCountString(Int64(gpu.maxTransferRate)))/sec")
            }
        }

        if #available(macOS 10.12, *) {
            print("  Recommended Maximum Memory Size: \(byteCountString(Int64(gpu.recommendedMaxWorkingSetSize)))")
        }

        if #available(macOS 10.14, *) {
            print("  Max Buffer Length: \(byteCountString(Int64(gpu.maxBufferLength)))")
        }

        print("  Max Threads per Thread Group: \(sizeToString(gpu.maxThreadsPerThreadgroup))")

        if #available(macOS 10.13, *) {
            print("  Max Thread Group Memory Size: \(byteCountString(Int64(gpu.maxThreadgroupMemoryLength)))")
        }

        if #available(macOS 11.0, *) {
            print("  Sparse Tile Size: \(byteCountString(Int64(gpu.sparseTileSizeInBytes)))")
        }
    }

    func collectGpuCharacteristics(_ gpu: MTLDevice) -> [String] {
        var characteristics: [String] = []
        if gpu.isLowPower {
            characteristics.append("Low Power")
        }

        if gpu.isHeadless {
            characteristics.append("Headless")
        }

        if #available(macOS 10.13, *) {
            if gpu.isRemovable {
                characteristics.append("Removable")
            }
        }

        if #available(macOS 10.15, *) {
            if gpu.hasUnifiedMemory {
                characteristics.append("Unified Memory")
            }
        }
        return characteristics
    }

    func collectFeatureSupport(_ gpu: MTLDevice) -> [String: Bool] {
        var features: [String: Bool] = [:]
        if #available(macOS 11.0, *) {
            features["Ray Tracing"] = gpu.supportsRaytracing
        }

        if #available(macOS 11.0, *) {
            features["32-Bit MSAA"] = gpu.supports32BitMSAA
        }

        if #available(macOS 11.0, *) {
            features["Dynamic Libraries"] = gpu.supportsDynamicLibraries
        }

        if #available(macOS 11.0, *) {
            features["Function Pointers"] = gpu.supportsFunctionPointers
        }

        if #available(macOS 11.0, *) {
            features["Query Texture LOD"] = gpu.supportsQueryTextureLOD
        }

        if #available(macOS 11.0, *) {
            features["32-Bit Float Filtering"] = gpu.supports32BitFloatFiltering
        }

        if #available(macOS 11.0, *) {
            features["Pull Model Interopolation"] = gpu.supportsPullModelInterpolation
        }

        if #available(macOS 11.0, *) {
            features["BC Texture Compression"] = gpu.supportsBCTextureCompression
        }

        if #available(macOS 10.15, *) {
            features["Shader Barycentric Coordinates"] = gpu.supportsShaderBarycentricCoordinates
        }

        if #available(macOS 10.15, *) {
            features["Barycentric Coordinates"] = gpu.areBarycentricCoordsSupported
        }

        if #available(macOS 10.13, *) {
            features["Raster Order Groups"] = gpu.areRasterOrderGroupsSupported
        }

        if #available(macOS 10.13, *) {
            features["Programmable Sample Position"] = gpu.areProgrammableSamplePositionsSupported
        }
        return features
    }

    @available(macOS 10.15, *)
    func locationAsString(_ location: MTLDeviceLocation) -> String {
        switch location {
        case .builtIn: return "Built-in"
        case .external: return "External"
        case .slot: return "Slot"
        case .unspecified: return "Unspecified"
        @unknown default:
            fatalError("Unknown GPU Location")
        }
    }

    func joinedOrEmpty(_ items: [String], _ otherwise: String) -> String {
        if items.isEmpty {
            return otherwise
        } else {
            return items.joined(separator: ", ")
        }
    }

    func byteCountString(_ value: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: value, countStyle: .binary)
    }

    func sizeToString(_ value: MTLSize) -> String {
        "(Width: \(value.width), Height: \(value.height), Depth: \(value.depth))"
    }

    struct DefaultDeviceNotFound: Error {}
}
