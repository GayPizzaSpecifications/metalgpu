//
//  MetalGpuTool.swift
//  metalgpu
//
//  Created by Alex Zenla on 10/29/21.
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

    @Flag(name: [.customShort("j"), .customLong("json")], help: "Enable JSON Output")
    var json: Bool = false

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

        let metalGpuInfos: [MetalGpuInfo] = gpus.enumerated().map {
            $0.element.collectMetalGpuInfo($0.offset)
        }

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encoded = try encoder.encode(metalGpuInfos)
            print(String(data: encoded, encoding: .utf8)!)
        } else {
            for gpu in metalGpuInfos {
                printGpuInfo(gpu)
                if gpu.index != gpus.count - 1 {
                    print()
                }
            }
        }
    }

    func printGpuInfo(_ info: MetalGpuInfo) {
        let features = info.features.sorted {
            $0.name.compare($1.name) == .orderedAscending
        }

        if let index = info.index {
            print("Index: \(index)")
        }

        print("  Name: \(info.name)")
        print("  Registry ID: \(info.registryID)")
        print("  Location: \(info.location.rawValue)")
        print("  Characteristics: \(joinedOrEmpty(info.characteristics.map(\.rawValue), "(None)"))")
        print("  Features:")
        for feature in features {
            print("    \(feature.name): \(feature.supported ? "Supported" : "Unsupported")")
        }

        print("  Families:")
        for family in info.families {
            print("    \(family)")
        }

        if let maxTransferRateBytesPerSecond = info.maxTransferRateBytesPerSecond {
            print("  Max Transfer Rate: \(byteCountString(Int64(maxTransferRateBytesPerSecond)))/sec")
        }

        if let recommendedMaxMemorySizeBytes = info.recommendedMaxMemorySizeBytes {
            print("  Recommended Maximum Memory Size: \(byteCountString(Int64(recommendedMaxMemorySizeBytes)))")
        }

        if let maxBufferLengthInBytes = info.maxBufferLengthInBytes {
            print("  Max Buffer Length: \(byteCountString(Int64(maxBufferLengthInBytes)))")
        }

        print("  Max Threads per Thread Group: \(sizeToString(info.maxThreadsPerThreadGroup))")

        if let maxThreadGroupMemorySize = info.maxThreadGroupMemorySize {
            print("  Max Thread Group Memory Size: \(byteCountString(Int64(maxThreadGroupMemorySize)))")
        }

        if let sparseTileSizeInBytes = info.sparseTileSizeInBytes {
            print("  Sparse Tile Size: \(byteCountString(Int64(sparseTileSizeInBytes)))")
        }

        if let maxSupportedVertexAmplification = info.maxSupportedVertexAmplification {
            print("  Max Vertex Amplification: \(maxSupportedVertexAmplification)")
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

    func sizeToString(_ value: MetalGpuInfo.Size) -> String {
        "(Width: \(value.width), Height: \(value.height), Depth: \(value.depth))"
    }

    struct DefaultDeviceNotFound: Error {}
}
