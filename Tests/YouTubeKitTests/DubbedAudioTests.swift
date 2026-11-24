//
//  DubbedAudioTests.swift
//  YouTubeKit
//

import XCTest
@testable import YouTubeKit

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
final class DubbedAudioTests: XCTestCase {

    private let plainOriginal = "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Alang%3Dko"

    private func streams(_ json: String) throws -> [YouTubeKit.Stream] {
        try JSONDecoder().decode([InnerTube.StreamingData.Format].self, from: Data(json.utf8)).map { try YouTubeKit.Stream(format: $0) }
    }

    private func audioURLs(_ streams: [YouTubeKit.Stream]) -> [String] {
        streams.filter { $0.includesAudioTrack && !$0.includesVideoTrack }.map(\.url.absoluteString)
    }

    // Formats of Uqzaq1I72P4 from the TVHTML5 client with hl=ko, URLs shortened.
    func testKeepsPlainOriginalWhenNamesAreKorean() throws {
        let kept = Extraction.filterOutDubbedAudio(try streams(#"""
        [
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Ddubbed-auto%3Alang%3Den-US",
             "audioTrack": {"displayName": "영어 (US)", "id": "en-US.10", "audioIsDefault": false}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Ddubbed-auto%3Alang%3Did",
             "audioTrack": {"displayName": "인도네시아어", "id": "id.10", "audioIsDefault": false}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Adrc%3D1%3Alang%3Dko",
             "audioTrack": {"displayName": "한국어 원본", "id": "ko.4", "audioIsDefault": true}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Alang%3Dko",
             "audioTrack": {"displayName": "한국어 원본", "id": "ko.4", "audioIsDefault": true}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Alang%3Dko%3Avb%3D1",
             "audioTrack": {"displayName": "한국어 원본", "id": "ko.4", "audioIsDefault": true}},
            {"itag": 136, "mimeType": "video/mp4; codecs=\"avc1.4d401f\"", "url": "https://example.com/videoplayback?itag=136"}
        ]
        """#))
        XCTAssertEqual(audioURLs(kept), [plainOriginal])
        XCTAssertTrue(kept.contains { $0.itag.itag == 136 })
    }

    func testKeepsPlainOriginalWhenNamesAreEnglish() throws {
        let kept = Extraction.filterOutDubbedAudio(try streams(#"""
        [
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Ddubbed-auto%3Alang%3Den-US",
             "audioTrack": {"displayName": "English (US)", "id": "en-US.10", "audioIsDefault": false}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Ddubbed-auto%3Alang%3Did",
             "audioTrack": {"displayName": "Indonesian", "id": "id.10", "audioIsDefault": false}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Adrc%3D1%3Alang%3Dko",
             "audioTrack": {"displayName": "Korean original", "id": "ko.4", "audioIsDefault": true}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Alang%3Dko",
             "audioTrack": {"displayName": "Korean original", "id": "ko.4", "audioIsDefault": true}},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Alang%3Dko%3Avb%3D1",
             "audioTrack": {"displayName": "Korean original", "id": "ko.4", "audioIsDefault": true}},
            {"itag": 136, "mimeType": "video/mp4; codecs=\"avc1.4d401f\"", "url": "https://example.com/videoplayback?itag=136"}
        ]
        """#))
        XCTAssertEqual(audioURLs(kept), [plainOriginal])
    }

    func testKeepsAdjustedOriginalWithoutAPlainOne() throws {
        let kept = Extraction.filterOutDubbedAudio(try streams(#"""
        [
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Ddubbed-auto%3Alang%3Den-US"},
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Adrc%3D1%3Alang%3Dko"}
        ]
        """#))
        XCTAssertEqual(audioURLs(kept), ["https://example.com/videoplayback?itag=140&xtags=acont%3Doriginal%3Adrc%3D1%3Alang%3Dko"])
    }

    func testKeepsAudioOfAVideoWithOneTrack() throws {
        let all = try streams(#"""
        [
            {"itag": 140, "mimeType": "audio/mp4; codecs=\"mp4a.40.2\"", "url": "https://example.com/videoplayback?itag=140"},
            {"itag": 251, "mimeType": "audio/webm; codecs=\"opus\"", "url": "https://example.com/videoplayback?itag=251"}
        ]
        """#)
        let kept = Extraction.filterOutDubbedAudio(all)
        XCTAssertEqual(audioURLs(kept), audioURLs(all))
        XCTAssertNoThrow(try Extraction.requireOriginalAudio(kept, sawDubbedAudio: false))
    }

    // What the remote extractor returned for jZGjUMVg-Y0: only the English AI dub.
    func testRemoteStreamsWithOnlyADubThrow() throws {
        let remote = try JSONDecoder().decode([RemoteStream].self, from: Data(#"""
        [
            {"url": "https://example.com/videoplayback?itag=140&xtags=acont%3Ddubbed-auto%3Alang%3Den-US", "itag": 140, "ext": "m4a", "audioCodec": "mp4a.40.2"},
            {"url": "https://example.com/videoplayback?itag=136", "itag": 136, "ext": "mp4", "videoCodec": "avc1.4d401f"}
        ]
        """#.utf8))
        let all = remote.map { try? YouTubeKit.Stream(remoteStream: $0) }.compactMap { $0 }
        let kept = Extraction.filterOutDubbedAudio(all)
        XCTAssertEqual(audioURLs(kept), [])
        XCTAssertThrowsError(try Extraction.requireOriginalAudio(kept, sawDubbedAudio: all.contains { $0.audioContent == .dubbed })) {
            XCTAssertEqual($0 as? YouTubeKitError, .originalAudioMissing)
        }
    }

}
