import Foundation
import Rainbow


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
Print.system( "Restarting.." )
Board.clear()
}


/*
 * Print a help message.
 */
func help()
{
Print.system( "\nTic-Tac-Toe Game!" )
Print.system( "Write the line and column you want to play (for example: \"1 3\" - first line and third column)." )
Print.system( "Available commands: " )
Print.system( "    q - Quit the program." )
Print.system( "    r - Restart the game." )
Print.system( "    h - Print this help message.\n" )
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
let values = input.flatMap { Int( String( $0 ) ) }

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
let index = Utilities.getRandomInt( min: 0, max: availablePositions.count - 1 )

return availablePositions[ index ]
}


    // start the game!
start()
