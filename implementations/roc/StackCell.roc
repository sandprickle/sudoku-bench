interface StackCell
    exposes [Cell, emptyInit, isFixed, isEmpty, isPossible]
    imports [Number.{ Number }]

Cell := U16 implements [Eq, Hash]

## An empty cell with all nubmers set as possible
emptyInit : Cell
emptyInit = @Cell 0b0_00_1001_111111111

masks = {
    isFixed: 0b1_000000_000000000,
    one: 0b0_00_0000_000000001,
    two: 0b0_00_0000_000000010,
    three: 0b0_00_0000_000000100,
    four: 0b0_00_0000_000001000,
    five: 0b0_00_0000_000010000,
    six: 0b0_00_0000_000100000,
    seven: 0b0_00_0000_001000000,
    eight: 0b0_00_0000_010000000,
    nine: 0b0_00_0000_100000000,
    count: 0b0_00_1111_000000000,
}

type : Cell -> [Fixed Number, Empty]
type = \@Cell bits ->


isFixed : Cell -> Bool
isFixed = \@Cell bits ->
    mask = masks.isFixed
    Num.bitwiseAnd mask bits == mask

isEmpty : Cell -> Bool
isEmpty = \cell ->
    isFixed cell |> Bool.not

isPossible : Cell, Number -> Bool
isPossible = \cell, num ->
    when num is
        One -> oneIsPossible cell
        Two -> twoIsPossible cell
        Three -> threeIsPossible cell
        Four -> fourIsPossible cell
        Five -> fiveIsPossible cell
        Six -> sixIsPossible cell
        Seven -> sevenIsPossible cell
        Eight -> eightIsPossible cell
        Nine -> nineIsPossible cell

oneIsPossible : Cell -> Bool
oneIsPossible = \@Cell bits ->
    mask = masks.one
    Num.bitwiseAnd mask bits == mask

twoIsPossible : Cell -> Bool
twoIsPossible = \@Cell bits ->
    mask = masks.two
    Num.bitwiseAnd mask bits == mask

threeIsPossible : Cell -> Bool
threeIsPossible = \@Cell bits ->
    mask = masks.three
    Num.bitwiseAnd mask bits == mask

fourIsPossible : Cell -> Bool
fourIsPossible = \@Cell bits ->
    mask = masks.four
    Num.bitwiseAnd mask bits == mask

fiveIsPossible : Cell -> Bool
fiveIsPossible = \@Cell bits ->
    mask = masks.five
    Num.bitwiseAnd mask bits == mask

sixIsPossible : Cell -> Bool
sixIsPossible = \@Cell bits ->
    mask = masks.six
    Num.bitwiseAnd mask bits == mask

sevenIsPossible : Cell -> Bool
sevenIsPossible = \@Cell bits ->
    mask = masks.seven
    Num.bitwiseAnd mask bits == mask

eightIsPossible : Cell -> Bool
eightIsPossible = \@Cell bits ->
    mask = masks.eight
    Num.bitwiseAnd mask bits == mask

nineIsPossible : Cell -> Bool
nineIsPossible = \@Cell bits ->
    mask = masks.nine
    Num.bitwiseAnd mask bits == mask

countPossible : Cell -> U8
countPossible = \@Cell bits ->
    mask = masks.count
    bits
    |> Num.bitwiseAnd mask
    |> Num.shiftRightBy 9
    |> Num.toU8

expect (countPossible emptyInit == 9)
expect (@Cell 0 |> countPossible == 0)
