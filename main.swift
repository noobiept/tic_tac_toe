import Glibc


func start()
{
print( "Hello there!" )
help()

let map = Map()
let options = [
    "q": quit,
    "r": restart,
    "h": help
]

while true
    {
    map.draw()

    let input = readLine( stripNewline: true ) ?? ""

    if let optionsFunc = options[ input ]
        {
        optionsFunc()
        }

    else
        {
        var (column, line) = getPlayerMove( input )

            // user inputs values from 1 to 3, but we work in 0-based values
        if map.play( column - 1, line - 1 )
            {
                // only continue the game if the player made a valid move
            (column, line) = getBotMove()
            map.play( column, line )

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

}


func help()
{
print( "Write the line and column you want to play (for example: \"1 3\" - first line and third column)." )
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
var MAP = [
        [ 0, 0, 0 ],
        [ 0, 0, 0 ],
        [ 0, 0, 0 ],
    ]

func draw()
    {
    for line in 0 ..< MAP.count
        {
        let lineArray = MAP[ line ]

        for column in 0 ..< lineArray.count
            {
            let value = lineArray[ column ]
            var valueSymbol = " "

            if value < 0
                {
                valueSymbol = "X"
                }

            else if value > 0
                {
                valueSymbol = "O"
                }

            print( valueSymbol, terminator: "" )

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

/**
 * Make a play. Returns whether the play was valid or not.
 */
func play( column: Int, _ line: Int ) -> Bool
    {
    if column < 0 || column > 2 ||
       line   < 0 || line   > 2
        {
        print( "Invalid play." )
        return false
        }

    if MAP[ line ][ column ] == 0
        {
        MAP[ line ][ column ] = 1
        print( "Played \(line + 1) \(column + 1) line/column." )
        return true
        }

    else
        {
        print( "Position already taken." )
        return false
        }
    }
}


start()
