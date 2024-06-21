module [PossibleNums, all, remove, single, walkUntil]

import Number exposing [Number]

PossibleNums := U16 implements [Eq]

all = @PossibleNums 0b111111111

remove : PossibleNums, Number -> PossibleNums
remove = \@PossibleNums possible, num ->
    shift = (Number.toU8 num) - 1
    mask = 1 |> Num.shiftLeftBy shift |> Num.bitwiseNot

    Num.bitwiseAnd possible mask |> @PossibleNums

single : PossibleNums -> Result Number [NoSingle]
single = \@PossibleNums inBits ->
    helper : U16, U8 -> Result U8 [NoSingle]
    helper = \bits, i ->
        if bits != 0 then
            if bits |> Num.bitwiseAnd 1 == 1 then
                Ok (i + 1)
            else
                helper (bits |> Num.shiftRightBy 1) (i + 1)
        else
            Err NoSingle
    if Num.countOneBits inBits == 1 then
        when helper inBits 0 is
            Ok int -> Number.fromIntNormalize int |> Ok
            Err err -> Err err
    else
        Err NoSingle

walkUntil : PossibleNums,
    state,
    (state, Number -> [Continue state, Break state])
    -> state
walkUntil = \@PossibleNums bits, state, fn ->
    if bits != 0 then
        when walkUntilHelp bits state fn 0 is
            Continue s -> s
            Break s -> s
    else
        state

walkUntilHelp : U16,
    s,
    (s, Number -> [Continue s, Break s]),
    U8
    -> [Continue s, Break s]
walkUntilHelp = \bits, state, fn, index ->
    if index < 9 then
        when bits |> bitAt index is
            End -> Break state
            Zero -> walkUntilHelp bits state fn (index + 1)
            One -> fn state (Number.fromIntNormalize index)
    else
        Break state

## What is at this location?
bitAt : U16, U8 -> [End, Zero, One]
bitAt = \bits, index ->
    if index < 9 then
        if bits |> Num.shiftRightBy index |> Num.bitwiseAnd 1 == 1 then
            One
        else
            Zero
    else
        End

expect
    singleResult = @PossibleNums 0b000010000 |> single
    singleResult == Ok Number.five

expect
    singleResult = @PossibleNums 0b000000000 |> single
    singleResult == Err NoSingle

expect
    singleResult = @PossibleNums 0b010100000 |> single
    singleResult == Err NoSingle
