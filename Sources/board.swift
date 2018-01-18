class Board
{
enum PositionValue: String {
    case player = "X"
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
    Print.board( "\n   #   #   " )
    Print.board( " \(BOARD[0][0].rawValue) # \(BOARD[0][1].rawValue) # \(BOARD[0][2].rawValue) " )
    Print.board( "   #   #   " )
    Print.board( "###########" )
    Print.board( "   #   #   " )
    Print.board( " \(BOARD[1][0].rawValue) # \(BOARD[1][1].rawValue) # \(BOARD[1][2].rawValue) " )
    Print.board( "   #   #   " )
    Print.board( "###########" )
    Print.board( "   #   #   " )
    Print.board( " \(BOARD[2][0].rawValue) # \(BOARD[2][1].rawValue) # \(BOARD[2][2].rawValue) " )
    Print.board( "   #   #   \n" )
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
        Print.error( "Invalid play. The line/column values need to be between 1 and 3." )
        return PlayResult.invalid
        }

    let line = move!.line
    let column = move!.column

    if BOARD[ line ][ column ] == PositionValue.empty
        {
        BOARD[ line ][ column ] = value

        let valueStr = String( describing: value ).capitalized
        let displayValue = Utilities.padRight( text: valueStr, length: 6 )
        Print.system( "\(displayValue) (\(value.rawValue)) - line \(line + 1) / column \(column + 1)." )

            // check if game is over
        if Board.inARow( line: line, column: column, howMany: SIZE, value: value ) != .none
            {
            if value == PositionValue.player
                {
                Print.victory( "\nYou've won!\nPress the 'enter' key to restart." )
                }

            else
                {
                Print.defeat( "\nYou've lost!\nPress the 'enter' key to restart." )
                }

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

        Print.draw( "\nGame Drawn!\nPress the 'enter' key to restart." )
        GAME_OVER = true

        return PlayResult.gameDraw
        }

    else
        {
        Print.error( "Position already taken." )
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
