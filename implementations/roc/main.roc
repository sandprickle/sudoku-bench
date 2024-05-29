app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.8.1/x8URkvfyi9I0QhmVG98roKBUs_AZRkLFwFJVJ3942YA.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.5.2/9VrPjwfQQ1QeSL3CfmWr2Pr9DESdDIXy97pwpuq84Ck.tar.br",
}

import cli.Stdout
import cli.Stderr
import cli.Task exposing [Task]
import cli.Arg
import cli.Path
import cli.File
import BTAdvHeap
import Puzzles

main : Task {} I32
main =
    args <- Arg.list |> Task.await
    if List.len args <= 1 then
        Stdout.line "Usage: sudoku <file>"
    else
        when List.get args 1 is
            Ok arg ->
                if arg == "benchmark" then
                    runBenchmark
                else
                    contents <- loadFile arg |> Task.await
                    inPuzzle = BTAdvHeap.fromStr contents

                    _ <- inPuzzle
                        |> BTAdvHeap.prettyPrint
                        |> Stdout.line
                        |> Task.await

                    output =
                        when inPuzzle |> BTAdvHeap.prune |> BTAdvHeap.solve is
                            Ok solution ->
                                "Solution:\n$(BTAdvHeap.prettyPrint solution)"

                            Err TooFewHints ->
                                "Too few hints!"

                            Err NotLegal ->
                                "Puzzle is not legal!"

                            Err NoSolutionFound ->
                                "No Solution!"
                    Stdout.line output

            Err _ ->
                Task.err 1

loadFile : Str -> Task Str I32
loadFile = \pathStr ->
    path = Path.fromStr pathStr

    result <- File.readUtf8 path |> Task.attempt

    when result is
        Ok content ->
            content
            |> Task.ok

        Err _ ->
            {} <- Stderr.line "Error reading file" |> Task.await
            Task.err 1

runBenchmark : Task {} I32
runBenchmark =
    puzzles =
        List.repeat Puzzles.puzzle1 100
        |> List.map BTAdvHeap.fromStr
        |> List.map BTAdvHeap.prune

    results = List.map puzzles BTAdvHeap.solve

    Task.ok {}
