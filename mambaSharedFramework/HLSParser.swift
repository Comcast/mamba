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
import QuartzCore

/**
 A performant parser for HLS playlists.
 */
public final class HLSParser {
    
    internal fileprivate(set) var registeredTags = RegisteredHLSTags()
    internal let updateEventPlaylistParams: UpdateEventPlaylistParams
    
    /**
     Constructs a parser for HLS playlists.
     
     - parameter tagTypes: An optional array of `HLSTagDescriptor` Types that the caller
     would like this parser to parse. If you have custom tags that you'd like to easily
     identify and query on, the caller can construct their own `HLSTagDescriptor`-implementing
     object and pass in the type here.
     - parameter updateEventPlaylistParams: An optional struct with parameters for desired
     behavior when updating an Event style variant playlist. See `UpdateEventPlaylistParams`
     for details. If you are uncertain, the defaults are probably good. Mostly present for
     unit testing purposes.
     */
    public init(tagTypes:[HLSTagDescriptor.Type]? = nil,
                updateEventPlaylistParams: UpdateEventPlaylistParams = UpdateEventPlaylistParams()) {
        self.updateEventPlaylistParams = updateEventPlaylistParams
        if let tagTypes = tagTypes {
            for tagType in tagTypes {
                registerHLSTags(tagType: tagType)
            }
        }
    }
    
    /**
     Adds a HLSTagDescriptor to the registered tags list for this parser.
     
     It's worth noting that playlist parsing proceeds with the registered tags that are
     present at the beginning of parsing.
     */
    func registerHLSTags(tagType: HLSTagDescriptor.Type) {
        registeredTags.register(tagDescriptorType: tagType)
    }
    
    /**
     Removes all registered tags from this parser, leaving only the built in PantosTag collection.
     
     It's worth noting that playlist parsing proceeds with the registered tags that are
     present at the beginning of parsing.
     */
    func unRegisterAllHLSTags() {
        registeredTags.unRegisterAllHLSTagDescriptors()
    }
    
    /**
     Parses a HLS playlist into a `HLSPlaylist` structure for editing.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `HLSPlaylist` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSPlaylist` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter url: The URL of the original playlist.
     
     - parameter success: A closure callback called with a `HLSPlaylist`
     structure when the parse has sucessfully completed.
     
     - parameter failure: A closure callback called when the incoming HLS
     playlist had some structural problem that prevented us from parsing.
     */
    public func parse(playlistData data: Data,
                      url: URL,
                      success: @escaping HLSPlaylistParserSuccess,
                      failure: @escaping HLSPlaylistParserFailure) {
        
        parse(playlistData: data,
              customData: HLSPlaylistURLData(url: url),
              hlsPlaylistConstructor: constructHLSPlaylist,
              success: success,
              failure: failure)
    }
    
    /**
     Parses a HLS playlist into a `HLSPlaylist` structure for editing.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `HLSPlaylist` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSPlaylist` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter url: The URL of the original playlist. This is optional, but some
     playlist manipulations require it.
     
     - parameter timeout: The timeout in seconds. If the timeout is exceeded, an
     `HLSParserError` with the `timedOut` code will be thrown.
     
     - returns: A parsed `HLSPlaylist`.
     
     - throws: If the playlist cannot be parsed, throws an `HLSParserError`.
     */
    public func parse(playlistData data: Data, url: URL, timeout: Int = 1) throws -> HLSPlaylist {
        return try parse(playlistData: data,
                         customData: HLSPlaylistURLData(url: url),
                         hlsPlaylistConstructor: constructHLSPlaylist)
    }
    
    public func update(eventVariantPlaylist: HLSPlaylist,
                       withPlaylistData data: Data,
                       atUrl url: URL,
                       withSuccessCallback success: @escaping HLSPlaylistParserSuccess,
                       withFailureCallback failure: @escaping HLSPlaylistParserFailure) {
        
        guard
            // sanity checks on the caller
            eventVariantPlaylist.type == .media,
            eventVariantPlaylist.playlistType == .event,
            // have to update the exact same variant!
            url == eventVariantPlaylist.url,
            // check to see if this situation merits an update vs a parse
            data.count > updateEventPlaylistParams.minimalBytesToTriggerUpdate,
            (CACurrentMediaTime() - eventVariantPlaylist.creationTime) < updateEventPlaylistParams.maximumAmountOfTimeBetweenUpdatesToTrigger,
            // ensure we can get the data we need to do an update
            let lastMediaSegmentGroup = eventVariantPlaylist.mediaSegmentGroups.last,
            let lastFragmentTag = eventVariantPlaylist.tags(forMediaGroup: lastMediaSegmentGroup).filter({ $0.tagDescriptor == PantosTag.Location }).first,
            !lastFragmentTag.tagData.stringValue().isEmpty else {
                
                // if we fail preconditions just do a normal parse quietly
                parse(playlistData: data, url: url, success: success, failure: failure)
                return
        }
        
        let worker = HLSParseWorker(registeredTags: registeredTags,
                                    data: data,
                                    parser: self,
                                    parserMode: .parsingEventPlaylistLookingForFragmentURL(fragmentURL: lastFragmentTag.tagData.stringValue()),
                                    success: { [weak self] (tags, buffer) in
                                        self?.constructAndReturnEventVariantUpdate(fromEventVariantPlaylist: eventVariantPlaylist,
                                                                                   insertingNewTags: tags,
                                                                                   afterTagPosition: lastMediaSegmentGroup.endIndex,
                                                                                   withSuccessCallback: success) },
                                    failure: { [weak self] _ in
                                        // try a normal parse
                                        self?.parse(playlistData: data, url: url, success: success, failure: failure) })
        
        queue.sync {
            let _ = workers.insert(worker)
        }
        
        worker.startParse()
    }
    
    private func constructAndReturnEventVariantUpdate(fromEventVariantPlaylist eventVariantPlaylist: HLSPlaylist,
                                                      insertingNewTags newTags: [HLSTag],
                                                      afterTagPosition insertTagPosition: Int,
                                                      withSuccessCallback success: @escaping HLSPlaylistParserSuccess) {
        
        var tags = eventVariantPlaylist.tags[0...insertTagPosition]
        tags.append(contentsOf: newTags)
        let newPlaylist = HLSPlaylist(url: eventVariantPlaylist.url,
                                      tags: Array(tags),
                                      registeredTags: registeredTags,
                                      hlsBuffer: eventVariantPlaylist.hlsBuffer)
        success(newPlaylist)
    }

    public func update(eventVariantPlaylist: HLSPlaylist,
                       withPlaylistData data: Data,
                       atUrl url: URL,
                       withTimeout timeout: Int = 1) throws -> HLSPlaylist {
        
        let semaphore = DispatchSemaphore(value: 0)
        var playlist: HLSPlaylist?
        var error: HLSParserError?
        
        self.update(eventVariantPlaylist: eventVariantPlaylist,
                    withPlaylistData: data,
                    atUrl: url,
                    withSuccessCallback: { (newPlaylist) -> (Void) in
                        playlist = newPlaylist
                        semaphore.signal() },
                    withFailureCallback: { (result) -> (Void) in
                        error = result
                        semaphore.signal() })
        
        if semaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout)) == .timedOut {
            throw HLSParserError.timedOut
        }
        
        if let error = error {
            throw error
        }
        
        guard let result = playlist else {
            assertionFailure("No error, but playlist was nil!")
            throw HLSParserError.unknown(description: "No error found, but no playlist was generated.")
        }
        
        return result
    }

    
    /**
     Generic parser for your concrete `HLSPlaylistCore` objects, if you need one. Most
     users will be using the built-in `HLSPlaylist` concrete object, so you probably
     don't need to use this method.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `HLSPlaylist` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSPlaylist` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter customData: Whatever custom data class you have defined for
     your concrete `HLSPlaylistCore` object.
     
     - parameter hlsPlaylistConstructor: A closure that can construct your
     concrete `HLSPlaylistCore` object from the `HLSTag` array, your custom
     data class, a RegisteredHLSTags object, and the playlistData. See
     the `constructHLSPlaylist` function for an example.
     
     - parameter success: A closure callback called with a concrete `HLSPlaylistCore`
     structure when the parse has sucessfully completed.
     
     - parameter failure: A closure callback called when the incoming HLS
     playlist had some structural problem that prevented us from parsing.
     */
    public func parse<D>(playlistData data: Data,
                         customData: D,
                         hlsPlaylistConstructor: @escaping ([HLSTag], D, RegisteredHLSTags, StaticMemoryStorage) -> HLSPlaylistCore<D>,
                         success: @escaping (HLSPlaylistCore<D>) -> (Swift.Void),
                         failure: @escaping HLSParserFailure) {
        
        let registeredTagsCopy = registeredTags
        
        let worker = HLSParseWorker(registeredTags: registeredTags,
                                    data: data,
                                    parser: self,
                                    success: { (tags, buffer) in
                                        let playlist = hlsPlaylistConstructor(tags, customData, registeredTagsCopy, buffer)
                                        success(playlist) },
                                    failure: failure)
        
        queue.sync {
            let _ = workers.insert(worker)
        }
        
        worker.startParse()
    }

    /**
     Generic parser for your concrete `HLSPlaylistCore` objects, if you need one. Most
     users will be using the built-in `HLSPlaylist` concrete object, so you probably
     don't need to use this method.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `HLSPlaylist` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `HLSPlaylist` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter customData: Whatever custom data class you have defined for
     your concrete `HLSPlaylistCore` object.
     
     - parameter hlsPlaylistConstructor: A closure that can construct your
     concrete `HLSPlaylistCore` object from the `HLSTag` array, your custom
     data class, a RegisteredHLSTags object, and the playlistData. See
     the `constructHLSPlaylist` function for an example.
     
     - parameter timeout: The timeout in seconds. If the timeout is exceeded, an
     `HLSParserError` with the `timedOut` code will be thrown.
     
     - returns: A parsed concrete `HLSPlaylistCore`.
     
     - throws: If the playlist cannot be parsed, throws an `HLSParserError`.
     */
    public func parse<D>(playlistData data: Data,
                         customData: D,
                         hlsPlaylistConstructor: @escaping ([HLSTag], D, RegisteredHLSTags, StaticMemoryStorage) -> HLSPlaylistCore<D>,
                         timeout: Int = 1) throws -> HLSPlaylistCore<D> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var playlist: HLSPlaylistCore<D>?
        var error: HLSParserError?
        
        self.parse(playlistData: data,
                   customData: customData,
                   hlsPlaylistConstructor: hlsPlaylistConstructor,
                   success: { (newPlaylist) -> (Void) in
                    playlist = newPlaylist
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
        
        guard let result = playlist else {
            assertionFailure("No error, but playlist was nil!")
            throw HLSParserError.unknown(description: "No error found, but no playlist was generated.")
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

public typealias HLSPlaylistParserSuccess = (HLSPlaylist) -> (Swift.Void)
public typealias HLSPlaylistParserFailure = (HLSParserError) -> (Swift.Void)

public typealias HLSParserSuccess = ([HLSTag], StaticMemoryStorage) -> (Swift.Void)
public typealias HLSParserFailure = (HLSParserError) -> (Swift.Void)

/**
 This stores detailed info about when mamba decides to trigger a update of a event style
 variant (rather than just reparse from scratch).
 
 The defaults are probably good for general usage, although if your application has
 unusual or special requirements for Event style playlists, you can change. This is here
 mostly for unit testing.
 */
public struct UpdateEventPlaylistParams {
    /**
     Parsing of small playlists is very quick, so it doesn't really make sense to do anything
     special for them.
     
     The default value was chosen to approximate a 150 segment long playlist.
     */
    let minimalBytesToTriggerUpdate: Int
    /**
     If the difference between the last time the playlist was created/updated and the
     current time is more than this value, HLSParser will do a complete parse.

     
     Why? If the difference between the playlist to be updated and the new playlist is too big,
     the update process can actually be longer than the complete reparse (since the update
     process allocates new memory in small chunks for new data)
     
     The default value is 60 seconds. If your fragment length is very big, you might want this
     value to be bigger, and if your fragment length is very small, you might want this to be
     smaller.
     */
    let maximumAmountOfTimeBetweenUpdatesToTrigger: TimeInterval
    
    public init(minimalBytesToTriggerUpdate: Int = 20000,
                maximumAmountOfTimeBetweenUpdatesToTrigger: TimeInterval = 60) {
        self.minimalBytesToTriggerUpdate = minimalBytesToTriggerUpdate
        self.maximumAmountOfTimeBetweenUpdatesToTrigger = maximumAmountOfTimeBetweenUpdatesToTrigger
    }
}

private func constructHLSPlaylist(withTags tags: [HLSTag], customData: HLSPlaylistURLData, registeredHLSTags: RegisteredHLSTags, hlsBuffer: StaticMemoryStorage) -> HLSPlaylist {
    return HLSPlaylist(tags: tags, registeredTags: registeredHLSTags, hlsBuffer: hlsBuffer, customData: customData)
}

fileprivate final class HLSParseWorker: NSObject, HLSRapidParserCallback {
    
    let fastParser = HLSRapidParser()
    var tags = [HLSTag]()
    let buffer: StaticMemoryStorage
    // strong ref to parent parser while parsing is happening
    // we release when parsing is over to prevent retain cycles
    // see `parseFail, `parseSuccess` and `parseEventUpdateSuccess` for where we do that.
    var parser: HLSParser?
    let registeredTags: RegisteredHLSTags
    var success: HLSParserSuccess
    var failure: HLSParserFailure
    let parserMode: ParseWorkerMode
    
    init(registeredTags: RegisteredHLSTags,
         data: Data,
         parser: HLSParser,
         parserMode: ParseWorkerMode = .parsingFromScratch,
         success: @escaping HLSParserSuccess,
         failure: @escaping HLSParserFailure) {
        
        self.buffer = StaticMemoryStorage(data: data)
        self.parser = parser
        self.registeredTags = registeredTags
        self.parserMode = parserMode
        self.success = success
        self.failure = failure
    }
    
    func startParse() {
        fastParser.parseHLSData(self.buffer, callback: self)
    }
    
    private func scrubHLSStringRef(_ ref: HLSStringRef) -> HLSStringRef {
        switch self.parserMode {
        case .parsingFromScratch:
            return ref
        case .parsingEventPlaylistLookingForFragmentURL(_):
            // if we are parsing through an Event update, we want to only keep the original `Data` from the first parse
            // so we convert new updates to strings. This is an optimistic assumption that we only have a few
            // updated tags and the cost of converting the small number to strings will be small.
            return HLSStringRef(string: ref.stringValue())
        }
    }

    // MARK: HLSRapidParserCallback
    
    func addedCommentLine(_ comment: HLSStringRef) {
        tags.append(HLSTag(tagDescriptor: PantosTag.Comment, tagData: scrubHLSStringRef(comment)))
    }
    
    func addedURLLine(_ url: HLSStringRef) -> Bool {
        switch self.parserMode {
        case .parsingFromScratch:
            tags.append(HLSTag(tagDescriptor: PantosTag.Location, tagData: url))
            return true
        case .parsingEventPlaylistLookingForFragmentURL(let alreadyParsedFragmentURL):
            let urlString = url.stringValue()
            if alreadyParsedFragmentURL == urlString {
                if let error = parseError {
                    parseFail(error: error)
                }
                else {
                    parseEventUpdateSuccess()
                }
                return false
            }
            tags.append(HLSTag(tagDescriptor: PantosTag.Location, tagData: HLSStringRef(string: urlString)))
            return true
        }
    }
    
    func addedNoValueTag(withName tagName: HLSStringRef) {
        let descriptor = tagDescriptor(forTagName: tagName)
        guard descriptor != PantosTag.UnknownTag else {
            // special case handling for unknown tags
            tags.append(HLSTag(tagDescriptor: descriptor, tagData: HLSStringRef(), tagName: scrubHLSStringRef(tagName)))
            return
        }
        guard descriptor.type() == .noValue else {
            parseError = HLSParserError.mismatchBetweenTagDescriptorAndTagData(description:"The HLS Tag and the data contained within do not match: tagName:\"\(tagName.stringValue())\" tagValue:<no tag value> descriptor:\(descriptor)")
            return
        }
        tags.append(HLSTag(tagDescriptor: descriptor, tagData: HLSStringRef(), tagName: scrubHLSStringRef(tagName)))
    }
    
    func addedTag(withName tagName: HLSStringRef, value: HLSStringRef) {
        
        let descriptor = tagDescriptor(forTagName: tagName)
        guard descriptor.type() != .noValue else {
            parseError = HLSParserError.mismatchBetweenTagDescriptorAndTagData(description:"The HLS Tag and the data contained within do not match: tagName:\"\(tagName.stringValue())\" tagValue:\"\(value.stringValue())\" descriptor:\(descriptor)")
            return
        }
        
        guard descriptor != PantosTag.UnknownTag else {
            // special case handling for unknown tags
            tags.append(HLSTag(tagDescriptor: descriptor, tagData: scrubHLSStringRef(value), tagName: scrubHLSStringRef(tagName)))
            return
        }
        
        guard let parsedValues = parseTags(tagValue: value, descriptor: descriptor) else {
            // the `parseTags` function already set a `parseError` error object for us
            return
        }
        
        tags.append(HLSTag(tagDescriptor: descriptor, tagData: scrubHLSStringRef(value), tagName: scrubHLSStringRef(tagName), parsedValues: parsedValues))
    }
    
    func addedEXTINFTag(withName tagName: HLSStringRef, duration: HLSStringRef, value: HLSStringRef) {
        tags.append(HLSTag(tagDescriptor: PantosTag.EXTINF, tagData: scrubHLSStringRef(value), tagName: scrubHLSStringRef(tagName), duration: duration.extinfSegmentDuration()))
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
        parser = nil
    }
    
    private func parseSucceed(tags: [HLSTag]) {
        success(tags, buffer)
        parser?.parseComplete(withWorker: self)
        parser = nil
    }
    
    private func parseEventUpdateSuccess() {
        tags = tags.reversed()
        success(tags, buffer)
        parser?.parseComplete(withWorker: self)
        parser = nil
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

/// The mode that this worker is set to run
private enum ParseWorkerMode {
    
    /**
     "Normal" mode.
     
     The parser will go through the data a line at a time and extract the entire HLS playlist.
     */
    case parsingFromScratch
    
    /**
     "Event style variant" efficiency mode.
     
     With event style variant playlists, new fragments are added at the end of the playlist. Any fragments already sent are unchanged.
     This is a HLS spec requirement. <https://tools.ietf.org/html/draft-pantos-hls-rfc8216bis-03#section-6.2.1>
     
     If you are parsing a event playlist that is hours long, it's a lot of work to parse a bunch of identical content over and over
     for each playlist update.
     
     This mode sets the parse worker to look for the last fragment url that we found in the last update. Once found, we stop
     parsing and return all the "new" tags. (Note that any tags in the "footer" will be reparsed every time).
     
     Further note that we actually allocate real memory for all tag strings that is not tied to the `Data` object that we are
     parsing. It would become unworkable to keep track of the innumerable updates and which memory belongs to which `Data`.
     
     It's up to our parent HLSParser to set this mode with an eye towards performance and memory usage, and to deal with the
     returned tags appropriately to construct a valid HLSPlaylist.
     */
    case parsingEventPlaylistLookingForFragmentURL(fragmentURL: String)
}
