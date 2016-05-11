import Glibc

let map = [
    [ 0, 0, 0 ],
    [ 0, 0, 0 ],
    [ 0, 0, 0 ],
]

func start()
{
print( "Hello there!" )

while true
    {
    draw()
    print( "Write the line and column you want to play (for example: \"1 3\" - first line and third column)." )
    let input = readLine( stripNewline: true )

    if input == "q"
        {
        break
        }

    var (column, line) = getPlayerMove( input! )
    play( column, line )

    (column, line) = getBotMove()
    play( column, line )

    if ( checkGameEnd() )
        {
        restart()
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


func draw()
{
for line in 0 ..< map.count
    {
    let lineArray = map[ line ]

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
    if line + 1 != map.count
        {
        print( "#####" )
        }
    }
}


func getPlayerMove( input: String ) -> (Int, Int)
{
let values = input.characters.split{ $0 == " " }.map( String.init )

let line = Int( values[ 0 ] ) ?? -1
let column = Int( values[ 1 ] ) ?? -1

return (column, line)
}


func getBotMove() -> (Int, Int)
{
let column = getRandomInt( 1, 3 )
let line = getRandomInt( 1, 3 )

return (column, line)
}


func play( column: Int, _ line: Int )
{
if column < 1 || column > 3 ||
   line   < 1 || line   > 3
    {
    return
    }

print( "Played \(line) \(column) line/column." )
}


func getRandomInt( min: Int, _ max: Int ) -> Int
{
return Int( random() % (max - min + 1) ) + min
}


start()
