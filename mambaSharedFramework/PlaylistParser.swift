//
//  PlaylistParser.swift
//  mamba
//
//  Created by David Coufal on 3/12/19.
//  Copyright © 2019 Comcast Corporation.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License. All rights reserved.
//

import Foundation

/**
 A performant parser for HLS playlists.
 */
public final class PlaylistParser {
    
    internal fileprivate(set) var registeredTags = RegisteredTags()
    internal let updateEventPlaylistParams: UpdateEventPlaylistParams
    
    /**
     Constructs a parser for HLS playlists.
     
     - parameter tagTypes: An optional array of `TagDescriptor` Types that the caller
     would like this parser to parse. If you have custom tags that you'd like to easily
     identify and query on, the caller can construct their own `TagDescriptor`-implementing
     object and pass in the type here.
     - parameter updateEventPlaylistParams: An optional struct with parameters for desired
     behavior when updating an Event style variant playlist. See `UpdateEventPlaylistParams`
     for details. If you are uncertain, the defaults are probably good. Mostly present for
     unit testing purposes.
     */
    public init(tagTypes:[PlaylistTagDescriptor.Type]? = nil,
                updateEventPlaylistParams: UpdateEventPlaylistParams = UpdateEventPlaylistParams()) {
        self.updateEventPlaylistParams = updateEventPlaylistParams
        if let tagTypes = tagTypes {
            for tagType in tagTypes {
                registerTags(tagType: tagType)
            }
        }
    }
    
    /**
     Adds a PlaylistTagDescriptor to the registered tags list for this parser.
     
     It's worth noting that playlist parsing proceeds with the registered tags that are
     present at the beginning of parsing.
     */
    func registerTags(tagType: PlaylistTagDescriptor.Type) {
        registeredTags.register(tagDescriptorType: tagType)
    }
    
    /**
     Removes all registered tags from this parser, leaving only the built in PantosTag collection.
     
     It's worth noting that playlist parsing proceeds with the registered tags that are
     present at the beginning of parsing.
     */
    func unRegisterAllTags() {
        registeredTags.unRegisterAllTagDescriptors()
    }
    
    /**
     Parses a HLS playlist into a `MasterPlaylist` or `VariantPlaylist` structure
     for editing.
     
     Asynchronous version.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final playlist structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final playlist will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter url: The URL of the original playlist.
     
     - parameter callback: A closure callback called with a `PlaylistParserResult` value
     when complete.
     */
    public func parse(playlistData data: Data,
                      url: URL,
                      callback: @escaping PlaylistParserResult) {
        
        parse(playlistData: data,
              customData: PlaylistURLData(url: url),
              playlistConstructor: constructMasterOrVariantPlaylist,
              resultCallback: callback)
    }
    
    /**
     Parses a HLS playlist into a `MasterPlaylist` or `VariantPlaylist` structure
     for editing.
     
     Synchronous version.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `PlaylistInterface` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `PlaylistInterface` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter url: The URL of the original playlist.
     
     - parameter timeout: The timeout in seconds. If the timeout is exceeded, an
     `ParserError` with the `timedOut` code will be thrown.
     
     - returns: A `PlaylistParserResult`.
     */
    public func parse(playlistData data: Data, url: URL, timeout: Int = 1) -> ParserResult {
        return parse(playlistData: data,
                     customData: PlaylistURLData(url: url),
                     playlistConstructor: constructMasterOrVariantPlaylist,
                     timeout: timeout)
    }
    
    /**
     Attempts to update an Event-style `VariantPlaylist` with changes from the server.
     This method should be faster than updating from scratch for long events.
     
     This method will attempt to be smart about when to update and when to parse
     from scratch. It will use values from `UpdateEventPlaylistParams` to assist,
     so you can tune this method if the defaults are not good for you.
     
     It will take care of memory usage, although the rules about not using `PlaylistTag`
     after the parent playlist is deleted still apply.
     
     Asynchronous version.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `PlaylistInterface` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `PlaylistInterface` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter eventVariantPlaylist: A `VariantPlaylist` object thay you would
     like to update.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter url: The URL of the original playlist.
     
     - parameter withSuccessCallback: A callback for when a a new version of your
     playlist is available
     
     - parameter withFailureCallback: A callback for when the update fails.
     */
    public func update(eventVariantPlaylist: VariantPlaylist,
                       withPlaylistData data: Data,
                       atUrl url: URL,
                       withSuccessCallback success: @escaping VariantPlaylistParserSuccess,
                       withFailureCallback failure: @escaping PlaylistParserFailure) {
        
        guard
            // sanity checks on the caller
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
                eventVariantUpdateFallbackToNormalParse(withPlaylistData: data,
                                                        atUrl: url,
                                                        withSuccessCallback: success,
                                                        withFailureCallback: failure)
                return
        }
        
        let worker = ParseWorker(registeredTags: registeredTags,
                                 data: data,
                                 parser: self,
                                 parserMode: .parsingEventPlaylistLookingForFragmentURL(fragmentURL: lastFragmentTag.tagData.stringValue()),
                                 success: { [weak self] (tags, storage) in
                                    self?.constructAndReturnEventVariantUpdate(fromEventVariantPlaylist: eventVariantPlaylist,
                                                                               insertingNewTags: tags,
                                                                               afterTagPosition: lastMediaSegmentGroup.endIndex,
                                                                               withSuccessCallback: success) },
                                 failure: { [weak self] _ in
                                    // try a normal parse
                                    self?.eventVariantUpdateFallbackToNormalParse(withPlaylistData: data,
                                                                                  atUrl: url,
                                                                                  withSuccessCallback: success,
                                                                                  withFailureCallback: failure) })
        
        queue.sync {
            let _ = workers.insert(worker)
        }
        
        worker.startParse()
    }
    
    private func eventVariantUpdateFallbackToNormalParse(withPlaylistData data: Data,
                                                         atUrl url: URL,
                                                         withSuccessCallback success: @escaping VariantPlaylistParserSuccess,
                                                         withFailureCallback failure: @escaping PlaylistParserFailure) {
        parse(playlistData: data,
              url: url,
              callback: { parserResult in
                switch parserResult {
                case .parsedVariant(let variant):
                    success(variant)
                    break
                case .parsedMaster(_):
                    failure(.unexpectedPlaylistType)
                    break
                case .parseError(let error):
                    failure(error)
                    break
                }
        })
    }
    
    private func constructAndReturnEventVariantUpdate(fromEventVariantPlaylist eventVariantPlaylist: VariantPlaylist,
                                                      insertingNewTags newTags: [PlaylistTag],
                                                      afterTagPosition insertTagPosition: Int,
                                                      withSuccessCallback success: @escaping VariantPlaylistParserSuccess) {
        
        var tags = eventVariantPlaylist.tags[0...insertTagPosition]
        tags.append(contentsOf: newTags)
        let newPlaylist = VariantPlaylist(url: eventVariantPlaylist.url,
                                          tags: Array(tags),
                                          registeredTags: registeredTags,
                                          playlistMemoryStorage: eventVariantPlaylist.playlistMemoryStorage)
        success(newPlaylist)
    }
    
    /**
     Attempts to update an Event-style `VariantPlaylist` with changes from the server.
     This method should be faster than updating from scratch for long events.
     
     This method will attempt to be smart about when to update and when to parse
     from scratch. It will use values from `UpdateEventPlaylistParams` to assist,
     so you can tune this method if the defaults are not good for you.
     
     It will take care of memory usage, although the rules about not using `PlaylistTag`
     after the parent playlist is deleted still apply.
     
     Synchronous version.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `PlaylistInterface` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `PlaylistInterface` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter eventVariantPlaylist: A `VariantPlaylist` object thay you would
     like to update.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter url: The URL of the original playlist.
     
     - parameter timeout: The timeout in seconds. If the timeout is exceeded, an
     `ParserError` with the `timedOut` code will be thrown.
     
     - returns: A `VariantPlaylist`.
     */
    public func update(eventVariantPlaylist: VariantPlaylist,
                       withPlaylistData data: Data,
                       atUrl url: URL,
                       withTimeout timeout: Int = 1) throws -> VariantPlaylist {
        
        let semaphore = DispatchSemaphore(value: 0)
        var playlist: VariantPlaylist?
        var error: PlaylistParserError?
        
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
            throw PlaylistParserError.timedOut
        }
        
        if let error = error {
            throw error
        }
        
        guard let result = playlist else {
            assertionFailure("No error, but playlist was nil!")
            throw PlaylistParserError.unknown(description: "No error found, but no playlist was generated.")
        }
        
        return result
    }
    
    
    /**
     Generic asynchronous parser for your concrete `PlaylistCore` objects, if you
     need one. Most users will be using the built-in `MasterPlaylist/VariantPlaylist`
     concrete objects, so you probably don't need to use this method.
     
     The function is generic on:
     
     * CD: which is the custom data type `customPlaylistDataType` from your
     `PlaylistTypeInterface`
     
     * R: A "result" type that you define for yourself. It's typically a enum
     with success and failure types.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `PlaylistInterface` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `PlaylistInterface` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter customData: Whatever custom data class (`customPlaylistDataType`)
     you have defined for your concrete `PlaylistCore<PlaylistTypeInterface>` object.
     
     - parameter playlistConstructor: A generic closure that can construct your
     concrete `PlaylistCore<PlaylistTypeInterface>` result from the either a
     `PlaylistTag` array OR a parser error, your custom data class, a RegisteredTags
     object, and the playlistData. See the `constructMasterOrVariantPlaylist` function
     for an example.
     
     - parameter resultCallback: A closure callback called with a concrete R type that
     the caller has defined.
     */
    public func parse<CD, R>(playlistData data: Data,
                             customData: CD,
                             playlistConstructor: @escaping PlaylistConstructor<CD, R>,
                             resultCallback: @escaping (R) -> (Swift.Void)) {
        
        let registeredTagsCopy = registeredTags
        
        let success: ParserSuccess = { tags, storage in
            let result = playlistConstructor(BaseParserResult.success(tags), customData, registeredTagsCopy, storage)
            resultCallback(result)
        }
        let failure: ParserFailure = { error in
            let result = playlistConstructor(BaseParserResult.failure(error), customData, registeredTagsCopy, StaticMemoryStorage())
            resultCallback(result)
        }
        
        let worker = ParseWorker(registeredTags: registeredTags,
                                 data: data,
                                 parser: self,
                                 success: success,
                                 failure: failure)
        
        queue.sync {
            let _ = workers.insert(worker)
        }
        
        worker.startParse()
    }
    
    /**
     Generic synchronous parser for your concrete `PlaylistCore` objects, if you
     need one. Most users will be using the built-in `MasterPlaylist/VariantPlaylist`
     concrete objects, so you probably don't need to use this method.
     
     The function is generic on:
     
     * CD: which is the custom data type `customPlaylistDataType` from your
     `PlaylistTypeInterface`
     
     * R: A "result" type that you define for yourself. It's typically a enum
     with success and failure types.
     
     - warning: this method, to improve performance, keeps references to the
     original `playlistData` in the final `PlaylistInterface` structure. (This allows us
     to not allocate very much memory during parsing, which keeps this method
     performant). The final `PlaylistInterface` will keep a reference to the `playlistData`
     so the caller does not have to keep a reference, but be aware that if a
     mutable data object is passed in and is mutated during parsing or afterward
     while manipulating the playlist, the caller will get undefined behavior.
     
     - parameter playlistData: A `Data` object that represents a HLS playlist
     (typically from a web request)
     
     - parameter customData: Whatever custom data class (`customPlaylistDataType`)
     you have defined for your concrete `PlaylistCore<PlaylistTypeInterface>` object.
     
     - parameter playlistConstructor: A generic closure that can construct your
     concrete `PlaylistCore<PlaylistTypeInterface>` result from the either a
     `PlaylistTag` array OR a parser error, your custom data class, a RegisteredTags
     object, and the playlistData. See the `constructMasterOrVariantPlaylist` function
     for an example.
     
     - parameter timeout: The timeout in seconds. If the timeout is exceeded, an
     `ParserError` with the `timedOut` code will be returned.
     
     - returns: A "R" value, which the caller has defined.
     */
    public func parse<CD, R>(playlistData: Data,
                             customData: CD,
                             playlistConstructor: @escaping PlaylistConstructor<CD, R>,
                             timeout: Int = 1) -> R {
        
        let semaphore = DispatchSemaphore(value: 0)
        let registeredTagsCopy = registeredTags
        var result: R = playlistConstructor(BaseParserResult.failure(.timedOut), customData, registeredTagsCopy, StaticMemoryStorage())
        
        self.parse(playlistData: playlistData,
                   customData: customData,
                   playlistConstructor: playlistConstructor,
                   resultCallback: { newResult in
                    result = newResult
                    semaphore.signal() })
        
        if semaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout)) == .timedOut {
            return result
        }
        
        return result
    }
    
    private var workers = Set<ParseWorker>()
    private let queue = DispatchQueue(label: "com.comcast.mamba.Parser", qos: .userInitiated)
    
    fileprivate func parseComplete(withWorker worker: ParseWorker) {
        queue.async {
            self.workers.remove(worker)
        }
    }
}

public typealias PlaylistParserResult = (ParserResult) -> (Swift.Void)

/// Result from a parse of a HLS playlist
public enum ParserResult {
    /// Returning a constructed master playlist
    case parsedMaster(MasterPlaylist)
    /// Returning a constructed variant playlist
    case parsedVariant(VariantPlaylist)
    /// Found an error while parsing the data
    case parseError(PlaylistParserError)
}

/**
 A generic closure prototype to construct a "result" from a `BaseParserResult`, a "CD",
 a RegisteredTags, and the original Data used to produce the `PlaylistTag` array.
 
 When using the generic functions of the `Parser`, this closure is required to
 interpret the tag array into whatever custom Playlist type you require.
 
 The `BaseParserResult` is going to either have an array of `PlaylistTag`s or a `ParserError`.
 
 A "CD" is the `customPlaylistDataType` from your `PlaylistTypeInterface` for your
 playlist.
 
 A "R" is the result you'd like to send. It's typically a enum with success and
 failure cases, but the actual type is up to you.
 */
public typealias PlaylistConstructor<CD, R> = (BaseParserResult, CD, RegisteredTags, StaticMemoryStorage) -> (R)

public enum BaseParserResult {
    case success([PlaylistTag])
    case failure(PlaylistParserError)
}

/// A PlaylistConstructor<PlaylistURLData, ParserResult> implementation for Master and Variant switch
private func constructMasterOrVariantPlaylist(withBaseParserResult baseParserResult: BaseParserResult,
                                              andUrlData urlData: PlaylistURLData,
                                              andregisteredTags registeredTags: RegisteredTags,
                                              andPlaylistMemoryStorage playlistMemoryStorage: StaticMemoryStorage) -> ParserResult {
    
    switch baseParserResult {
    case .success(let tags):
        switch tags.type() {
        case .master:
            return ParserResult.parsedMaster(MasterPlaylist(tags: tags, registeredTags: registeredTags, playlistMemoryStorage: playlistMemoryStorage, customData: urlData))
        case .media:
            return ParserResult.parsedVariant(VariantPlaylist(tags: tags, registeredTags: registeredTags, playlistMemoryStorage: playlistMemoryStorage, customData: urlData))
        case .unknown:
            return ParserResult.parseError(.unableToDeterminePlaylistType)
        }
    case .failure(let error):
        return ParserResult.parseError(error)
    }
}

public typealias ParserSuccess = ([PlaylistTag], StaticMemoryStorage) -> (Swift.Void)
public typealias ParserFailure = (PlaylistParserError) -> (Swift.Void)

public typealias VariantPlaylistParserSuccess = (VariantPlaylist) -> (Swift.Void)
public typealias PlaylistParserFailure = (PlaylistParserError) -> (Swift.Void)


fileprivate final class ParseWorker: NSObject, RapidParserCallback {
    
    let fastParser = RapidParser()
    var tags = [PlaylistTag]()
    let playlistMemoryStorage: StaticMemoryStorage
    // strong ref to parent parser while parsing is happening
    // we release when parsing is over to prevent retain cycles
    // see `parseFail, `parseSuccess` and `parseEventUpdateSuccess` for where we do that.
    var parser: PlaylistParser?
    let registeredTags: RegisteredTags
    var success: ParserSuccess
    var failure: ParserFailure
    let parserMode: ParseWorkerMode
    
    init(registeredTags: RegisteredTags,
         data: Data,
         parser: PlaylistParser,
         parserMode: ParseWorkerMode = .parsingFromScratch,
         success: @escaping ParserSuccess,
         failure: @escaping ParserFailure) {
        
        self.playlistMemoryStorage = StaticMemoryStorage(data: data)
        self.parser = parser
        self.registeredTags = registeredTags
        self.parserMode = parserMode
        self.success = success
        self.failure = failure
    }
    
    func startParse() {
        fastParser.parseHLSData(self.playlistMemoryStorage, callback: self)
    }
    
    private func scrubMambaStringRef(_ ref: MambaStringRef) -> MambaStringRef {
        switch self.parserMode {
        case .parsingFromScratch:
            return ref
        case .parsingEventPlaylistLookingForFragmentURL(_):
            // if we are parsing through an Event update, we want to only keep the original `Data` from the first parse
            // so we convert new updates to strings. This is an optimistic assumption that we only have a few
            // updated tags and the cost of converting the small number to strings will be small.
            return MambaStringRef(string: ref.stringValue())
        }
    }
    
    // MARK: RapidParserCallback
    
    func addedCommentLine(_ comment: MambaStringRef) {
        tags.append(PlaylistTag(tagDescriptor: PantosTag.Comment, tagData: scrubMambaStringRef(comment)))
    }
    
    func addedURLLine(_ url: MambaStringRef) -> Bool {
        switch self.parserMode {
        case .parsingFromScratch:
            tags.append(PlaylistTag(tagDescriptor: PantosTag.Location, tagData: url))
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
            tags.append(PlaylistTag(tagDescriptor: PantosTag.Location, tagData: MambaStringRef(string: urlString)))
            return true
        }
    }
    
    func addedNoValueTag(withName tagName: MambaStringRef) {
        let descriptor = tagDescriptor(forTagName: tagName)
        guard descriptor != PantosTag.UnknownTag else {
            // special case handling for unknown tags
            tags.append(PlaylistTag(tagDescriptor: descriptor, tagData: MambaStringRef(), tagName: scrubMambaStringRef(tagName)))
            return
        }
        guard descriptor.type() == .noValue else {
            parseError = PlaylistParserError.mismatchBetweenTagDescriptorAndTagData(description:"The PlaylistTag and the data contained within do not match: tagName:\"\(tagName.stringValue())\" tagValue:<no tag value> descriptor:\(descriptor)")
            return
        }
        tags.append(PlaylistTag(tagDescriptor: descriptor, tagData: MambaStringRef(), tagName: scrubMambaStringRef(tagName)))
    }
    
    func addedTag(withName tagName: MambaStringRef, value: MambaStringRef) {
        
        let descriptor = tagDescriptor(forTagName: tagName)
        guard descriptor.type() != .noValue else {
            parseError = PlaylistParserError.mismatchBetweenTagDescriptorAndTagData(description:"The PlaylistTag and the data contained within do not match: tagName:\"\(tagName.stringValue())\" tagValue:\"\(value.stringValue())\" descriptor:\(descriptor)")
            return
        }
        
        guard descriptor != PantosTag.UnknownTag else {
            // special case handling for unknown tags
            tags.append(PlaylistTag(tagDescriptor: descriptor, tagData: scrubMambaStringRef(value), tagName: scrubMambaStringRef(tagName)))
            return
        }
        
        guard let parsedValues = parseTags(tagValue: value, descriptor: descriptor) else {
            // the `parseTags` function already set a `parseError` error object for us
            return
        }
        
        tags.append(PlaylistTag(tagDescriptor: descriptor, tagData: scrubMambaStringRef(value), tagName: scrubMambaStringRef(tagName), parsedValues: parsedValues))
    }
    
    func addedEXTINFTag(withName tagName: MambaStringRef, duration: MambaStringRef, value: MambaStringRef) {
        tags.append(PlaylistTag(tagDescriptor: PantosTag.EXTINF, tagData: scrubMambaStringRef(value), tagName: scrubMambaStringRef(tagName), duration: duration.extinfSegmentDuration()))
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
        var parsererror: PlaylistParserError
        switch Int(errorNumber) {
        case PlaylistParserInternalErrorCode.missingTagData.rawValue:
            parsererror = .missingTagData(description:error)
            break
        case PlaylistParserInternalErrorCode.missingTagDataForEXTINF.rawValue:
            parsererror = .missingTagDataForEXTINF(description:error)
            break
        default:
            assertionFailure("Found unknown error code \"\(errorNumber)\" with error string \"\(error)\" in parseError.ParseWorker")
            parsererror = .unknown(description:"\(errorNumber): \(error)")
            break
        }
        parseFail(error: parsererror)
    }
    
    // MARK: Parser Helpers
    
    private func parseFail(error: PlaylistParserError) {
        failure(error)
        parser?.parseComplete(withWorker: self)
        parser = nil
    }
    
    private func parseSucceed(tags: [PlaylistTag]) {
        success(tags, playlistMemoryStorage)
        parser?.parseComplete(withWorker: self)
        parser = nil
    }
    
    private func parseEventUpdateSuccess() {
        tags = tags.reversed()
        success(tags, playlistMemoryStorage)
        parser?.parseComplete(withWorker: self)
        parser = nil
    }
    
    private func parseTags(tagValue: MambaStringRef, descriptor: PlaylistTagDescriptor) -> PlaylistTagDictionary? {
        
        let parser = registeredTags.parser(forTag: descriptor)
        let tagBody = tagValue.stringValue()
        do {
            return try parser.parseTag(fromTagString: tagBody)
        }
        catch let error as PlaylistParserError {
            parseError = error
        }
        catch {
            parseError = PlaylistParserError.unknown(description:"Unknown error: \"\(error)\" while parsing tag \"\(descriptor.toString())\" with body \"\(String(describing: tagValue))\"")
        }
        return nil
    }
    
    private var parseError: PlaylistParserError? = nil
    
    private func tagDescriptor(forTagName name: MambaStringRef) -> PlaylistTagDescriptor {
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
     
     It's up to our parent Parser to set this mode with an eye towards performance and memory usage, and to deal with the
     returned tags appropriately to construct a valid playlist.
     */
    case parsingEventPlaylistLookingForFragmentURL(fragmentURL: String)
}

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
     current time is more than this value, `Parser` will do a complete parse.

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
