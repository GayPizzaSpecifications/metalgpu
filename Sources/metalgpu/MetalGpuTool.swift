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
    func run() throws {
        let gpus = MTLCopyAllDevices()

        for (index, gpu) in gpus.enumerated() {
            printGpuInfo(gpu, index: index)
            if index != gpus.count - 1 {
                print()
            }
        }
    }

    func printGpuInfo(_ gpu: MTLDevice, index: Int? = nil) {
        let characteristics = collectGpuCharacteristics(gpu)

        if index != nil {
            print("Index: \(index!)")
        }

        print("Name: \(gpu.name)")
        print("Location: \(locationAsString(gpu.location))")
        print("Characteristics: \(joinedOrEmpty(characteristics, "(None)"))")
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
}
