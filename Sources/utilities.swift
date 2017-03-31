import Foundation


class Utilities
{
/*
 * Return a random integer between 'min' and 'max' (inclusive).
 */
static func getRandomInt( min: Int, max: Int ) -> Int
    {
    let diff = max - min + 1

    #if os(Linux)
        return min + Int( random() % diff )
    #else
        return min + Int( arc4random_uniform( UInt32( diff ) ) )
    #endif
    }


/*
 * Return a new string that is padded with the given character at the end/right, if needed (depending on the specified length).
 */
static func padRight( text: String, length: Int, padString: String = " " ) -> String
    {
    let diff = length - text.characters.count

    if diff > 0
        {
        return text + String( repeating: padString, count: diff )
        }

    return text
    }
}