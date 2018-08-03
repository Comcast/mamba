//: [Previous](@previous)
import Foundation
import mamba

let masterPlaylist: HLSPlaylist = ParsedHLSPlaylists.master
let variantPlaylist: HLSPlaylist = ParsedHLSPlaylists.variant
/*: # Reading a playlist
 The `HLSPlaylist` struct is an in memory representation of a HLS playlist. It includes:
 The `URL` of the playlist*/
let url: URL = masterPlaylist.url
print("url:\(url)")
//: An editable array of `HLSTag`s that represent each line in the playlist.
let tags: [HLSTag] = masterPlaylist.tags
print(tags.prettyPrint)
//: utility functions to tell if a playlist is a master or variant, live, event or vod
let fileType: FileType = variantPlaylist.type //media
let playlistType: PlaylistType = variantPlaylist.playlistType //vod

//: helper functions for the structure of a playlist
let header: TagGroup = variantPlaylist.header! //returns references to all the header tags in the playlist
print("header " + variantPlaylist.tags(forMediaGroup: header).prettyPrint)

let footer: TagGroup = variantPlaylist.footer! //returns references to all footer tags in the playlist
print("footer " + variantPlaylist.tags(forMediaGroup: footer).prettyPrint)

let media: [MediaSegmentTagGroup] = variantPlaylist.mediaSegmentGroups //returns references to all media segments
print("media " + variantPlaylist.tags(forMediaGroup: media[0]).prettyPrint)
//: [Next](@next)
