import Glibc


/*
 * Start the main game loop.
 */
func start()
{
help()

let options = [
    "q": quit,
    "r": { restart( false ) },
    "h": help
]

while true
    {
    Board.draw()
    let input = readLine( stripNewline: true ) ?? ""

    if let optionsFunc = options[ input ]
        {
        optionsFunc()
        }

    else
        {
        var (line, column) = getPlayerMove( input )

        let result = Board.play( column, line, Board.PositionValue.Human )

            // only continue the game if the player made a valid move
        switch result
            {
            case .GameWon:
                print( "Player Won!" )
                restart()

            case .GameDraw:
                print( "Game Drawn!" )
                restart()

            case .Valid:
                (line, column) = getBotMove()
                let result = Board.play( column, line, Board.PositionValue.Bot )

                switch result
                    {
                    case .GameWon:
                        print( "Bot Won!" )
                        restart()

                    case .GameDraw:
                        print( "Game Drawn!" )
                        restart()

                    default:
                        ()
                    }

            default:
                ()
            }
        }
    }
}


/*
 * Restart the game.
 * It can optionally draw or not the board before clearing the game (to see how the game ended).
 */
func restart( drawBoard: Bool = true )
{
if drawBoard
    {
    Board.draw()
    }

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
func getPlayerMove( input: String ) -> (line: Int, column: Int)
{
let values = input.characters.split{ $0 == " " }.map( String.init )

var line = -1
var column = -1

if values.count >= 2
    {
    line = Int( values[ 0 ] ) ?? -1
    column = Int( values[ 1 ] ) ?? -1
    }

    // user inputs values from 1 to 3, but we work in 0-based values
return (line - 1, column - 1)
}


/*
 * Has the bot logic.
 * It tries to complete a row (to win the game or deny the win to the opponent) or if not possible then it plays at random.
 */
func getBotMove() -> (line: Int, column: Int)
{
    // see if there's lines with 2 in a row, so we can win the game
let botPositions = Board.getPositions( Board.PositionValue.Bot )

for position in botPositions
    {
    if let playPosition = Board.getEmptyPosition( position.line, position.column, Board.PositionValue.Bot )
        {
        return playPosition
        }
    }

    // see if the opponent has 2 in a row, so we can deny it
let humanPositions = Board.getPositions( Board.PositionValue.Human )

for position in humanPositions
    {
    if let playPosition = Board.getEmptyPosition( position.line, position.column, Board.PositionValue.Human )
        {
        return playPosition
        }
    }

    // if there's no values in a row, then just play at random
let availablePositions = Board.getPositions( Board.PositionValue.Empty )

    // play on a random empty position
let index = getRandomInt( 0, availablePositions.count - 1 )

return availablePositions[ index ]
}


/*
 * Return a random integer between 'min' and 'max' (inclusive).
 */
func getRandomInt( min: Int, _ max: Int ) -> Int
{
return Int( random() % (max - min + 1) ) + min
}


class Board
{
enum PositionValue: String {
    case Human = "X"
    case Bot = "O"
    case Empty = " "
}

enum PlayResult {
    case Valid      // valid play, but game not over yet, continue playing
    case Invalid    // invalid play, try again
    case GameWon    // game was won by the last move
    case GameDraw   // game was drawn by the last move
}

    // identifies which kind of line in a row was found
enum Row {
    case Horizontal
    case Vertical
    case LeftDiagonal
    case RightDiagonal
    case None
}

static var BOARD:[[PositionValue]] = [
        [ .Empty, .Empty, .Empty ],
        [ .Empty, .Empty, .Empty ],
        [ .Empty, .Empty, .Empty ],
    ]
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
static func play( column: Int, _ line: Int, _ value: PositionValue ) -> PlayResult
    {
    if column < 0 || column > 2 ||
       line   < 0 || line   > 2
        {
        print( "Invalid play. The line/column values need to be between 1 and 3." )
        return PlayResult.Invalid
        }

    if BOARD[ line ][ column ] == PositionValue.Empty
        {
        BOARD[ line ][ column ] = value
        print( "\(value) Played \(line + 1) \(column + 1) line/column." )

            // check if game is over
        if Board.inARow( line, column, SIZE, value ) != .None
            {
            return PlayResult.GameWon
            }

            // check if game draw
        for line in 0 ..< SIZE
            {
            for column in 0 ..< SIZE
                {
                    // not over yet, continue playing
                if BOARD[ line ][ column ] == PositionValue.Empty
                    {
                    return PlayResult.Valid
                    }
                }
            }

        return PlayResult.GameDraw
        }

    else
        {
        print( "Position already taken." )
        return PlayResult.Invalid
        }
    }


/*
 * Check if there's 2/3 positions in a row of the same value.
 */
static func inARow( line: Int, _ column: Int, _ howMany: Int, _ value: PositionValue ) -> Row
    {
        // check in same line
    var count = 0

    for a in 0 ..< SIZE
        {
        if BOARD[ line ][ a ] == value
            {
            count += 1
            }

            // there are elements in a row of the same value (the amount specified)
        if count == howMany
            {
            return Row.Horizontal
            }
        }

        // check in same column
    count = 0

    for a in 0 ..< SIZE
        {
        if BOARD[ a ][ column ] == value
            {
            count += 1
            }

        if count == howMany
            {
            return Row.Vertical
            }
        }

        // check in diagonal
    if column == line
        {
        count = 0

        for a in 0 ..< SIZE
            {
            if BOARD[ a ][ a ] == value
                {
                count += 1
                }

            if count == howMany
                {
                return Row.LeftDiagonal
                }
            }
        }

        // check other diagonal
    count = 0

    for a in 0 ..< SIZE
        {
        if BOARD[ a ][ SIZE - 1 - a ] == value
            {
            count += 1
            }

        if count == howMany
            {
            return Row.RightDiagonal
            }
        }

    return Row.None
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
static func getEmptyPosition( refLine: Int, _ refColumn: Int, _ value: PositionValue ) -> (line: Int, column: Int)?
    {
    switch Board.inARow( refLine, refColumn, 2, value )
        {
            // find the empty position
        case .Horizontal:
            for column in 0 ..< SIZE
                {
                if BOARD[ refLine ][ column ] == PositionValue.Empty
                    {
                    return (refLine, column)
                    }
                }

        case .Vertical:
            for line in 0 ..< SIZE
                {
                if BOARD[ line ][ refColumn ] == PositionValue.Empty
                    {
                    return (line, refColumn)
                    }
                }

        case .LeftDiagonal:
            for a in 0 ..< SIZE
                {
                if BOARD[ a ][ a ] == PositionValue.Empty
                    {
                    return (a, a)
                    }
                }

        case .RightDiagonal:
            for a in 0 ..< SIZE
                {
                if BOARD[ a ][ SIZE - 1 - a ] == PositionValue.Empty
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
            BOARD[ line ][ column ] = PositionValue.Empty
            }
        }
    }
}


    // start the game!
start()
