module [
    Number,
    fromInt,
    fromIntNormalize,
    fromStr,
    toU8,
    toU64,
    toStr,
    increment,
    all,
]

## A number in the range 1-9, inclusive.
Number : [One, Two, Three, Four, Five, Six, Seven, Eight, Nine]

fromInt : Int * -> Result Number [OutOfRange]
fromInt = \n ->
    when n is
        1 -> One |> Ok
        2 -> Two |> Ok
        3 -> Three |> Ok
        4 -> Four |> Ok
        5 -> Five |> Ok
        6 -> Six |> Ok
        7 -> Seven |> Ok
        8 -> Eight |> Ok
        9 -> Nine |> Ok
        _ -> Err OutOfRange

fromIntNormalize : Int * -> Number
fromIntNormalize = \n ->
    num =
        if n < 1 then
            1
        else if n > 9 then
            9
        else
            n

    fromInt num |> Result.withDefault (One)

fromStr : Str -> Result Number [InvalidStr]
fromStr = \str ->
    when str is
        "1" -> Ok (One)
        "2" -> Ok (Two)
        "3" -> Ok (Three)
        "4" -> Ok (Four)
        "5" -> Ok (Five)
        "6" -> Ok (Six)
        "7" -> Ok (Seven)
        "8" -> Ok (Eight)
        "9" -> Ok (Nine)
        _ -> Err InvalidStr

toU8 : Number -> U8
toU8 = \num ->
    when num is
        One -> 1
        Two -> 2
        Three -> 3
        Four -> 4
        Five -> 5
        Six -> 6
        Seven -> 7
        Eight -> 8
        Nine -> 9

toU64 : Number -> U64
toU64 = \number ->
    toU8 number |> Num.toU64

toStr : Number -> Str
toStr = \num ->
    when num is
        One -> "1"
        Two -> "2"
        Three -> "3"
        Four -> "4"
        Five -> "5"
        Six -> "6"
        Seven -> "7"
        Eight -> "8"
        Nine -> "9"

increment : Number -> Result Number [MaxValue]
increment = \num ->
    when num is
        One -> Two |> Ok
        Two -> Three |> Ok
        Three -> Four |> Ok
        Four -> Five |> Ok
        Five -> Six |> Ok
        Six -> Seven |> Ok
        Seven -> Eight |> Ok
        Eight -> Nine |> Ok
        Nine -> Err MaxValue

all = [One, Two, Three, Four, Five, Six, Seven, Eight, Nine]
