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
    Map.draw()

    let input = readLine( stripNewline: true ) ?? ""

    if let optionsFunc = options[ input ]
        {
        optionsFunc()
        }

    else
        {
        var (column, line) = getPlayerMove( input )

            // user inputs values from 1 to 3, but we work in 0-based values
        if Map.play( column - 1, line - 1, Map.PositionValue.Human )
            {
                // only continue the game if the player made a valid move
            (column, line) = getBotMove()
            Map.play( column, line, Map.PositionValue.Bot )

            if ( checkGameEnd() )
                {
                restart()
                }
            }
        }
    }
}


func checkGameEnd() -> Bool
{
return false
}


func restart()
{
Map.clear()
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

return (column, line)
}


func getBotMove() -> (Int, Int)
{
let column = getRandomInt( 0, 2 )
let line = getRandomInt( 0, 2 )

return (column, line)
}


func getRandomInt( min: Int, _ max: Int ) -> Int
{
return Int( random() % (max - min + 1) ) + min
}


class Map
{
enum PositionValue: String {
    case Human = "X"
    case Bot = "O"
    case Empty = " "
}

static var MAP:[[PositionValue]] = [
        [ .Empty, .Empty, .Empty ],
        [ .Empty, .Empty, .Empty ],
        [ .Empty, .Empty, .Empty ],
    ]

static func draw()
    {
    for line in 0 ..< MAP.count
        {
        let lineArray = MAP[ line ]

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
        if line + 1 != MAP.count
            {
            print( "#####" )
            }
        }
    }

/*
 * Make a play. Returns whether the play was valid or not.
 */
static func play( column: Int, _ line: Int, _ position: PositionValue ) -> Bool
    {
    if column < 0 || column > 2 ||
       line   < 0 || line   > 2
        {
        print( "Invalid play. The line/column values need to be between 1 and 3." )
        return false
        }

    if MAP[ line ][ column ] == PositionValue.Empty
        {
        MAP[ line ][ column ] = position
        print( "\(position) Played \(line + 1) \(column + 1) line/column." )
        return true
        }

    else
        {
        print( "Position already taken." )
        return false
        }
    }

static func clear()
    {
    for line in 0 ..< MAP.count
        {
        for column in 0 ..< MAP[ line ].count
            {
            MAP[ line ][ column ] = PositionValue.Empty
            }
        }
    }
}

    // start the game!
start()
