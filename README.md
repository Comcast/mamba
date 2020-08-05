[![Build Status](https://secure.travis-ci.org/Comcast/mamba.svg)](https://travis-ci.org/Comcast/mamba) 
[![Code Coverage from codecov](https://codecov.io/gh/Comcast/mamba/branch/develop/graph/badge.svg)](https://codecov.io/gh/Comcast/mamba)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapod status](https://img.shields.io/cocoapods/v/mamba.svg)](https://cocoapods.org/pods/mamba)
[![GitHub release](https://img.shields.io/github/release/Comcast/mamba.svg)](https://github.com/Comcast/mamba/releases)
[![License](https://img.shields.io/cocoapods/l/mamba.svg)](https://raw.githubusercontent.com/Comcast/mamba/master/LICENSE.md)
[![Platform](https://img.shields.io/cocoapods/p/mamba.svg?style=flat)]()

Mamba
===

Mamba is a Swift iOS, tvOS and macOS framework to parse, validate and write [HTTP Live Streaming (HLS)](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23) data.

This framework is used in Comcast applications to parse, validate, edit and write HLS playlists to deliver video to millions of customers. It was written by the [Comcast VIPER](https://stackoverflow.com/jobs/companies/comcast-viper) Player Platform team.

_Mamba Project Goals:_

* **Simple-to-use parsing, editing and writing** of HLS playlists.

* **Maximum performance**. We required our parsing library to parse very large HLS playlists (12 hour Video-On-Demand) on low end phones in a few milliseconds. A internal core C library is used for very fast parsing of large playlists.

## Requires

* XCode 10.2+
* Swift 4+ (written in Swift 5)
* iOS 9+ _or_ tvOS 9+ _or_ macOS 10.13+

## Usage

### _Parsing a HLS Playlist_

Create an `PlaylistParser`. 

```swift
let parser = PlaylistParser()
```

Parse your HLS playlist using the parser. Here's the asynchronous version:

```swift
let myPlaylistData: Data = ... // source of HLS data
let myPlaylistURL: URL = ... // the URL of this playlist resource

parser.parse(playlistData: myPlaylistData,
             url: myPlaylistURL,
             callback: { result in
                switch result {
                case .parsedVariant(let variant):
                    // do something with the parsed VariantPlaylist 
                    myVariantPlaylistHandler(variantPlaylist: variant)
                    break
                case .parsedMaster(let master):
                    // do something with the parsed MasterPlaylist 
                    myMasterPlaylistHandler(masterPlaylist: master)
                    break
                case .parseError(let error):
                    // handle the ParserError
                    myErrorHandler(error: error)
                    break
                }
})
```

And here's the synchronous version:

```swift
// note: could take several milliseconds for large transcripts!
let result = parser.parse(playlistData: myPlaylistData,
                          url: myPlaylistURL)
switch result {
case .parsedVariant(let variant):
    // do something with the parsed VariantPlaylist object
    myVariantPlaylistHandler(variantPlaylist: variant)
    break
case .parsedMaster(let master):
    // do something with the parsed MasterPlaylist object
    myMasterPlaylistHandler(masterPlaylist: master)
    break
case .parseError(let error):
    // handle the ParserError
    myErrorHandler(error: error)
    break
}
```

You now have an HLS playlist object.

### _MasterPlaylist and VariantPlaylist_

These structs are in-memory representations of a HLS playlist.

They include:

* The `URL` of the playlist.
* An array of `PlaylistTag`s that represent each line in the HLS playlist. This array is editable, so you can make edits to the playlist.
* Utility functions to tell if a variant playlist is a Live, VOD or Event style playlist.
* Helpful functionality around the structure of a playlist. This structure is kept up to date behind the scenes as the playlist is edited.
 *  `VariantPlaylist`: includes calculated references to the "header", "footer" and all the video segments and the metadata around them. 
 *  `MasterPlaylist`: includes calculated references to the variant streams and their URL's.

`MasterPlaylist` and `VariantPlaylist` objects are highly editable.

### _Validating a Playlist_

Validate your playlist using the `PlaylistValidator`.

```swift
let variantPlaylist: VariantPlaylistInterface = myVariantPlaylistFactoryFunction()
let masterPlaylist: MasterPlaylistInterface = myMasterPlaylistFactoryFunction()

let variantissues = PlaylistValidator.validate(variantPlaylist: variantPlaylist)
let masterissues = PlaylistValidator.validate(masterPlaylist: masterPlaylist)
```

It returns an array of `PlaylistValidationIssue`s found with the playlist. They each have a description and a severity associated with them.

*We currently implement only a subset of the HLS validation rules as described in the [HLS specification](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23). Improving our HLS validation coverage would be a most welcome pull request!*

### _Writing a HLS Playlist_

Create a `PlaylistWriter`.

```swift
let writer = PlaylistWriter()
```

Write your HLS playlist to a stream.

```swift
let stream: OutputStream = ... // stream to receive the HLS Playlist

do {
   try writer.write(playlist: variantPlaylist, toStream: stream)
   try writer.write(playlist: masterPlaylist, toStream: stream)
}
catch {
    // there was an error severe enough for us to stop writing the data
}
```

There is also a utility function in the playlist to write out the playlist to a `Data` object.

```
do {
    let variantData = try variantPlaylist.write()
    let masterData = try masterPlaylist.write()
    
    // do something with the resulting data
    myDataHandler(data: variantData)
    myDataHandler(data: masterData)
}
catch {
    // there was an error severe enough for us to stop writing the data
}
```

### _Using Custom Tags_

Natively, Mamba only understands HLS tags as defined in the [Pantos IETF specification](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23). If you'd like to add support for a custom set of tags, you'll need to create them as a object implementing `PlaylistTagDescriptor`. Please look at `PantosTag` or one of the examples in the unit tests for sample code.

If you have any custom `PlaylistTagDescriptor` collections you'd like to parse alongside the standard Pantos tags, pass them in through this `PlaylistParser` initializer:

```swift
enum MyCustomTagSet: String {
    // define your custom tags here
    case EXT_MY_CUSTOM_TAG = "EXT-MY-CUSTOM-TAG"
}

extension MyCustomTagSet: PlaylistTagDescriptor {
    ... // conform to HLSTagDescriptor here
}

let customParser = PlaylistParser(tagTypes: [MyCustomTagSet.self])
```

If there is specfic data inside your custom tag that you'd like to access, e.g.

```
#EXT-MY-CUSTOM-TAG:CUSTOMDATA1="Data1",CUSTOMDATA2="Data1"
```

you can define that data in an enum that conforms to `PlaylistTagValueIdentifier`:

```swift
enum MyCustomValueIdentifiers: String {
    // define your custom value identifiers here
    case CUSTOMDATA1 = "CUSTOMDATA1"
    case CUSTOMDATA2 = "CUSTOMDATA2"
}

extension MyCustomValueIdentifiers: PlaylistTagValueIdentifier {
    ... // conform to PlaylistTagValueIdentifier here
}
```

You can now look through `PlaylistTag` objects for your custom tag values just as if it were a valuetype defined in the HLS specification.

### _Important Note About Memory Safety_

In order to achieve our performance goals, the internal C parser for HLS had to minimize the amount of heap memory allocated.

This meant that, for each `PlaylistTag` object that is included in a `MasterPlaylist/VariantPlaylist`, instead of using a swift `String` to represent data, we use a `MambaStringRef`, which is a object that is a reference into the memory of the original data used to parse the playlist. This greatly speeds parsing, but comes at a cost: **these `PlaylistTag` objects are unsafe to use beyond the lifetime of their parent `MasterPlaylist/VariantPlaylist`**. 

In general, this is no problem. Normal usage of a `MasterPlaylist/VariantPlaylist` would be (1) Parse the playlist, (2) Edit by manipulating `PlaylistTag`s (3) Write the playlist. 

If you do, for some reason, need to access `PlaylistTag` data beyond the lifetime of the parent `MasterPlaylist/VariantPlaylist` object, you'll need to make a copy of all `MambaStringRef` data of interest into a regular swift `String`. There's a string conversion function in `MambaStringRef` to accomplish this.

--

_Note: We have legacy branches for mamba 1.x at [our main 1.x branch](https://github.com/Comcast/mamba/tree/main_1.x) and [our develop 1.x branch](https://github.com/Comcast/mamba/tree/develop_1.x). We are maintaining that branch, but may stop updating in the near future. Users are welcome to submit pull requests against the 1.x branches or potentially fork if they do not want to move to 2.0_

--
