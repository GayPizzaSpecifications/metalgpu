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
        let features = collectFeatureSupport(gpu)

        if index != nil {
            print("Index: \(index!)")
        }

        print("  Name: \(gpu.name)")
        print("  Registry ID: \(gpu.registryID)")
        print("  Location: \(locationAsString(gpu.location))")
        print("  Characteristics: \(joinedOrEmpty(characteristics, "(None)"))")
        print("  Features:")
        for (name, supported) in features.sorted(by: {
            $0.key.compare($1.key) == .orderedAscending
        }) {
            print("    \(name): \(supported ? "Supported" : "Unsupported")")
        }
        if gpu.location != .builtIn {
            print("  Max Transfer Rate: \(byteCountString(Int64(gpu.maxTransferRate)))/sec")
        }
        print("  Recommended Maximum Memory Size: \(byteCountString(Int64(gpu.recommendedMaxWorkingSetSize)))")
        print("  Max Buffer Length: \(byteCountString(Int64(gpu.maxBufferLength)))")
        print("  Max Threads per Thread Group: \(sizeToString(gpu.maxThreadsPerThreadgroup))")
        print("  Max Thread Group Memory Size: \(byteCountString(Int64(gpu.maxThreadgroupMemoryLength)))")
    }

    func collectGpuCharacteristics(_ gpu: MTLDevice) -> [String] {
        var characteristics: [String] = []
        if gpu.isLowPower {
            characteristics.append("Low Power")
        }

        if gpu.isHeadless {
            characteristics.append("Headless")
        }

        if gpu.isRemovable {
            characteristics.append("Removable")
        }

        if gpu.hasUnifiedMemory {
            characteristics.append("Unified Memory")
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
            features["Primitive Motion Blur"] = gpu.supportsPrimitiveMotionBlur
        }

        if #available(macOS 11.0, *) {
            features["Pull Model Interopolation"] = gpu.supportsPullModelInterpolation
        }

        if #available(macOS 11.0, *) {
            features["BC Texture Compression"] = gpu.supportsBCTextureCompression
        }

        if gpu.supportsShaderBarycentricCoordinates {
            features["Barycentric Coordinates"] = gpu.supportsShaderBarycentricCoordinates
        }

        return features
    }

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
