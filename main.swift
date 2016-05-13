import Glibc


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

    let input = readLine( stripNewline: true ) ?? ""

    if let optionsFunc = options[ input ]
        {
        optionsFunc()
        }

    else
        {
        var (column, line) = getPlayerMove( input )

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
                (column, line) = getBotMove()
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


func restart()
{
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


func quit()
{
exit( 0 );
}


func getPlayerMove( input: String ) -> (Int, Int)
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
return (column - 1, line - 1)
}


func getBotMove() -> (Int, Int)
{
let availablePositions = Board.getPositions( Board.PositionValue.Empty )

    // play on a random empty position
let index = getRandomInt( 0, availablePositions.count - 1 )

return availablePositions[ index ]
}


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

static var BOARD:[[PositionValue]] = [
        [ .Empty, .Empty, .Empty ],
        [ .Empty, .Empty, .Empty ],
        [ .Empty, .Empty, .Empty ],
    ]
static let SIZE = 3

static func draw()
    {
    for line in 0 ..< BOARD.count
        {
        let lineArray = BOARD[ line ]

        for column in 0 ..< lineArray.count
            {
            let value = lineArray[ column ]

            print( value.rawValue, terminator: "" )

            if column + 1 != lineArray.count
                {
                print( "#", terminator: "" )
                }

            else
                {
                print()
                }
            }

            // if not the last element
        if line + 1 != BOARD.count
            {
            print( "#####" )
            }
        }
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
            // check in same line
        for a in 0 ..< SIZE
            {
            if BOARD[ line ][ a ] != value
                {
                break
                }

                // means all elements in this line are of the same value
            if a + 1 == SIZE
                {
                return PlayResult.GameWon
                }
            }

            // check in same column
        for a in 0 ..< SIZE
            {
            if BOARD[ a ][ column ] != value
                {
                break
                }

            if a + 1 == SIZE
                {
                return PlayResult.GameWon
                }
            }

            // check in diagonal
        if column == line
            {
            for a in 0 ..< SIZE
                {
                if BOARD[ a ][ a ] != value
                    {
                    break
                    }

                if a + 1 == SIZE
                    {
                    return PlayResult.GameWon
                    }
                }
            }

            // check other diagonal
        for a in 0 ..< SIZE
            {
            if BOARD[ a ][ SIZE - 1 - a ] != value
                {
                break
                }

            if a + 1 == SIZE
                {
                return PlayResult.GameWon
                }
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

static func getPositions( type: PositionValue ) -> [(Int, Int)]
    {
    var positions: [(Int, Int)] = []

    for line in 0 ..< BOARD.count
        {
        for column in 0 ..< BOARD[ line ].count
            {
            if BOARD[ line ][ column ] == type
                {
                positions.append( (column, line) )
                }
            }
        }

    return positions
    }

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
