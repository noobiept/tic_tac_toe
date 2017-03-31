#if os(Linux)
    import Glibc
#else
    import Darwin
#endif


/*
 * Start the main game loop.
 */
func start()
{
help()

let options = [
    "q": quit,
    "r": restart,
    "h": help
]

while true
    {
    Board.draw()
    let input = readLine() ?? ""

    if let optionsFunc = options[ input ]
        {
        optionsFunc()
        }

    else
        {
        let result = Board.play( move: getPlayerMove( input: input ), value: Board.PositionValue.human )

            // only continue the game if the player made a valid move
        switch result
            {
            case .valid:
                _ = Board.play( move: getBotMove(), value: Board.PositionValue.bot )

            case .gameOver:
                restart()

            default:
                ()
            }
        }
    }
}


/*
 * Restart the game.
 */
func restart()
{
print( "Restarting.." )
Board.clear()
}


/*
 * Print a help message.
 */
func help()
{
print( "\nTic-Tac-Toe Game!" )
print( "Write the line and column you want to play (for example: \"1 3\" - first line and third column)." )
print( "Available commands: " )
print( "    q - Quit the program." )
print( "    r - Restart the game." )
print( "    h - Print this help message.\n" )
}


/*
 * Exit the program.
 */
func quit()
{
exit( 0 );
}


/*
 * Parse the user input, and return the played line/column.
 */
func getPlayerMove( input: String ) -> (line: Int, column: Int)?
{
let values = input.characters.flatMap { Int( String( $0 ) ) }

if values.count >= 2
    {
    let line = values[ 0 ]
    let column = values[ 1 ]

    if column >= 1 && column <= 3 &&
       line   >= 1 && line   <= 3
        {
            // user inputs values from 1 to 3, but we work in 0-based values
        return (line - 1, column - 1)
        }
    }

return nil
}


/*
 * Has the bot logic.
 * It tries to complete a row (to win the game or deny the win to the opponent) or if not possible then it plays at random.
 */
func getBotMove() -> (line: Int, column: Int)
{
    // see if there's lines with 2 in a row, so we can win the game
let botPositions = Board.getPositions( type: Board.PositionValue.bot )

for position in botPositions
    {
    if let playPosition = Board.getEmptyPosition( refLine: position.line, refColumn: position.column, value: Board.PositionValue.bot )
        {
        return playPosition
        }
    }

    // see if the opponent has 2 in a row, so we can deny it
let humanPositions = Board.getPositions( type: Board.PositionValue.human )

for position in humanPositions
    {
    if let playPosition = Board.getEmptyPosition( refLine: position.line, refColumn: position.column, value: Board.PositionValue.human )
        {
        return playPosition
        }
    }

    // if there's no values in a row, then just play at random
let availablePositions = Board.getPositions( type: Board.PositionValue.empty )

    // play on a random empty position
let index = getRandomInt( min: 0, max: availablePositions.count - 1 )

return availablePositions[ index ]
}


/*
 * Return a random integer between 'min' and 'max' (inclusive).
 */
func getRandomInt( min: Int, max: Int ) -> Int
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
func padRight( text: String, length: Int, padString: String = " " ) -> String
{
let diff = length - text.characters.count

if diff > 0
    {
    return text + String( repeating: padString, count: diff )
    }

return text
}


class Board
{
enum PositionValue: String {
    case human = "X"
    case bot = "O"
    case empty = " "
}

enum PlayResult {
    case valid      // valid play, but game not over yet, continue playing
    case invalid    // invalid play, try again
    case gameWon    // game was won by the last move
    case gameDraw   // game was drawn by the last move
    case gameOver   // game is already over
}

    // identifies which kind of line in a row was found
enum Row {
    case horizontal
    case vertical
    case leftDiagonal
    case rightDiagonal
    case none
}

static var BOARD:[[PositionValue]] = [
        [ .empty, .empty, .empty ],
        [ .empty, .empty, .empty ],
        [ .empty, .empty, .empty ],
    ]
static var GAME_OVER = false
static let SIZE = 3


/*
 * Draw the board with the current played positions as well.
 */
static func draw()
    {
    print( "\n   #   #   " )
    print( " \(BOARD[0][0].rawValue) # \(BOARD[0][1].rawValue) # \(BOARD[0][2].rawValue) " )
    print( "   #   #   " )
    print( "###########" )
    print( "   #   #   " )
    print( " \(BOARD[1][0].rawValue) # \(BOARD[1][1].rawValue) # \(BOARD[1][2].rawValue) " )
    print( "   #   #   " )
    print( "###########" )
    print( "   #   #   " )
    print( " \(BOARD[2][0].rawValue) # \(BOARD[2][1].rawValue) # \(BOARD[2][2].rawValue) " )
    print( "   #   #   \n" )
    }


/*
 * Make a play. After the play checks for the game ending condition.
 * Game ends when one of the players has 3 positions in a row (horizontal, vertical or diagonal).
 * Game can draw when there are no more valid plays left.
 */
static func play( move: (line: Int, column: Int)?, value: PositionValue ) -> PlayResult
    {
    if GAME_OVER
        {
        return PlayResult.gameOver
        }

    if move == nil
        {
        print( "Invalid play. The line/column values need to be between 1 and 3." )
        return PlayResult.invalid
        }

    let line = move!.line
    let column = move!.column

    if BOARD[ line ][ column ] == PositionValue.empty
        {
        BOARD[ line ][ column ] = value

        let displayValue = padRight( text: "\(value)", length: 5 )
        print( "\(displayValue) played line \(line + 1) and column \(column + 1)." )

            // check if game is over
        if Board.inARow( line: line, column: column, howMany: SIZE, value: value ) != .none
            {
            print( "\n\(value) won!\nPress the enter key to restart." )
            GAME_OVER = true

            return PlayResult.gameWon
            }

            // check if game draw
        for line in 0 ..< SIZE
            {
            for column in 0 ..< SIZE
                {
                    // not over yet, continue playing
                if BOARD[ line ][ column ] == PositionValue.empty
                    {
                    return PlayResult.valid
                    }
                }
            }

        print( "\nGame Drawn!\nPress the enter key to restart." )
        GAME_OVER = true

        return PlayResult.gameDraw
        }

    else
        {
        print( "Position already taken." )
        return PlayResult.invalid
        }
    }


/*
 * Check if there's 2/3 positions in a row of the same value. When checking for 2, the other position needs to be empty to be considered.
 */
static func inARow( line: Int, column: Int, howMany: Int, value: PositionValue ) -> Row
    {
        // check in same line
    var count = 0
    var skip = false

    for a in 0 ..< SIZE
        {
        let currentValue = BOARD[ line ][ a ]
        if currentValue == value
            {
            count += 1
            }

        else if currentValue != .empty
            {
            skip = true
            break
            }
        }

        // there are elements in a row of the same value (the amount specified)
    if !skip && count >= howMany
        {
        return Row.horizontal
        }

        // check in same column
    count = 0
    skip = false

    for a in 0 ..< SIZE
        {
        let currentValue = BOARD[ a ][ column ]
        if currentValue == value
            {
            count += 1
            }

        else if currentValue != .empty
            {
            skip = true
            break
            }
        }

    if !skip && count >= howMany
        {
        return Row.vertical
        }

        // check in diagonal
    if column == line
        {
        count = 0
        skip = false

        for a in 0 ..< SIZE
            {
            let currentValue = BOARD[ a ][ a ]
            if currentValue == value
                {
                count += 1
                }

            else if currentValue != .empty
                {
                skip = true
                break
                }
            }

        if !skip && count >= howMany
            {
            return Row.leftDiagonal
            }
        }

        // check other diagonal
    count = 0
    skip = false

    for a in 0 ..< SIZE
        {
        let currentValue = BOARD[ a ][ SIZE - 1 - a ]
        if currentValue == value
            {
            count += 1
            }

        else if currentValue != .empty
            {
            skip = true
            break
            }
        }

    if !skip && count >= howMany
        {
        return Row.rightDiagonal
        }

    return Row.none
    }


/*
 * Returns a list with all the positions of that position type.
 */
static func getPositions( type: PositionValue ) -> [(line: Int, column: Int)]
    {
    var positions: [(line: Int, column: Int)] = []

    for line in 0 ..< BOARD.count
        {
        for column in 0 ..< BOARD[ line ].count
            {
            if BOARD[ line ][ column ] == type
                {
                positions.append( (line, column) )
                }
            }
        }

    return positions
    }


/*
 * Find the empty position needed to complete a row.
 */
static func getEmptyPosition( refLine: Int, refColumn: Int, value: PositionValue ) -> (line: Int, column: Int)?
    {
    switch Board.inARow( line: refLine, column: refColumn, howMany: 2, value: value )
        {
            // find the empty position
        case .horizontal:
            for column in 0 ..< SIZE
                {
                if BOARD[ refLine ][ column ] == PositionValue.empty
                    {
                    return (refLine, column)
                    }
                }

        case .vertical:
            for line in 0 ..< SIZE
                {
                if BOARD[ line ][ refColumn ] == PositionValue.empty
                    {
                    return (line, refColumn)
                    }
                }

        case .leftDiagonal:
            for a in 0 ..< SIZE
                {
                if BOARD[ a ][ a ] == PositionValue.empty
                    {
                    return (a, a)
                    }
                }

        case .rightDiagonal:
            for a in 0 ..< SIZE
                {
                if BOARD[ a ][ SIZE - 1 - a ] == PositionValue.empty
                    {
                    return (a, SIZE - 1 - a)
                    }
                }

        default:
            return nil
        }

    return nil
    }


/*
 * Clear/reset the board.
 */
static func clear()
    {
    for line in 0 ..< BOARD.count
        {
        for column in 0 ..< BOARD[ line ].count
            {
            BOARD[ line ][ column ] = PositionValue.empty
            }
        }

    GAME_OVER = false
    }
}


    // start the game!
start()