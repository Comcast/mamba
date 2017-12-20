//
//  HLSParser.swift
//  mamba
//
//  Created by David Coufal on 6/8/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC This software and its contents are
//  Comcast confidential and proprietary. It cannot be used, disclosed, or
//  distributed without Comcast's prior written permission. Modification of this
//  software is only allowed at the direction of Comcast Cable Communications Management, LLC All allowed
//  modifications must be provided to Comcast Cable Communications Management, LLC
//

import Foundation

/**
 A performant parser for HLS manifests.
 */
public final class HLSParser {
    
    internal fileprivate(set) var registeredTags = RegisteredHLSTags()
    
    /**
     Constructs a parser for HLS manifests.
     
     - parameter tagTypes: An optional array of `HLSTagDescriptor` Types that the caller
     would like this parser to parse. If you have custom tags that you'd like to easily
     identify and query on, the caller can construct their own `HLSTagDescriptor`-implementing
     object and pass in the type here.
     */
    public init(tagTypes:[HLSTagDescriptor.Type]? = nil) {
        if let tagTypes = tagTypes {
            for tagType in tagTypes {
                registerHLSTags(tagType: tagType)
            }
        }
    }
    
    /**
     Adds a HLSTagDescriptor to the registered tags list for this parser.
     
     It'w worth noting that manifest parsing proceeds with the registered tags that are
     present at the beginning of parsing.
     */
    func registerHLSTags(tagType: HLSTagDescriptor.Type) {
        registeredTags.register(tagDescriptorType: tagType)
    }
    
    /**
     Removes all registered tags from this parser, leaving only the built in PantosTag collection.
     
     It'w worth noting that manifest parsing proceeds with the registered tags that are
     present at the beginning of parsing.
     */
    func unRegisterAllHLSTags() {
        registeredTags.unRegisterAllHLSTagDescriptors()
    }
    
    /**
     Parses a HLS manifest into a `HLSManifest` structure for editing.
     
     - warning: this method, to improve performance, keeps references to the
     original `manifestData` in the final `HLSManifest` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSManifest` will keep a reference to the `manifestData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the manifest, the caller will get undefined behavior.
     
     - parameter manifestData: A `Data` object that represents a HLS manifest
     (typically from a web request)
     
     - parameter url: The URL of the original manifest.
     
     - parameter success: A closure callback called with a `HLSManifest`
     structure when the parse has sucessfully completed.
     
     - parameter failure: A closure callback called when the incoming HLS
     manifest had some structural problem that prevented us from parsing.
     */
    public func parse(manifestData data: Data,
                      url: URL,
                      success: @escaping HLSManifestParserSuccess,
                      failure: @escaping HLSManifestParserFailure) {
        
        parse(manifestData: data,
              customData: HLSManifestURLData(url: url),
              hlsManifestConstructor: constructHLSManifest,
              success: success,
              failure: failure)
    }
    
    /**
     Parses a HLS manifest into a `HLSManifest` structure for editing.
     
     - warning: this method, to improve performance, keeps references to the
     original `manifestData` in the final `HLSManifest` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSManifest` will keep a reference to the `manifestData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the manifest, the caller will get undefined behavior.
     
     - parameter manifestData: A `Data` object that represents a HLS manifest
     (typically from a web request)
     
     - parameter url: The URL of the original manifest. This is optional, but some
     manifest manipulations require it.
     
     - parameter timeout: The timeout in seconds. If the timeout is exceeded, an
     `HLSParserError` with the `timedOut` code will be thrown.
     
     - returns: A parsed `HLSManifest`.
     
     - throws: If the manifest cannot be parsed, throws an `HLSParserError`.
     */
    public func parse(manifestData data: Data, url: URL, timeout: Int = 1) throws -> HLSManifest {
        return try parse(manifestData: data,
                         customData: HLSManifestURLData(url: url),
                         hlsManifestConstructor: constructHLSManifest)
    }
    
    /**
     Generic parser for your concrete `HLSManifestCore` objects, if you need one. Most
     users will be using the built-in `HLSManifest` concrete object, so you probably
     don't need to use this method.
     
     - warning: this method, to improve performance, keeps references to the
     original `manifestData` in the final `HLSManifest` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSManifest` will keep a reference to the `manifestData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the manifest, the caller will get undefined behavior.
     
     - parameter manifestData: A `Data` object that represents a HLS manifest
     (typically from a web request)
     
     - parameter customData: Whatever custom data class you have defined for
     your concrete `HLSManifestCore` object.
     
     - parameter hlsManifestConstructor: A closure that can construct your
     concrete `HLSManifestCore` object from the `HLSTag` array, your custom
     data class, a RegisteredHLSTags object, and the manifestData. See
     the `constructHLSManifest` function for an example.
     
     - parameter success: A closure callback called with a concrete `HLSManifestCore`
     structure when the parse has sucessfully completed.
     
     - parameter failure: A closure callback called when the incoming HLS
     manifest had some structural problem that prevented us from parsing.
     */
    public func parse<D>(manifestData data: Data,
                         customData: D,
                         hlsManifestConstructor: @escaping ([HLSTag], D, RegisteredHLSTags, Data) -> HLSManifestCore<D>,
                         success: @escaping (HLSManifestCore<D>) -> (Swift.Void),
                         failure: @escaping HLSParserFailure) {
        
        let registeredTagsCopy = registeredTags
        
        let worker = HLSParseWorker(registeredTags: registeredTags,
                                    data: data,
                                    parser: self,
                                    success: { (tags) in
                                        let manifest = hlsManifestConstructor(tags, customData, registeredTagsCopy, data)
                                        success(manifest) },
                                    failure: failure)
        
        queue.sync {
            let _ = workers.insert(worker)
        }
        
        worker.startParse()
    }

    /**
     Generic parser for your concrete `HLSManifestCore` objects, if you need one. Most
     users will be using the built-in `HLSManifest` concrete object, so you probably
     don't need to use this method.
     
     - warning: this method, to improve performance, keeps references to the
     original `manifestData` in the final `HLSManifest` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSManifest` will keep a reference to the `manifestData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the manifest, the caller will get undefined behavior.
     
     - parameter manifestData: A `Data` object that represents a HLS manifest
     (typically from a web request)
     
     - parameter customData: Whatever custom data class you have defined for
     your concrete `HLSManifestCore` object.
     
     - parameter hlsManifestConstructor: A closure that can construct your
     concrete `HLSManifestCore` object from the `HLSTag` array, your custom
     data class, a RegisteredHLSTags object, and the manifestData. See
     the `constructHLSManifest` function for an example.
     
     - parameter timeout: The timeout in seconds. If the timeout is exceeded, an
     `HLSParserError` with the `timedOut` code will be thrown.
     
     - returns: A parsed concrete `HLSManifestCore`.
     
     - throws: If the manifest cannot be parsed, throws an `HLSParserError`.
     */
    public func parse<D>(manifestData data: Data,
                         customData: D,
                         hlsManifestConstructor: @escaping ([HLSTag], D, RegisteredHLSTags, Data) -> HLSManifestCore<D>,
                         timeout: Int = 1) throws -> HLSManifestCore<D> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var manifest: HLSManifestCore<D>?
        var error: HLSParserError?
        
        self.parse(manifestData: data,
                   customData: customData,
                   hlsManifestConstructor: hlsManifestConstructor,
                   success: { (newManifest) -> (Void) in
                    manifest = newManifest
                    semaphore.signal() },
                   failure: { (result) -> (Void) in
                    error = result
                    semaphore.signal() })
        
        if semaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout)) == .timedOut {
            throw HLSParserError.timedOut
        }
        
        if let error = error {
            throw error
        }
        
        guard let result = manifest else {
            assertionFailure("No error, but manifest was nil!")
            throw HLSParserError.unknown(description: "No error found, but no manifest was generated.")
        }
        
        return result
    }
    
    private var workers = Set<HLSParseWorker>()
    private let queue = DispatchQueue(label: "com.comcast.mamba.HLSParser", qos: .userInitiated)
    
    fileprivate func parseComplete(withWorker worker: HLSParseWorker) {
        queue.async {
            self.workers.remove(worker)
        }
    }
}

public typealias HLSManifestParserSuccess = (HLSManifest) -> (Swift.Void)
public typealias HLSManifestParserFailure = (HLSParserError) -> (Swift.Void)

public typealias HLSParserSuccess = ([HLSTag]) -> (Swift.Void)
public typealias HLSParserFailure = (HLSParserError) -> (Swift.Void)

private func constructHLSManifest(withTags tags: [HLSTag], customData: HLSManifestURLData, registeredHLSTags: RegisteredHLSTags, hlsData: Data) -> HLSManifest {
    return HLSManifest(tags: tags, registeredTags: registeredHLSTags, hlsData: hlsData, customData: customData)
}

fileprivate final class HLSParseWorker: NSObject, HLSRapidParserCallback {
    
    let fastParser = HLSRapidParser()
    var tags = [HLSTag]()
    let data: Data
    weak var parser: HLSParser?
    let registeredTags: RegisteredHLSTags
    var success: HLSParserSuccess
    var failure: HLSParserFailure
    
    init(registeredTags: RegisteredHLSTags,
         data: Data,
         parser: HLSParser,
         success: @escaping HLSParserSuccess,
         failure: @escaping HLSParserFailure) {
        
        self.data = data
        self.parser = parser
        self.registeredTags = registeredTags
        self.success = success
        self.failure = failure
    }
    
    func startParse() {
        fastParser.parseHLSData(self.data, callback: self)
    }

    // MARK: HLSRapidParserCallback
    
    func addedCommentLine(_ comment: HLSStringRef) {
        tags.append(HLSTag(tagDescriptor: PantosTag.Comment, tagData: comment))
    }
    
    func addedURLLine(_ url: HLSStringRef) {
        tags.append(HLSTag(tagDescriptor: PantosTag.Location, tagData: url))
    }
    
    func addedNoValueTag(withName tagName: HLSStringRef) {
        let descriptor = tagDescriptor(forTagName: tagName)
        guard descriptor != PantosTag.UnknownTag else {
            // special case handling for unknown tags
            tags.append(HLSTag(tagDescriptor: descriptor, tagData: HLSStringRef(), tagName: tagName))
            return
        }
        guard descriptor.type() == .noValue else {
            parseError = HLSParserError.mismatchBetweenTagDescriptorAndTagData(description:"The HLS Tag and the data contained within do not match: tagName:\"\(tagName.stringValue())\" tagValue:<no tag value> descriptor:\(descriptor)")
            return
        }
        tags.append(HLSTag(tagDescriptor: descriptor, tagData: HLSStringRef(), tagName: tagName))
    }
    
    func addedTag(withName tagName: HLSStringRef, value: HLSStringRef) {
        
        let descriptor = tagDescriptor(forTagName: tagName)
        guard descriptor.type() != .noValue else {
            parseError = HLSParserError.mismatchBetweenTagDescriptorAndTagData(description:"The HLS Tag and the data contained within do not match: tagName:\"\(tagName.stringValue())\" tagValue:\"\(value.stringValue())\" descriptor:\(descriptor)")
            return
        }
        
        guard descriptor != PantosTag.UnknownTag else {
            // special case handling for unknown tags
            tags.append(HLSTag(tagDescriptor: descriptor, tagData: value, tagName: tagName))
            return
        }
        
        guard let parsedValues = parseTags(tagValue: value, descriptor: descriptor) else {
            // the `parseTags` function already set a `parseError` error object for us
            return
        }
        
        tags.append(HLSTag(tagDescriptor: descriptor, tagData: value, tagName: tagName, parsedValues: parsedValues))
    }
    
    func addedEXTINFTag(withName tagName: HLSStringRef, duration: HLSStringRef, value: HLSStringRef) {
        tags.append(HLSTag(tagDescriptor: PantosTag.EXTINF, tagData: value, tagName: tagName, duration: duration.extinfSegmentDuration()))
    }
    
    func parseComplete() {
        if let error = parseError {
            parseFail(error: error)
        }
        else {
            if let lastTag = tags.last {
                if lastTag.tagDescriptor == PantosTag.EXTM3U {
                    tags.removeLast()
                }
            }
            tags = tags.reversed()
            
            parseSucceed(tags: tags)
        }
    }
    
    func parseError(_ error: String, errorNumber: UInt32) {
        var parsererror: HLSParserError
        switch Int(errorNumber) {
        case HLSParserInternalErrorCode.missingTagData.rawValue:
            parsererror = .missingTagData(description:error)
            break
        case HLSParserInternalErrorCode.missingTagDataForEXTINF.rawValue:
            parsererror = .missingTagDataForEXTINF(description:error)
            break
        default:
            assertionFailure("Found unknown error code \"\(errorNumber)\" with error string \"\(error)\" in parseError.HLSParseWorker")
            parsererror = .unknown(description:"\(errorNumber): \(error)")
            break
        }
        parseFail(error: parsererror)
    }
    
    // MARK: Parser Helpers
    
    private func parseFail(error: HLSParserError) {
        failure(error)
        parser?.parseComplete(withWorker: self)
    }
    
    private func parseSucceed(tags: [HLSTag]) {
        success(tags)
        parser?.parseComplete(withWorker: self)
    }
    
    private func parseTags(tagValue: HLSStringRef, descriptor: HLSTagDescriptor) -> HLSTagDictionary? {
        
        let parser = registeredTags.parser(forTag: descriptor)
        let tagBody = tagValue.stringValue()
        do {
            return try parser.parseTag(fromTagString: tagBody)
        }
        catch let error as HLSParserError {
            parseError = error
        }
        catch {
            parseError = HLSParserError.unknown(description:"Unknown error: \"\(error)\" while parsing tag \"\(descriptor.toString())\" with body \"\(String(describing: tagValue))\"")
        }
        return nil
    }
    
    private var parseError: HLSParserError? = nil
    
    private func tagDescriptor(forTagName name: HLSStringRef) -> HLSTagDescriptor {
        if let descriptor = registeredTags.tagDescriptor(fromStringRef: name) {
            return descriptor
        }
        return PantosTag.UnknownTag
    }
}
