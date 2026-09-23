import AVFoundation
import Foundation

@MainActor
final class ChimeService {
    enum Cue: String, CaseIterable, Identifiable {
        case invitation = "Pause suggestion"
        case pause = "Time for a pause"
        case returnToWork = "Ready to continue"
        var id: String { rawValue }

        var notes: [(Double, Double)] {
            switch self {
            case .invitation: return [(0, 660)]
            case .pause: return [(0, 660), (0.38, 880)]
            case .returnToWork: return [(0, 880)]
            }
        }
    }

    private var player: AVAudioPlayer?

    func stop() { player?.stop(); player = nil }

    func play(_ cue: Cue, volume: Double) throws {
        stop()
        let sound = try AVAudioPlayer(data: Self.audioData(for: cue))
        sound.volume = Float(min(max(volume, 0), 1))
        guard sound.play() else {
            throw NSError(domain: "Rhythm.Chime", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "The audio output could not play the chime."])
        }
        player = sound
    }

    // Short, locally synthesized bell tones with a soft attack and decay.
    // Playback uses the current macOS audio output, including headphones.
    static func audioData(for cue: Cue) -> Data {
        let rate = 44100
        let duration = 1.6
        let count = Int((cue.notes.last!.0 + duration) * Double(rate))
        var pcm = Data(capacity: count * 2)
        for index in 0..<count {
            let time = Double(index) / Double(rate)
            var sample = 0.0
            for (start, frequency) in cue.notes {
                let t = time - start
                if t >= 0 && t < duration {
                    let envelope = min(t / 0.025, 1) * exp(-4 * t) * min((duration - t) / 0.1, 1)
                    sample += 0.24 * envelope * (sin(2 * .pi * frequency * t)
                        + 0.18 * sin(2 * .pi * frequency * 2 * t))
                }
            }
            var value = Int16(max(-1, min(1, sample)) * Double(Int16.max)).littleEndian
            withUnsafeBytes(of: &value) { pcm.append(contentsOf: $0) }
        }
        var data = Data()
        func text(_ text: String) { data.append(contentsOf: text.utf8) }
        func number<T: FixedWidthInteger>(_ value: T) {
            var value = value.littleEndian
            withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
        }
        text("RIFF"); number(UInt32(36 + pcm.count)); text("WAVEfmt ")
        number(UInt32(16)); number(UInt16(1)); number(UInt16(1))
        number(UInt32(rate)); number(UInt32(rate * 2)); number(UInt16(2)); number(UInt16(16))
        text("data"); number(UInt32(pcm.count)); data.append(pcm)
        return data
    }
}
