import UIKit
import mamba

let hlsSamplePlaylistMaster = "#EXTM3U\n#EXT-X-VERSION:6\n#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2855600,CODECS=\"avc1.4d001f,mp4a.40.2\",RESOLUTION=960x540\nlive/medium.m3u8\n#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=5605600,CODECS=\"avc1.640028,mp4a.40.2\",RESOLUTION=1280x720\nlive/high.m3u8"

let parser = HLSParser()
let master:Data = hlsSamplePlaylistMaster.data(using: .utf8)!
let url = URL(string:"http://nowhere")!
let playlist:HLSPlaylist = try! parser.parse(playlistData: master, url: url)
print(playlist)
