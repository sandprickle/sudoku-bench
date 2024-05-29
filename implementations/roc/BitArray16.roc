module [
    BitArray16,
    Index,
    indexFromInt,
    fromU16,
    get,
    set,
    initSet,
    initUnset,
]

## A 2-byte array of bits
BitArray16 := U16 implements [Eq, Hash]

## A BitArray16 with all bits unset
initUnset : BitArray16
initUnset = @BitArray16 0

## A BitArray16 with all bits set
initSet : BitArray16
initSet = @BitArray16 0b1111_1111_1111_1111

fromU16 : U16 -> BitArray16
fromU16 = \num -> @BitArray16 num

get : BitArray16, Index -> [Set, Unset]
get = \@BitArray16 bits, index ->
    mask = indexToMask index
    offset = indexToU8 index
    if
        bits
        |> Num.bitwiseAnd mask
        |> Num.shiftRightBy offset
        == 0
    then
        Unset
    else
        Set

expect (fromU16 1 |> get Index0 == Set)
expect (fromU16 0 |> get Index0 == Unset)

set : BitArray16, Index, [Set, Unset] -> BitArray16
set = \@BitArray16 bits, index, value ->
    offset = indexToU8 index
    mask = Num.shiftLeftBy 1 offset

    result =
        when value is
            Set ->
                Num.bitwiseOr bits mask

            Unset ->
                Num.bitwiseAnd
                    bits
                    (Num.bitwiseXor 0b1111_1111_1111_1111 mask)

    @BitArray16 result

expect
    lsbSet = initUnset |> set Index0 Set
    lsbSet == @BitArray16 1

expect
    test = @BitArray16 3 |> set Index0 Unset
    test == @BitArray16 2

## Unfinished do not use
walk : BitArray16, state, (state, [Set, Unset] -> state) -> state
walk = \@BitArray16 bits, state, f ->
    state

Index : [
    Index0,
    Index1,
    Index2,
    Index3,
    Index4,
    Index5,
    Index6,
    Index7,
    Index8,
    Index9,
    Index10,
    Index11,
    Index12,
    Index13,
    Index14,
    Index15,
]

indexToMask : Index -> U16
indexToMask = \index ->
    when index is
        Index0 -> 0b0000_0000_0000_0001
        Index1 -> 0b0000_0000_0000_0010
        Index2 -> 0b0000_0000_0000_0100
        Index3 -> 0b0000_0000_0000_1000
        Index4 -> 0b0000_0000_0001_0000
        Index5 -> 0b0000_0000_0010_0000
        Index6 -> 0b0000_0000_0100_0000
        Index7 -> 0b0000_0000_1000_0000
        Index8 -> 0b0000_0001_0000_0000
        Index9 -> 0b0000_0010_0000_0000
        Index10 -> 0b0000_0100_0000_0000
        Index11 -> 0b0000_1000_0000_0000
        Index12 -> 0b0001_0000_0000_0000
        Index13 -> 0b0010_0000_0000_0000
        Index14 -> 0b0100_0000_0000_0000
        Index15 -> 0b1000_0000_0000_0000

indexToU8 : Index -> U8
indexToU8 = \index ->
    when index is
        Index0 -> 0
        Index1 -> 1
        Index2 -> 2
        Index3 -> 3
        Index4 -> 4
        Index5 -> 5
        Index6 -> 6
        Index7 -> 7
        Index8 -> 8
        Index9 -> 9
        Index10 -> 10
        Index11 -> 11
        Index12 -> 12
        Index13 -> 13
        Index14 -> 14
        Index15 -> 15

indexFromInt : Int * -> Index
indexFromInt = \int ->
    if int < 0 then
        Index0
    else if int > 15 then
        Index15
    else
        when int is
            0 -> Index0
            1 -> Index1
            2 -> Index2
            3 -> Index3
            4 -> Index4
            5 -> Index5
            6 -> Index6
            7 -> Index7
            8 -> Index8
            9 -> Index9
            10 -> Index10
            11 -> Index11
            12 -> Index12
            13 -> Index13
            14 -> Index14
            15 | _ -> Index15
