#Mamba Version 2.0 Request for Comment from Users

The core mamba team has identified weaknesses in the design of mamba as we have worked with the library over the past couple of years. We're going to start work on a updated version soon. To free ourselves to make the best choices, this will be a breaking change (although we will try to keep huge changes to a minimum).

We have a list of features that's we'd like to add/alter, but we wanted to have a period of time where the community could give us feedback on pain points or improvements.

If you have an idea for a feature or change, please write up as an issue on [the mamba issues page](https://github.com/Comcast/mamba/issues) and mark with the `mamba2.0` label.

Here's a list of the Comcast teams' desired updates:

* Clearer typing for `HLSPlaylist` master and variant types. Right now, both of these are the same type. This makes the interfaces awkward when trying to deal with media sequences, segment times, etc; which are only valid for variant playlists. There should be two types, `HLSMasterPlaylist` and `HLSVariantPlaylist`. They would share a lot of code, which would be accomplished by either inheritance from a base class or (more likely) a generic `HLSPlaylist<T>` class this is specialized for Master and Variant `T` types. <https://github.com/Comcast/mamba/issues/5>

* We should remove the `HLS` prefix from all types. This is not really required in modern Swift. <https://github.com/Comcast/mamba/issues/39>

* Comcast has privately written some code to figure out if a given master playlist has totally demuxed audio and video, partially demuxed audio/video (i.e. some video/audio that is muxed and some audio and/or video that is demuxed (typically SAP), or totally muxed audio/video. We should make that public since it might be useful to others. <https://github.com/Comcast/mamba/issues/40>

* The `playlistType: PlaylistType` for a `HLSPlaylist` should be cached instead of calculated every time. Also it should only be present if we are a `VariantPlaylist` (we don't have enough info in a master to figure this out). Also, it should be cached, but if a user makes HLS content changes we should throw away the tag (it's technically possible for a user to transform a "EVENT" style playlist into "LIVE" if they really wanted to.). Therefore, this should be part of `HLSPlaylistStructure` at some level so we know when the cache should be vacated. <https://github.com/Comcast/mamba/issues/41>

* It seems like getting the time where some tags occur in variant playlists (possibly with particular data associated with the tag) in the playlist is a common request (at Comcast, we do this, and a user has asked for it as well <https://github.com/Comcast/mamba/issues/29>). We should add some syntatic sugar for this to turn it into a one liner function. <https://github.com/Comcast/mamba/issues/42>

* Remove the `HLSTagCriteria` and `HLSTagCriterion` Query Language objects. It turns out that using filter/map/reduce is a simpler, more swift way of doing things that everyone understands. The small amount of code that uses it can be rewritten to use filter/map/reduce. <https://github.com/Comcast/mamba/issues/43>