import Foundation
import AudioToolbox

class SystemTones: NSObject, Tones {
    func play(forDigitDigit digit: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let char = digit.first else {
            return
        }
        
        guard let tone = toTone(char) else {
            return
        }

        AudioServicesPlaySystemSoundWithCompletion(tone, nil)
    }
    
    private func toTone(_ char: Character) -> UInt32? {
        switch char {
            case "0": return 1200
            case "1": return 1201
            case "2": return 1202
            case "3": return 1203
            case "4": return 1204
            case "5": return 1205
            case "6": return 1206
            case "7": return 1207
            case "8": return 1208
            case "9": return 1209
            case "*": return 1210
            case "#": return 1211
            default: return nil
        }
    }
}
