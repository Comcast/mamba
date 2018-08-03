import Foundation
import mamba
public struct SamplePlaylist {
    public static let master:Data = "#EXTM3U\n#EXT-X-VERSION:6\n#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2855600,CODECS=\"avc1.4d001f,mp4a.40.2\",RESOLUTION=960x540\nlive/medium.m3u8\n#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=5605600,CODECS=\"avc1.640028,mp4a.40.2\",RESOLUTION=1280x720\nlive/high.m3u8".data(using:.utf8)!
    public static let variant:Data = "#EXTM3U\n#EXT-X-VERSION:4\n#EXT-X-I-FRAMES-ONLY\n#EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-ALLOW-CACHE:NO\n#EXT-X-TARGETDURATION:10\n#EXT-X-MEDIA-SEQUENCE:1\n#EXT-X-PROGRAM-DATE-TIME:2016-02-19T14:54:23.031+08:00\n#EXT-X-INDEPENDENT-SEGMENTS\n#EXT-X-START:TIME-OFFSET=0\n#EXT-X-KEY:METHOD=NONE\n#EXTINF:5220,1\nhttp://media.example.com/entire.ts\n#EXT-X-DISCONTINUITY\n#EXT-X-KEY:METHOD=SAMPLE-AES,URI=\"https://priv.example.com/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa,KEYFORMAT=\"com.apple.streamingkeydelivery\",KEYFORMATVERSIONS=\"1\"\n#EXTINF:5220,2\n#EXT-X-BYTERANGE:82112@752321\nhttp://media.example.com/entire1.ts\n#EXT-X-ENDLIST".data(using:.utf8)!
    public static let masterWithCustomTag:Data = "#EXTM3U\n#EXT-X-CUSTOM\n#EXT-X-VERSION:6\n#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2855600,CODECS=\"avc1.4d001f,mp4a.40.2\",RESOLUTION=960x540\nlive/medium.m3u8\n#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=5605600,CODECS=\"avc1.640028,mp4a.40.2\",RESOLUTION=1280x720\nlive/high.m3u8".data(using:.utf8)!
}

public struct ParsedHLSPlaylists {
    public static let master:HLSPlaylist = {
        let parser = HLSParser()
        return try! parser.parse(playlistData:SamplePlaylist.master, url:URL(string:"http://nowhere")!) 
    }()
    
    public static let variant:HLSPlaylist = {
        let parser = HLSParser()
        return try! parser.parse(playlistData:SamplePlaylist.variant, url:URL(string:"http://nowhere")!)
    }()
}

public extension Sequence where Iterator.Element == HLSTag {
    public var prettyPrint: String {
        get {
            var string = "tags:\n"
            self.forEach { (tag) in
                string += String("\(tag)\n")
            }
            return string
        }
    }
}

public enum CustomTag: String {
    
    case EXT_X_CUSTOM = "EXT-X-CUSTOM"
}

extension CustomTag: HLSTagDescriptor, Equatable {
    
    public static func constructTag(tag: String) -> HLSTagDescriptor? {
        return CustomTag(rawValue: tag)
    }
    
    public func toString() -> String {
        return self.rawValue
    }
    
    public func isEqual(toTagDescriptor tagDescriptor: HLSTagDescriptor) -> Bool {
        guard let ourtag = tagDescriptor as? CustomTag else {
            return false
        }
        return ourtag.rawValue == self.rawValue
    }
    
    public func scope() -> HLSTagDescriptorScope {
        return .mediaSegment
    }
    
    public static func parser(forTag tag: HLSTagDescriptor) -> HLSTagParser? {
        guard let ourtag = CustomTag(rawValue: tag.toString()) else {
            return nil
        }
        
        return GenericDictionaryTagParser(tag: ourtag)
    }
    
    public static func writer(forTag tag: HLSTagDescriptor) -> HLSTagWriter? {
        return nil
    }
    
    public static func validator(forTag tag: HLSTagDescriptor) -> HLSTagValidator? {
        return nil
    }
    
    public func type() -> HLSTagDescriptorType {
        return .noValue
    }
    
    public static func constructDescriptor(fromStringRef string: HLSStringRef) -> HLSTagDescriptor? {
        var tagName = string.stringValue()
        tagName.remove(at: tagName.startIndex)
        return constructTag(tag: tagName)
    }
}
