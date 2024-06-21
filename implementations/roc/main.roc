app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.8.1/x8URkvfyi9I0QhmVG98roKBUs_AZRkLFwFJVJ3942YA.tar.br",
    weaver: "https://github.com/smores56/weaver/releases/download/0.2.0/BBDPvzgGrYp-AhIDw0qmwxT0pWZIQP_7KOrUrZfp_xw.tar.br",
}

import cli.Stdout
import cli.Task exposing [Task]
import cli.Arg
import weaver.Cli
import weaver.Opt
import SmartBacktrackStack as SmartBacktrack
import Puzzles

main =
    args = Arg.list!

    when Cli.parseOrDisplayMessage cliParser args is
        Ok { count } ->
            results = runBenchmark count
            Task.ok {}

        Err message ->
            Stdout.line! message

cliParser =
    Cli.weave {
        count: <- Opt.u64 { short: "c", help: "Number of puzzles to solve" },
    }
    |> Cli.finish {
        name: "sudoku-bench",
        authors: ["Bryce Miller"],
        description: "Benchmark a sudoku solver written in Roc",
    }
    |> Cli.assertValid

runBenchmark : U64 -> List _
runBenchmark = \count ->
    puzzles =
        List.repeat Puzzles.puzzle1 count
        |> List.map SmartBacktrack.fromStr
        |> List.map SmartBacktrack.prune

    List.map puzzles SmartBacktrack.solve
