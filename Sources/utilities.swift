import Foundation

class Utilities {
    /*
     * Return a new string that is padded with the given character at the end/right, if needed (depending on the specified length).
     */
    static func padRight(text: String, length: Int, padString: String = " ") -> String {
        let diff = length - text.count

        if diff > 0 {
            return text + String(repeating: padString, count: diff)
        }

        return text
    }
}
