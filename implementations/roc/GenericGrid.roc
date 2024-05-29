module [
    Grid,
    init,
    fromCsvStr,
    get,
    set,
    findFirstCoord,
    sufficientHints,
]

import Coord exposing [Coord]

## A 9 x 9 Sudoku Grid
Grid cell := List cell implements [Eq]

init : cell -> Grid cell
init = \defaultCell ->
    List.repeat defaultCell 81 |> @Grid

## Create a Grid from a List of values.
## Pad or truncate the list if it is not the correct length.
fromList : cell -> (List cell -> Grid cell)
fromList = \defaultCell ->
    \inputList ->
        list =
            if List.len inputList > 81 then
                List.takeFirst inputList 81
            else if List.len inputList < 81 then
                List.concat
                    inputList
                    (List.repeat defaultCell (81 - List.len inputList))
            else
                inputList

        @Grid list

fromCsvStr : cell, (Str -> cell) -> (Str -> Grid cell)
fromCsvStr = \defaultCell, cellFromStr ->
    \str ->
        str
        |> Str.split "\n"
        |> List.map (\row -> Str.split row ",")
        |> List.map
            (\row -> List.map
                    row
                    cellFromStr
            )
        |> List.join
        |> (fromList defaultCell)

## **curried**
##
## Takes a default `cell`, and returns a function that takes a
## `Grid` and a `Coord` and returns a `cell`
get : cell -> (Grid cell, Coord -> cell)
get = \defaultCell ->
    \@Grid cells, coord ->
        cells
        |> List.get (Coord.toU64 coord)
        |> Result.withDefault defaultCell

set : Grid cell, Coord, cell -> Grid cell
set = \@Grid cells, coord, value ->
    cells
    |> List.set (Coord.toU64 coord) value
    |> @Grid

findFirstCoord : Grid cell, (cell -> Bool) -> Result Coord [NotFound]
findFirstCoord = \@Grid cells, fn ->
    List.findFirstIndex cells fn |> Result.map Coord.fromInt

## **curried**
##
## Takes a function that determines whether a `cell` is empty or fixed, and
## returns a function that determines whether a `Grid` has at least 17 clues
sufficientHints : (cell -> [Empty, Fixed]) -> (Grid cell -> Bool)
sufficientHints = \cellStatus ->
    \@Grid cells ->
        filledCells = List.countIf
            cells
            (\cell ->
                when cellStatus cell is
                    Empty -> Bool.false
                    Fixed -> Bool.true

            )

        filledCells >= 17

isLegal : Grid cell -> Bool

# HELPERS

houseRange = { start: At 0, end: At 8 }

rowCoords : U8 -> List Coord
rowCoords = \rowNum ->
    getCoord = \colNum ->
        Coord.fromRowCol rowNum colNum

    List.map
        (List.range houseRange)
        getCoord

colCoords : U8 -> List Coord
colCoords = \colNum ->
    getCoord = \rowNum ->
        Coord.fromRowCol rowNum colNum

    List.map
        (List.range houseRange)
        getCoord

boxCoords : U8 -> List Coord
boxCoords = \boxNum ->
    boxRange = { start: At 0, end: At 2 }

    boxRow =
        boxNum // 3

    boxCol =
        boxNum % 3

    yCoords =
        List.map
            (List.range boxRange)
            (\n -> (3 * boxRow) + n)

    xCoords =
        List.map
            (List.range boxRange)
            (\n -> (3 * boxCol) + n)

    coordsInRow = \yCoord ->
        List.map
            xCoords
            (\xCoord -> Coord.fromXY xCoord yCoord)

    List.map yCoords coordsInRow |> List.join

getRow : Grid cell, U8 -> List cell
getRow = \grid, rowNum ->
    List.map
        (rowCoords rowNum)
        (\coord -> get grid coord)

getCol : Grid cell, U8 -> List cell
getCol = \grid, colNum ->
    List.map
        (colCoords colNum)
        (\coord -> get grid coord)

getBox : Grid cell, U8 -> List cell
getBox = \grid, boxNum ->
    List.map
        (boxCoords boxNum)
        (\coord -> get grid coord)

toRows : Grid cell -> List (List cell)
toRows = \grid ->
    List.map
        (List.range houseRange)
        (\n -> getRow grid n)

toCols : Grid cell -> List (List cell)
toCols = \grid ->
    List.map
        (List.range houseRange)
        (\n -> getCol grid n)

toBoxes : Grid cell -> List (List cell)
toBoxes = \grid ->
    List.map
        (List.range houseRange)
        (\n -> getBox grid n)
