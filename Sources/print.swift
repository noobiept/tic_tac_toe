/**
 * Print a line of text, with a specific color, depending on the type of message.
 */
class Print
{
/**
 * Print a line of the board.
 */
static func board( _ text: String )
    {
    print( text.yellow )
    }


/**
 * Print a system message.
 */
static func system( _ text: String )
    {
    print( text.blue )
    }


/**
 * Print an error message.
 */
static func error( _ text: String )
    {
    print( text.lightRed )
    }


/**
 * Print the victory message.
 */
static func victory( _ text: String )
    {
    print( text.green )
    }


/**
 * Print the defeat message.
 */
static func defeat( _ text: String )
    {
    print( text.red )
    }


/**
 * Print the draw message.
 */
static func draw( _ text: String )
    {
    print( text.yellow )
    }
}