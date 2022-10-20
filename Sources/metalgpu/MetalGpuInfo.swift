//
//  MetalGpuInfo.swift
//  metalgpu
//
//  Created by Alex Zenla on 11/15/21.
//

import Collections
import Foundation
import Metal

struct MetalGpuInfo: Codable {
    let index: Int?
    let name: String
    let registryID: UInt64
    let location: Location
    let characteristics: [Characteristic]
    let features: [Feature]
    let families: [String]
    let maxTransferRateBytesPerSecond: UInt64?
    let recommendedMaxMemorySizeBytes: UInt64?
    let maxBufferLengthInBytes: UInt64?
    let maxThreadGroupMemorySize: UInt64?
    let sparseTileSizeInBytes: UInt64?
    let maxThreadsPerThreadGroup: Size

    enum Location: String, Codable {
        case builtIn = "Built-in"
        case external = "External"
        case slot = "Slot"
        case unspecified = "Unspecified"
    }

    enum Characteristic: String, Codable {
        case lowPower = "Low Power"
        case headless = "Headless"
        case removable = "Removable"
        case unifiedMemory = "Unified Memory"
    }

    enum FeatureKey: String, Codable {
        case rayTracing = "Ray Tracing"
        case msaa32Bit = "32-Bit MSAA"
        case dynamicLibraries = "Dynamic Libraries"
        case functionPointers = "Function Pointers"
        case queryTextureLOD = "Query Texture LOD"
        case floatFiltering32Bit = "32-Bit Float Filtering"
        case pullModelInterpolation = "Pull Model Interpolation"
        case bcTextureCompression = "BC Texture Compression"
        case shaderBarycentricCoordinates = "Shader Barycentric Coordinates"
        case barycentricCoordinates = "Barycentric Coordinates"
        case rasterOrderGroups = "Raster Order Groups"
        case programmableSamplePosition = "Programmable Sample Position"
        case primitiveMotionBlur = "Primitive Motion Blur"
        case renderDynamicLibraries = "Render Dynamic Libraries"
        case depth24Stencil8PixelFormat = "Depth 24 Stencil 8 Pixel Format"
    }

    struct Feature: Codable {
        let name: String
        let supported: Bool

        public init(name: String, supported: Bool) {
            self.name = name
            self.supported = supported
        }
    }

    struct Size: Codable {
        let width: Int
        let height: Int
        let depth: Int
    }
}

@available(macOS 10.15, *)
extension MTLDeviceLocation {
    func asMetalGpuLocation() -> MetalGpuInfo.Location {
        switch self {
        case .builtIn: return .builtIn
        case .external: return .external
        case .slot: return .slot
        case .unspecified: return .unspecified
        @unknown default:
            fatalError("Unknown GPU Location")
        }
    }
}

extension MTLDevice {
    func collectMetalGpuInfo(_ index: Int? = nil) -> MetalGpuInfo {
        var recommendedMaxMemorySize: UInt64?
        if #available(macOS 10.12, *) {
            recommendedMaxMemorySize = self.recommendedMaxWorkingSetSize
        }

        var registryID: UInt64 = 0
        var maxThreadGroupMemorySize: UInt64?
        if #available(macOS 10.13, *) {
            registryID = self.registryID
            maxThreadGroupMemorySize = UInt64(self.maxThreadgroupMemoryLength)
        }

        var maxBufferMemorySize: UInt64?
        if #available(macOS 10.14, *) {
            maxBufferMemorySize = UInt64(self.maxBufferLength)
        }

        var location: MetalGpuInfo.Location = .unspecified
        var maxTransferRate: UInt64?
        if #available(macOS 10.15, *) {
            location = self.location.asMetalGpuLocation()

            if location != .builtIn {
                maxTransferRate = self.maxTransferRate
            }
        }

        var sparseTileSizeInBytes: UInt64?
        if #available(macOS 11.0, *) {
            sparseTileSizeInBytes = UInt64(self.sparseTileSizeInBytes)
        }

        return MetalGpuInfo(
            index: index,
            name: name,
            registryID: registryID,
            location: location,
            characteristics: collectGpuCharacteristics(),
            features: collectGpuFeatures().map {
                MetalGpuInfo.Feature(
                    name: $0.key.rawValue,
                    supported: $0.value
                )
            }.sorted {
                $0.name.compare($1.name) == .orderedAscending
            },
            families: collectGpuFamilies(),
            maxTransferRateBytesPerSecond: maxTransferRate,
            recommendedMaxMemorySizeBytes: recommendedMaxMemorySize,
            maxBufferLengthInBytes: maxBufferMemorySize,
            maxThreadGroupMemorySize: maxThreadGroupMemorySize,
            sparseTileSizeInBytes: sparseTileSizeInBytes,
            maxThreadsPerThreadGroup: maxThreadsPerThreadgroup.asMetalGpuSize()
        )
    }

    func collectGpuFeatures() -> [MetalGpuInfo.FeatureKey: Bool] {
        var features: [MetalGpuInfo.FeatureKey: Bool] = [:]

        features[.depth24Stencil8PixelFormat] = isDepth24Stencil8PixelFormatSupported

        if #available(macOS 10.13, *) {
            features[.rasterOrderGroups] = areRasterOrderGroupsSupported
            features[.programmableSamplePosition] = areProgrammableSamplePositionsSupported
        }

        if #available(macOS 10.15, *) {
            features[.shaderBarycentricCoordinates] = supportsShaderBarycentricCoordinates
            features[.barycentricCoordinates] = areBarycentricCoordsSupported
        }

        if #available(macOS 11.0, *) {
            features[.pullModelInterpolation] = supportsPullModelInterpolation
            features[.bcTextureCompression] = supportsBCTextureCompression
            features[.floatFiltering32Bit] = supports32BitFloatFiltering
            features[.queryTextureLOD] = supportsQueryTextureLOD
            features[.functionPointers] = supportsFunctionPointers
            features[.dynamicLibraries] = supportsDynamicLibraries
            features[.msaa32Bit] = supports32BitMSAA
            features[.primitiveMotionBlur] = supportsPrimitiveMotionBlur
        }

        return features
    }

    func collectGpuCharacteristics() -> [MetalGpuInfo.Characteristic] {
        var characteristics: [MetalGpuInfo.Characteristic] = []
        if isLowPower {
            characteristics.append(.lowPower)
        }

        if isHeadless {
            characteristics.append(.headless)
        }

        if #available(macOS 10.13, *) {
            if isRemovable {
                characteristics.append(.removable)
            }
        }

        if #available(macOS 10.15, *) {
            if hasUnifiedMemory {
                characteristics.append(.unifiedMemory)
            }
        }
        return characteristics
    }

    func collectGpuFamilies() -> [String] {
        if #available(macOS 10.15, *) {
            let families: OrderedDictionary<MTLGPUFamily, String> = [
                .apple1: "Apple1",
                .apple2: "Apple2",
                .apple3: "Apple3",
                .apple4: "Apple4",
                .apple5: "Apple5",
                .apple6: "Apple6",
                .apple7: "Apple7",
                .common1: "Common1",
                .common2: "Common2",
                .common3: "Common3",
                .mac1: "Mac1",
                .mac2: "Mac2",
                .macCatalyst1: "MacCatalyst1",
                .macCatalyst2: "MacCatalyst2"
            ]

            var supportedFamilies: [String] = []
            for (family, text) in families {
                if supportsFamily(family) {
                    supportedFamilies.append(text)
                }
            }
            return supportedFamilies
        } else {
            return []
        }
    }
}

extension MTLSize {
    func asMetalGpuSize() -> MetalGpuInfo.Size {
        MetalGpuInfo.Size(
            width: width,
            height: height,
            depth: depth
        )
    }
}
