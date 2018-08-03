//: [Previous](@previous)
import Foundation
import mamba
/*: HLSPlaylists are highly editable, just insert a new `HLSTag` into the tags array. Some examples of what you can do:
 
 Remove tag(s) to a playlist
 */
var playlist: HLSPlaylist = ParsedHLSPlaylists.variant
guard let segment = playlist.mediaSegmentGroups.last else {
    fatalError()
}
print(playlist)
playlist.delete(atRange: segment.range)
print(playlist)

//: Add tag(s) to a playlist
let tagInf: HLSTag = HLSTag(tagDescriptor: PantosTag.EXTINF, stringTagData: "5220,2")
let tagLoc: HLSTag = HLSTag(tagDescriptor: PantosTag.Location, tagData:HLSStringRef(string: "http://media.example.com/entire_1.ts"))
playlist.insert(tags: [tagInf,tagLoc], atIndex: playlist.mediaSegmentGroups.last!.endIndex + 1)
print(playlist)

//: Transform all tags in a playlist matching a criteria
do {
    try playlist.transform({ tag in
        if tag.tagDescriptor == PantosTag.Location {
            return HLSTag(tagDescriptor: PantosTag.Location, tagData: toHttps(tag.tagData))
        }
        return tag
    })
}
catch {
    fatalError()
}
print(playlist)

playlist = ParsedHLSPlaylists.variant
//: You can also validate the playlist
if let issues = HLSCompletePlaylistValidator.validate(hlsPlaylist: playlist) {
    print(issues)// Here we see our sample HLS is invalid due to our segment durations (5220) greatly exceeding or target duration of 10
} else {
    print("valid HLS")
}
do {
    try playlist.transform({ tag in
        var tag = tag
        if tag.tagDescriptor == PantosTag.EXT_X_TARGETDURATION {
            tag.set(value: "5220", forKey: PantosValue.targetDurationSeconds.rawValue)
        }
        return tag
    })
}
catch {
    fatalError()
}
print("\n")
if let issues = HLSCompletePlaylistValidator.validate(hlsPlaylist: playlist) {
    print(issues)
} else {
    print("valid HLS")// After the transform, we're now valid
}

//: [Next](@next)

func toHttps(_ stringRef:HLSStringRef) -> HLSStringRef {
    let string = stringRef.stringValue().replacingOccurrences(of: "http", with: "https")
    return HLSStringRef(string: string)
}
