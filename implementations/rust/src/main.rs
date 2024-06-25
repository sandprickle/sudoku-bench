mod number;
mod possible_nums;
mod puzzles;
mod smart_backtrack;
mod solve;

use crate::smart_backtrack::Grid as Puzzle;
use clap::Parser;

#[derive(Parser)]
#[command(version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
    #[arg(short, long, default_value_t = 1000)]
    count: u32,
}

fn main() {
    let cli = Cli::parse();

    benchmark(cli.count);
}

fn benchmark(count: u32) {
    // let puzzle_strs = [puzzles::OK; 1000];
    let puzzle_strs = vec![puzzles::OK; count as usize];

    let puzzles = puzzle_strs.iter().map(|input| Puzzle::from_csv_str(input));

    for mut puzzle in puzzles {
        puzzle.solve().unwrap();
    }
}

fn demo() {
    let mut puzzle = Puzzle::from_csv_str(puzzles::OK);
    println!("Puzzle:\n{}", puzzle.pretty_print());

    if let Ok(()) = puzzle.solve() {
        println!("Solved puzzle:\n{}", puzzle.pretty_print());
    };
}
