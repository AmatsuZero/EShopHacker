//
//  TitleMap.swift
//  EShopHelper
//
//  Created by Jiang,Zhenhua on 2018/7/27.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation
import SpriteKit

class TileMap: SKNode {
    struct LayerAttribute: OptionSet {
        let rawValue: Int
        
        static let none = LayerAttribute(rawValue: 1 << 0)
        static let base64 = LayerAttribute(rawValue: 1 << 1)
        static let gzip = LayerAttribute(rawValue: 1 << 2)
        static let zlib = LayerAttribute(rawValue: 1 << 3)
        
        static let all: LayerAttribute = [.none, .base64, .gzip, .zlib]
    }
    
    enum PropertyType: Int {
        case none = 0, map, layer, ObjectGroup, object, tile, imageLayer
    }
    
    enum OrientationStyle: UInt {
        case isometric, orthogonal
    }
    
    struct TileFlags: OptionSet {
        let rawValue: Int
        
        static let diagonal = TileFlags(rawValue: 0x20000000)
        static let vertical = TileFlags(rawValue: 0x40000000)
        static let horizontal = TileFlags(rawValue: 0x80000000)
        
        static let all: TileFlags = [.diagonal, .vertical, .horizontal]
        static let mask: TileFlags = []
    }
    
    @objc(EHHTilesetInfo) class TilesetInfo: NSObject, NSCoding {
        
        private(set) var name: String = ""
        private(set) var firstGid: UInt8 = 0
        private(set) var tileSize = CGSize.zero
        private(set) var unitTileSize = CGSize.zero
        private(set) var spacing: CGFloat = 0
        private(set) var margin: CGFloat = 0
        var sourcceImage: String = "" {
            didSet {
                if let atlas = UIImage(contentsOfFile: sourcceImage) {
                    imageSize = atlas.size
                }
                atlasTexture = SKTexture(imageNamed: sourcceImage)
                unitTileSize = CGSize(width: tileSize.width / imageSize.width,
                                      height: tileSize.height / imageSize.height)
                atlasTilesPerRow = (Int(imageSize.width) - Int(margin * 2 + spacing)) / (Int(tileSize.width) + Int(spacing))
                atlasTilesPerCol = (Int(imageSize.height) - Int(margin * 2 + spacing)) / (Int(tileSize.height) + Int(spacing))
            }
        }
        private(set) var imageSize = CGSize.zero
        private(set) var atlasTilesPerRow = 0
        private(set) var atlasTilesPerCol = 0
        private(set) var atlasTexture: SKTexture?
        
        private var textureCache = [UInt8: SKTexture]()
        
        init(gid: UInt8, attributes: [String: Any]) {
            name = attributes["name"] as? String ?? ""
            firstGid = gid
            spacing = attributes["spacing"] as? CGFloat ?? 0
            margin = attributes["margin"] as? CGFloat ?? 0
            tileSize = CGSize(width: attributes["tilewidth"] as? CGFloat ?? 0,
                              height: attributes["tileheight"] as? CGFloat ?? 0)
            super.init()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init()
            name = aDecoder.decodeObject(forKey: "TilesetName") as? String ?? ""
            firstGid = UInt8(aDecoder.decodeInteger(forKey: "TilesetFirstGid"))
            tileSize = aDecoder.decodeCGSize(forKey: "TilesetTileSize")
            unitTileSize = aDecoder.decodeCGSize(forKey: "TilesetUnitTileSize")
            imageSize = aDecoder.decodeCGSize(forKey: "TilesetImageSize")
            spacing = CGFloat(aDecoder.decodeFloat(forKey: "TilesetSpacing"))
            margin = CGFloat(aDecoder.decodeFloat(forKey: "TilesetMargin"))
            sourcceImage = aDecoder.decodeObject(forKey: "TilesetSourceImage") as? String ?? ""
            atlasTilesPerRow = aDecoder.decodeInteger(forKey: "TilesetTilesPerRow")
            atlasTilesPerCol = aDecoder.decodeInteger(forKey: "TilesetTilesPerCol")
            atlasTexture = aDecoder.decodeObject(forKey: "TilesetAtlasTexture") as? SKTexture
            if let cache = aDecoder.decodeObject(forKey: "TilesetTextureCache") as? [UInt8: SKTexture] {
                cache.forEach { textureCache[$0.key] = $0.value }
            }
        }
        
        func rowFromGid(gid: Int) -> Int {
            return gid / atlasTilesPerRow
        }
        
        func colFromGid(gid: Int) -> Int {
            return gid % atlasTilesPerRow
        }
        
        func textureForGid(gid: UInt8) -> SKTexture? {
            var g = gid & UInt8(TileMap.TileFlags.mask.rawValue)
            g -= firstGid
            guard let texture = textureCache[g] else {
                var r = (tileSize.height + CGFloat(spacing)) * CGFloat(rowFromGid(gid: Int(g))) + margin
                r /= imageSize.height
                let c = ((tileSize.width + CGFloat(spacing)) * CGFloat(colFromGid(gid: Int(g))) + margin) / imageSize.width
                r = 1 - r - unitTileSize.height
                let rect = CGRect(x: c, y: r, width: unitTileSize.width, height: unitTileSize.height)
                guard let atlas = atlasTexture else {
                    return nil
                }
                let texture = SKTexture(rect: rect, in: atlas)
                texture.usesMipmaps = true
                texture.filteringMode = .nearest
                textureCache[g] = texture
                return texture
            }
            return texture
        }
        
        func textureAtPoint(point: CGPoint) -> SKTexture? {
            guard let atlas = atlasTexture else {
                return nil
            }
            return SKTexture(rect: CGRect(x: point.x / atlas.size().width,
                                          y: 1 - ((point.y + tileSize.height) / atlas.size().height),
                                          width: unitTileSize.width,
                                          height: unitTileSize.height),
                             in: atlas)
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(name, forKey: "TilesetName")
            aCoder.encode(firstGid, forKey: "TilesetFirstGid")
            aCoder.encode(tileSize, forKey: "TilesetTileSize")
            aCoder.encode(unitTileSize, forKey: "TilesetUnitTileSize")
            aCoder.encode(imageSize, forKey: "TilesetImageSize")
            aCoder.encode(spacing, forKey: "TilesetSpacing")
            aCoder.encode(margin, forKey: "TilesetMargin")
            aCoder.encode(sourcceImage, forKey: "TilesetSourceImage")
            aCoder.encode(atlasTilesPerRow, forKey: "TilesetTilesPerRow")
            aCoder.encode(atlasTilesPerCol, forKey: "TilesetTilesPerCol")
            aCoder.encode(atlasTexture, forKey: "TilesetAtlasTexture")
            aCoder.encode(textureCache, forKey: "TilesetTextureCache")
        }
    }
    
    class Layer: SKNode {
        var layerInfo: LayerInfo?
        var tileInfo = Set<TilesetInfo>()
        var mapTileSize = CGSize.zero
        var layerWidth: CGFloat {
            guard let layerInfo = layerInfo else {
                return 0
            }
            return layerInfo.layerGridSize.width * mapTileSize.width
        }
        var layerHeight: CGFloat {
            guard let layerInfo = layerInfo else {
                return 0
            }
            return layerInfo.layerGridSize.height * mapTileSize.height
        }
        weak var map: TileMap?
        
        internal init(tilesets: [TilesetInfo], layerInfo: LayerInfo, mapInfo: TileMap) {
            super.init()
            self.layerInfo = layerInfo
            layerInfo.layer = self
            mapTileSize = mapInfo.tileSize
            alpha = layerInfo.opacity
            position = layerInfo.offset
            // recalc the offset if we are isometriic
            if mapInfo.orientation == .isometric {
                position = CGPoint(x: (mapTileSize.width / 2) * (position.x - position.y),
                                   y: (mapTileSize.height / 2) * (-position.x - position.y))
            }
            var layerNodes = [String: SKNode]()
            for col in 0..<Int(layerInfo.layerGridSize.width) {
                for row in 0..<Int(layerInfo.layerGridSize.height) {
                    // get the gID
                    let gID = layerInfo.tiles[col + Int(CGFloat(row) * layerInfo.layerGridSize.width)]
                    let flag = TileFlags(rawValue: Int(gID))
                    guard TileFlags.all.contains(flag) else { continue }
                    if let titesetInfo = mapInfo.tilesetInfo(for: gID) {
                        tileInfo.insert(titesetInfo)
                        let texture = titesetInfo.textureForGid(gid: gID)
                        let sprite = SKSpriteNode(texture: texture)
                        sprite.name = "\(Int(CGFloat(col) + CGFloat(row) * layerInfo.layerGridSize.width))"
                        if mapInfo.orientation == .isometric {
                            let x = (mapTileSize.width / 2) * (layerInfo.layerGridSize.width + CGFloat(col - row - 1))
                            let y = (mapTileSize.height / 2) * ((layerInfo.layerGridSize.height * 2 - CGFloat(col + row) - 2))
                            sprite.position = CGPoint(x: x, y: y)
                        } else {
                            let x = CGFloat(col) * mapTileSize.width + mapTileSize.width / 2.0
                            let y = mapInfo.mapSize.height * titesetInfo.tileSize.height - CGFloat(row + 1) * mapTileSize.height + mapTileSize.height / 2.0
                            sprite.position = CGPoint(x: x, y: y)
                        }
                        // flip sprites if necessary
                        if flag.contains(.diagonal) {
                            if flag.contains(.horizontal) {
                                sprite.zRotation = -.pi/2
                            } else if flag.contains(.vertical) {
                                sprite.zRotation = .pi/2
                            }
                        } else {
                            if flag.contains(.vertical) {
                                sprite.yScale *= -1
                            }
                            if flag.contains(.horizontal) {
                                sprite.xScale *= -1
                            }
                        }
                        // add sprite to correct node for this tileset
                        let layerNode = layerNodes[titesetInfo.name] ?? {
                            let node = SKNode()
                            layerNodes[titesetInfo.name] = node
                            return node
                        }()
                        layerNode.addChild(sprite)
                    }
                }
            }
            for layerNode in layerNodes.values where !layerNode.children.isEmpty {
                addChild(layerNode)
            }
            calculateAccumulatedFrame()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            layerInfo = aDecoder.decodeObject(forKey: "LayerLayerInfo") as? LayerInfo
            if let set = aDecoder.decodeObject(forKey: "LayerTileInfo") as? Set<TilesetInfo> {
                set.forEach { tileInfo.insert($0) }
            }
            mapTileSize = aDecoder.decodeCGSize(forKey: "LayerTileSize")
            map = aDecoder.decodeObject(forKey: "LayerMap") as? TileMap
        }
        
        var properties: [String: Any]? {
            return layerInfo?.properties
        }
        
        func point(for coord: CGPoint) -> CGPoint {
            return CGPoint(x: coord.x * mapTileSize.width + mapTileSize.width / 2,
                           y: layerHeight - (coord.y * mapTileSize.height + mapTileSize.height / 2))
        }
        
        func coord(for point: CGPoint) -> CGPoint {
            let inPoint = CGPoint(x: point.x, y: layerHeight - point.y)
            return CGPoint(x: inPoint.x / mapTileSize.height,
                           y: inPoint.y / mapTileSize.width)
        }
        
        func removeTile(at coord: CGPoint)  {
            guard layerInfo?.tileGid(at: coord) != nil, let layerInfo = layerInfo else { return }
            let z = coord.x + coord.y * layerInfo.layerGridSize.width
            // remove tile from GID map
            layerInfo.tiles[Int(z)] = 0
            if let node = childNode(withName: "//\(Int(coord.x + coord.y * layerInfo.layerGridSize.width))") {
                node.removeFromParent()
            }
        }
        
        func tile(at point: CGPoint) -> SKSpriteNode? {
            return tileAt(coord(for: point))
        }
        
        func tileAt(_ coord: CGPoint) -> SKSpriteNode? {
            let nodeName = "*/\(Int(coord.x + coord.y * (layerInfo?.layerGridSize.width ?? 0)))"
            return childNode(withName: nodeName) as? SKSpriteNode
        }
        
        func tileGid(at point: CGPoint) -> UInt8 {
            guard let layerInfo = layerInfo else {
                return 0
            }
            // get index
            let pt = coord(for: point)
            let idx = pt.x + pt.y * layerInfo.layerGridSize.width
            
            // bounds check, invalid GID if out of bounds
            guard idx <= layerInfo.layerGridSize.width * layerInfo.layerGridSize.height,
                idx >= 0 else {
                return 0
            }
            return layerInfo.tiles[Int(idx)]
        }
        
        func property(with name: String) -> Any? {
            return properties?[name]
        }
        
        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(layerInfo, forKey: "LayerLayerInfo")
            aCoder.encode(tileInfo, forKey: "LayerTileInfo")
            aCoder.encode(mapTileSize, forKey: "LayerTileSiz")
            aCoder.encode(map, forKey: "LayerMap")
        }
    }
    
    @objc(EHHLayerInfo) class LayerInfo: NSObject, NSCoding {
        var name = ""
        var layerGridSize = CGSize.zero
        var tiles = [UInt8]()
        var isVisible = false
        var opacity: CGFloat = 0
        var minGID: UInt8 = 0
        var maxGID: UInt8 = 0
        private(set) var properties = [String: Any]()
        var offset = CGPoint.zero
        weak var layer: Layer?
        
        internal var zOrderCount = 0
        
        required init?(coder aDecoder: NSCoder) {
            super.init()
            name = aDecoder.decodeObject(forKey: "LayerInfoName") as? String ?? ""
            layerGridSize = aDecoder.decodeCGSize(forKey: "LayerInfoGridSize")
            if let data = aDecoder.decodeObject(forKey: "LayerInfoGridSize") as? Data {
                tiles += Array<UInt8>(data)
            }
            isVisible = aDecoder.decodeBool(forKey: "LayerInfoVisible")
            opacity = CGFloat(aDecoder.decodeFloat(forKey: "LayerInfoOpacity"))
            minGID = UInt8(aDecoder.decodeInteger(forKey: "LayerInfoMinGid"))
            maxGID = UInt8(aDecoder.decodeInteger(forKey: "LayerInfoMaxGid"))
            if let prop = aDecoder.decodeObject(forKey: "LayerInfoProperties") as? [String: Any] {
                prop.forEach { properties[$0.key] = $0.value }
            }
            offset = aDecoder.decodeCGPoint(forKey: "LayerInfoOffset")
            layer = aDecoder.decodeObject(forKey: "LayerInfoLayer") as? TileMap.Layer
            zOrderCount = aDecoder.decodeInteger(forKey: "LayerInfoZOrderCount")
        }
        
        func tileGid(at coord: CGPoint) -> UInt8 {
            let idx = coord.x + coord.y * layerGridSize.width
            assert(idx < (layerGridSize.width * layerGridSize.height), "index out of bounds!")
            return tiles[Int(idx)]
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(name, forKey: "LayerInfoName")
            aCoder.encode(layerGridSize, forKey: "LayerInfoGridSize")
            aCoder.encode(Data(bytes: tiles), forKey: "LayerInfoTiles")
            aCoder.encode(isVisible, forKey: "LayerInfoVisible")
            aCoder.encode(opacity, forKey: "LayerInfoOpacity")
            aCoder.encode(minGID, forKey: "LayerInfoMinGid")
            aCoder.encode(maxGID, forKey: "LayerInfoMaxGid")
            aCoder.encode(properties, forKey: "LayerInfoProperties")
            aCoder.encode(offset, forKey: "LayerInfoOffset")
            aCoder.encode(layer, forKey: "LayerInfoLayer")
            aCoder.encode(zOrderCount, forKey: "LayerInfoZOrderCount")
        }
    }
    
    @objc(EHHImageLayer) class ImageLayer: NSObject, NSCoding {
        var name = ""
        var properties = [String: Any]()
        var imageSource = ""
        
        internal var zOrderCount = 0
        
        required init?(coder aDecoder: NSCoder) {
            super.init()
            name = aDecoder.decodeObject(forKey: "ImageLayerName") as? String ?? ""
            imageSource = aDecoder.decodeObject(forKey: "ImageLayerSource") as? String ?? ""
            if let props = aDecoder.decodeObject(forKey: "ImageLayerProperties") as? [String: Any] {
                props.forEach { properties[$0.key] = $0.value }
            }
            zOrderCount = aDecoder.decodeInteger(forKey: "ImageLayerZOrderCount")
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(name, forKey: "ImageLayerName")
            aCoder.encode(imageSource, forKey: "ImageLayerSource")
            aCoder.encode(properties, forKey: "ImageLayerProperties")
            aCoder.encode(zOrderCount, forKey: "ImageLayerZOrderCount")
        }
    }
    
    @objc(EHHObjectGroup) class ObjectGroup: NSObject, NSCoding {
        var groupName = ""
        var positionOffset = CGPoint.zero
        var objects = [[String: Any]]()
        var properties = [String: Any]()
        
        internal var zOrderCount = 0
        
        required init?(coder aDecoder: NSCoder) {
            super.init()
            groupName = aDecoder.decodeObject(forKey: "ObjectGroupName") as? String ?? ""
            positionOffset = aDecoder.decodeCGPoint(forKey: "ObjectGroupPosOffset")
            if let objs = aDecoder.decodeObject(forKey: "ObjectGroupObjects") as? [[String: Any]] {
                objects += objs
            }
            if let props = aDecoder.decodeObject(forKey: "ObjectGroupProperties") as? [String: Any] {
                props.forEach { properties[$0.key] = $0.value }
            }
            zOrderCount = aDecoder.decodeInteger(forKey: "ObjectGroupZOrderCount")
        }
        
        func object(name: String) -> [String: Any]? {
            return objects(name: name).first
        }
        
        func objects(name: String) -> [[String: Any]] {
            return objects.filter {
                guard let n = $0["name"] as? String else {
                    return false
                }
                return n == name
            }
        }
        
        func propertyName(name: String) -> Any? {
            return self.properties[name]
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(groupName, forKey: "ObjectGroupName")
            aCoder.encode(positionOffset, forKey: "ObjectGroupPosOffset")
            aCoder.encode(objects, forKey: "ObjectGroupObjects")
            aCoder.encode(properties, forKey: "ObjectGroupProperties")
            aCoder.encode(zOrderCount, forKey: "ObjectGroupZOrderCount")
        }
    }
    
    var mapSize = CGSize.zero
    var tileSize = CGSize.zero
    var parentElement = PropertyType.none
    var parentGID = 0
    var orientation = OrientationStyle.isometric
    private(set) var minZPositioning: CGFloat = 0
    private(set) var maxZPositioning: CGFloat = 0
    
    var fileName = ""
    var resources = ""
    var tilesets = [TilesetInfo]()
    private(set) var tileProperties = [String : [String: Any]]()
    private(set) var properties = [String: Any]()
    private(set) var layers = [LayerInfo]()
    var imageLayers = [ImageLayer]()
    var objectGroups = [ObjectGroup]()
    var gidData = [Data]()
    
    private var currentString = ""
    private var storingCharacters = false
    private var currentFirstGID = 0
    private var layerAttribute = LayerAttribute.none
    private var zOrderCount = 1
    
    convenience init?(mapName: String) {
        self.init(name: mapName, baseZPosition: 0, zOrderModifier: -20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mapSize = aDecoder.decodeCGSize(forKey: "TileMapMapSize")
        tileSize = aDecoder.decodeCGSize(forKey: "TileMapTileSize")
        parentElement = PropertyType(rawValue: aDecoder.decodeInteger(forKey: "TileMapParentElement")) ?? .none
        parentGID = aDecoder.decodeInteger(forKey: "TileMapParentGid")
        orientation = OrientationStyle(rawValue: UInt(aDecoder.decodeInteger(forKey: "TileMapOrientatio"))) ?? .isometric
        fileName = aDecoder.decodeObject(forKey: "TileMapFilename") as? String ?? ""
        resources = aDecoder.decodeObject(forKey: "TileMapResources") as? String ?? ""
        tilesets = aDecoder.decodeObject(forKey: "TileMapTilesets") as? [TilesetInfo] ?? []
        tileProperties = aDecoder.decodeObject(forKey: "TileMapTileProperties") as? [String: [String: Any]] ?? [:]
        properties = aDecoder.decodeObject(forKey: "TileMapProperties") as? [String : Any] ?? [:]
        layers = aDecoder.decodeObject(forKey: "TileMapLayers") as? [LayerInfo] ?? []
        objectGroups = aDecoder.decodeObject(forKey: "TileMapObjectGroups") as? [ObjectGroup] ?? []
        gidData = aDecoder.decodeObject(forKey: "TileMapGidData") as? [Data] ?? []
        imageLayers = aDecoder.decodeObject(forKey: "TileMapImageLayers") as? [ImageLayer] ?? []
        zOrderCount = aDecoder.decodeInteger(forKey: "TileMapZOrderCount")
        
        // parsing variables -- not sure they need to be coded, but just in case
        currentString = aDecoder.decodeObject(forKey: "TileMapCurrentString") as? String ?? ""
        storingCharacters = aDecoder.decodeBool(forKey: "TileMapStoringChars")
        currentFirstGID = aDecoder.decodeInteger(forKey: "TileMapCurrentFirstGid")
        layerAttribute = LayerAttribute(rawValue: aDecoder.decodeInteger(forKey: "TileMapLayerAttributes"))
    }
    
    init?(name mapName: String, baseZPosition: CGFloat, zOrderModifier: CGFloat) {
        // create the map
        super.init()
        // get the TMX map filename
        var extensionName = ""
        var name = mapName
        if mapName.range(of: ".") != nil {
            extensionName = (mapName as NSString).pathExtension
            name = (mapName as NSString).deletingPathExtension
        }
        // load the TMX map from disk
        guard let path = Bundle.main.path(forResource: name as String, ofType: extensionName),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
           return nil
        }
        // set the filename
        fileName = path
        // parse the map
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        guard parser.parse() else {
            return nil
        }
        if baseZPosition < baseZPosition + (zOrderModifier * CGFloat(zOrderCount + 1)) {
            minZPositioning = baseZPosition
            maxZPositioning = baseZPosition + (zOrderModifier * CGFloat(zOrderCount + 1))
        } else {
            maxZPositioning = baseZPosition
            minZPositioning = baseZPosition + (zOrderModifier * CGFloat(zOrderCount + 1))
        }
        // now actually using the data begins.
        // add layers
        for layerInfo in layers where layerInfo.isVisible {
            let child = Layer(tilesets: tilesets, layerInfo: layerInfo, mapInfo: self)
            child.zPosition = baseZPosition + CGFloat(zOrderCount - layerInfo.zOrderCount) * zOrderModifier
            addChild(child)
        }
        // add tile objects
        for objectGroup in objectGroups {
            for obj in objectGroup.objects where obj["gid"] != nil {
                if let gid = obj["gid"] as? UInt8, let tileset = tilesetInfo(for: gid) {
                    let x = obj["x"] as? CGFloat ?? 0
                    let y = obj["y"] as? CGFloat ?? 0
                    var pt = CGPoint.zero
                    if orientation == .isometric {
                        //#warning these appear to be incorrect for iso maps when used for tile objects!
                        // Unsure why the math is different between objects and regular tiles.
                        let coords = toPosition(for: .init(x: x, y: y))
                        pt.x = (tileSize.width / 2) * (tileSize.width + coords.x - coords.y - 1)
                        pt.y = (tileSize.height / 2) * ((tileSize.height * 2 - coords.x - coords.y) - 2)
                    } else {
                        //  NOTE:
                        //    iso zPositioning may not work as expected for maps with irregular tile sizes.  For larger tiles (i.e. a box in front of some floor
                        //    tiles) We would need each layer to have their tiles ordered lower at the bottom coords and higher at the top coords WITHIN THE LAYER, in
                        //    addition to the layers being offset as described below. this could potentially be a lot larger than 20 as a default and may take some
                        //    thinking to fix.
                        pt.x = x + tileSize.width / 2
                        pt.y = y + tileSize.height / 2
                    }
                    let texture = tileset.textureForGid(gid: gid - tileset.firstGid + 1)
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.position = pt
                    sprite.zPosition = baseZPosition + CGFloat(zOrderCount - objectGroup.zOrderCount) * zOrderModifier
                    addChild(sprite)
                    //#warning This needs to be optimized into tilemap layers like our regular layers above for performance reasons.
                    // this could be problematic...  what if a single object group had a bunch of tiles from different tilemaps?  Would this cause zOrder problems if we're adding them all to tilemap layers?
                }
            }
        }
        // add image layers
        imageLayers.map { imageLayer in
            let image = SKSpriteNode(imageNamed: imageLayer.imageSource)
            image.position = CGPoint(x: image.size.width / 2, y: image.size.height / 2)
            image.zPosition = baseZPosition + CGFloat(zOrderCount - imageLayer.zOrderCount) * zOrderModifier
            return image
        }.forEach { addChild($0) }
    }
    
    func layer(named: String) -> Layer? {
        for layerInfo in layers where layerInfo.name == name {
            return layerInfo.layer
        }
        return nil
    }
    
    func groupNamed(name: String) -> ObjectGroup? {
        for group in objectGroups where group.groupName == name {
            return group
        }
        return nil
    }
    
    func tilesetInfo(for gid: UInt8) -> TilesetInfo? {
        guard gid != 0 else {
            return nil
        }
        for tileset in tilesets {
            // check to see if the gID is in the info's atlas gID range.  If not, skip this one and go to the next.
            let lastPossibleGid = tileset.firstGid + UInt8(tileset.atlasTilesPerRow * tileset.atlasTilesPerCol) - 1
            if gid < tileset.firstGid || gid > lastPossibleGid {
                continue
            }
            return tileset
        }
        return nil
    }
    
    func properties(for gid: UInt8) -> [String: Any]? {
        return tileProperties["\(gid)"]
    }
    
    func toPosition(for coord: CGPoint) -> CGPoint {
        return CGPoint(x: coord.x / tileSize.width, y: coord.y / tileSize.height)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(mapSize, forKey: "TileMapMapSize")
        aCoder.encode(tileSize, forKey: "TileMapTileSize")
        aCoder.encode(parentElement.rawValue, forKey: "TileMapParentElement")
        aCoder.encode(parentGID, forKey: "TileMapParentGid")
        aCoder.encode(orientation.rawValue, forKey: "TileMapOrientation")
        aCoder.encode(fileName, forKey: "TileMapFilename")
        aCoder.encode(resources, forKey: "TileMapResources")
        aCoder.encode(tilesets, forKey: "TileMapTilesets")
        aCoder.encode(tileProperties, forKey: "TileMapTileProperties")
        aCoder.encode(properties, forKey: "TileMapProperties")
        aCoder.encode(layers, forKey: "TileMapLayers")
        aCoder.encode(imageLayers, forKey: "TileMapImageLayers")
        aCoder.encode(objectGroups, forKey: "TileMapObjectGroups")
        aCoder.encode(gidData, forKey: "TileMapGidData")
        aCoder.encode(zOrderCount, forKey: "TileMapZOrderCount")
        
        // parsing variables -- not sure they need to be coded, but just in case
        aCoder.encode(currentString, forKey: "TileMapCurrentString")
        aCoder.encode(storingCharacters, forKey: "TileMapStoringChars")
        aCoder.encode(currentFirstGID, forKey: "TileMapCurrentFirstGid")
        aCoder.encode(layerAttribute.rawValue, forKey: "TileMapLayerAttributes")
    }
}

extension TileMap: XMLParserDelegate {
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        var len: Int = 0
        switch elementName {
        case "data":
            storingCharacters = false
            let layer = layers.last
            if layerAttribute.contains(.base64) {
                // clean whitespace from string
                currentString = currentString.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let buffer = Data(base64Encoded: currentString), !buffer.isEmpty else {
                    parser.abortParsing()
                    return
                }
                len = buffer.count
            } else if layerAttribute.contains(.gzip) || layerAttribute.contains(.zlib) {
                let s = layer?.layerGridSize
            }
        default:
            break
        }
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if storingCharacters {
            currentString += string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error on XML Parse: \(parseError.localizedDescription)")
    }
}
