import Foundation
import mamba

/*: # Parsing a playlist
 In General to parse a playlist you'll need: a `HLSParser`, the source of HLS `Data`, and the `URL` of the playlist resource. */
let parser = HLSParser()
let playlistData: Data = SamplePlaylist.master
let playlistUrl: URL = URL(string: "http://nowhere")!

//: Playlists can be parsed asynchronously

parser.parse(playlistData: playlistData,
             url: playlistUrl,
             success: { (playlist) in
                print("asych:\n\(playlist)")
             },
             failure: { (error) in
                print(error)
                })

//: Or syncronously
guard let playlist: HLSPlaylist = try? parser.parse(playlistData:playlistData, url:playlistUrl) else {
    print("playlist parse failed")
    fatalError()
}
print("sych:\n\(playlist)")

//: If you have custom HLSTags not defined in `PantosTags` that you'll be parsing, pass them to the `HLSParser` on initialization
let customParser = HLSParser(tagTypes: [CustomTag.self])
customParser.parse(playlistData:SamplePlaylist.masterWithCustomTag,
                   url:playlistUrl,
                   success: { (playlist) in
                    print("asych:\n\(playlist)")
                    },
                    failure: { (error) in
                        print(error)
                    })

//: [Next](@next)
