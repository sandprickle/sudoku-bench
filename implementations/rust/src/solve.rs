use crate::number::Number;
use crate::possible_nums::PossibleNums;
use std::{array, collections::HashSet};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Cell {
    Fixed(Number),
    Empty(PossibleNums),
}
impl Cell {
    fn from_char(char: char) -> Cell {
        match Number::from_char(char) {
            Some(num) => Cell::Fixed(num),
            None => Self::init_empty(),
        }
    }

    fn to_char(self: &Self) -> char {
        match self {
            Cell::Fixed(num) => num.to_char(),
            Cell::Empty(_) => ' ',
        }
    }

    fn init_empty() -> Cell {
        Cell::Empty(PossibleNums::ALL)
    }
}

#[derive(PartialEq, Eq)]
struct Coord {
    row: usize,
    col: usize,
}
impl Coord {
    pub const FIRST: Coord = Coord { row: 0, col: 0 };
    pub const LAST: Coord = Coord { row: 8, col: 8 };

    pub fn next(self: &Self) -> Option<Self> {
        if self == &Self::LAST {
            None
        } else if self.col == 8 {
            Some(Coord {
                row: self.row + 1,
                col: 0,
            })
        } else {
            Some(Coord {
                row: self.row,
                col: self.col + 1,
            })
        }
    }
}

#[derive(Debug, Clone, Copy)]
pub struct Grid {
    cells: [[Cell; 9]; 9],
}
impl Grid {
    fn sufficient_hints(&self) -> bool {
        let mut count = 0;

        for row in self.cells.iter() {
            for cell in row {
                if let Cell::Fixed(_) = cell {
                    count += 1;
                }
            }
        }

        count >= 17
    }

    pub fn is_legal(&self) -> bool {
        self.rows().all(|row| house_is_ok(&row))
            && self.cols().all(|col| house_is_ok(&col))
            && self.boxes().all(|box_| house_is_ok(&box_))
    }

    pub fn from_csv_str(input: &str) -> Result<Self, GridParseError> {
        let rows = input.split('\n').map(|row| {
            row.split(',')
                .map(|cell_str| match cell_str.chars().nth(0) {
                    Some(char) => Cell::from_char(char),
                    None => Cell::init_empty(),
                })
        });

        let mut output: Self = Self {
            cells: array::from_fn(|_| array::from_fn(|_| Cell::init_empty())),
        };

        for (i, row) in rows.enumerate() {
            for (j, cell) in row.enumerate() {
                if i < 9 && j < 9 {
                    output.cells[i][j] = cell;
                } else {
                    break;
                }
            }
        }

        if !Self::is_legal(&output) {
            Err(GridParseError::IllegalPuzzle)
        } else if !Self::sufficient_hints(&output) {
            Err(GridParseError::TooFewHints)
        } else {
            Ok(output)
        }
    }

    pub fn pretty_print(&self) -> String {
        let line_top = "┏━━━┯━━━┯━━━┳━━━┯━━━┯━━━┳━━━┯━━━┯━━━┓\n";
        let line_mid_thin = "┠───┼───┼───╂───┼───┼───╂───┼───┼───┨\n";
        let line_mid_thick = "┣━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┫\n";
        let line_bottom = "┗━━━┷━━━┷━━━┻━━━┷━━━┷━━━┻━━━┷━━━┷━━━┛";

        fn format_row(row: &[Cell; 9]) -> String {
            let thin = " │ ";
            let thick = " ┃ ";
            let mut output = String::with_capacity(76);

            output.push_str("┃ ");
            output.push(row[0].to_char());
            output.push_str(thin);
            output.push(row[1].to_char());
            output.push_str(thin);
            output.push(row[2].to_char());
            output.push_str(thick);
            output.push(row[3].to_char());
            output.push_str(thin);
            output.push(row[4].to_char());
            output.push_str(thin);
            output.push(row[5].to_char());
            output.push_str(thick);
            output.push(row[6].to_char());
            output.push_str(thin);
            output.push(row[7].to_char());
            output.push_str(thin);
            output.push(row[8].to_char());
            output.push_str(" ┃\n");

            output
        }

        let row_strs = self.cells.iter().map(|row| format_row(row));

        let mut output = String::from(line_top);

        for (i, row) in row_strs.enumerate() {
            match i {
                0 | 1 | 3 | 4 | 6 | 7 => {
                    // rows 1, 2, 4, 5, 7, and 8
                    output.push_str(&row);
                    output.push_str(line_mid_thin);
                }
                2 | 5 => {
                    // rows 3 and 6
                    output.push_str(&row);
                    output.push_str(line_mid_thick);
                }
                8 => {
                    // row 9
                    output.push_str(&row);
                    output.push_str(line_bottom);
                }
                _ => {}
            }
        }

        output
    }

    pub fn rows(&self) -> RowIterator {
        RowIterator {
            cells: self.cells,
            index: 0,
        }
    }

    pub fn cols(&self) -> ColIterator {
        ColIterator {
            cells: self.cells,
            index: 0,
        }
    }

    pub fn boxes(&self) -> BoxIterator {
        BoxIterator {
            cells: self.cells,
            index: 0,
        }
    }

    pub fn solve(self) -> Result<Self, SolveError> {
        self.solve_helper(Coord::FIRST)
    }

    fn solve_helper(mut self, c: Coord) -> Result<Grid, SolveError> {
        let cell = self.cells[c.row][c.col];
        match cell {
            Cell::Fixed(_) => match c.next() {
                Some(next_c) => self.solve_helper(next_c),
                None => Ok(self),
            },
            Cell::Empty(possible) => {
                let mut result = Err(SolveError::NoSolutionFound);

                for num in &possible {
                    self.cells[c.row][c.col] = Cell::Fixed(num);

                    if self.is_legal() {
                        match c.next() {
                            Some(next_c) => match self.solve_helper(next_c) {
                                Ok(solution) => {
                                    result = Ok(solution);
                                    break;
                                }
                                Err(_) => continue,
                            },
                            None => {
                                result = Ok(self);
                                break;
                            }
                        }
                    } else {
                        continue;
                    }
                }
                result
            }
        }
    }

    fn prune(&mut self) {}
}

fn house_is_ok(house: &[Cell; 9]) -> bool {
    let mut uniq: HashSet<Cell> = HashSet::new();
    house
        .iter()
        .filter(|cell| match cell {
            Cell::Fixed(_) => true,
            Cell::Empty(_) => false,
        })
        .all(|cell| uniq.insert(*cell))
}

/// Remove all fixed numbers in a house from the possible numbers
/// of empty cells in the house.
fn prune_house(house: &mut [Cell; 9]) {
    let fixed_nums: Vec<Number> = house
        .iter()
        .filter_map(|cell| {
            if let Cell::Fixed(num) = cell {
                Some(*num)
            } else {
                None
            }
        })
        .collect();

    for num in fixed_nums {
        for cell in house.iter_mut() {
            if let Cell::Empty(possible_nums) = cell {
                possible_nums.remove(num);
            }
        }
    }
}

fn normalize_index(index: u8) -> u8 {
    if index > 8 {
        8
    } else {
        index
    }
}

// Error enums

#[derive(Debug)]
pub enum SolveError {
    NoSolutionFound,
}

#[derive(Debug)]
pub enum GridParseError {
    TooFewHints,
    IllegalPuzzle,
}

pub struct RowIterator {
    cells: [[Cell; 9]; 9],
    index: u8,
}
impl Iterator for RowIterator {
    type Item = [Cell; 9];

    fn next(&mut self) -> Option<Self::Item> {
        if self.index < 9 {
            let row = self.cells[self.index as usize];
            self.index += 1;
            Some(row)
        } else {
            None
        }
    }
}

pub struct ColIterator {
    cells: [[Cell; 9]; 9],
    index: u8,
}
impl Iterator for ColIterator {
    type Item = [Cell; 9];

    fn next(&mut self) -> Option<Self::Item> {
        if self.index < 9 {
            let mut col: [Cell; 9] = array::from_fn(|_| Cell::init_empty());
            for (i, row) in self.cells.iter().enumerate() {
                col[i] = row[self.index as usize];
            }
            self.index += 1;
            Some(col)
        } else {
            None
        }
    }
}

pub struct BoxIterator {
    cells: [[Cell; 9]; 9],
    index: u8,
}
impl Iterator for BoxIterator {
    type Item = [Cell; 9];

    fn next(&mut self) -> Option<Self::Item> {
        if self.index < 9 {
            let mut box_cells: [Cell; 9] = array::from_fn(|_| Cell::init_empty());
            let row_start = (self.index / 3) * 3;
            let col_start = (self.index % 3) * 3;

            for i in 0..3 {
                for j in 0..3 {
                    box_cells[i * 3 + j] =
                        self.cells[row_start as usize + i][col_start as usize + j];
                }
            }

            self.index += 1;
            Some(box_cells)
        } else {
            None
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_row() {
        assert_eq!(normalize_index(9), 8);
        assert_eq!(normalize_index(6), 6);
    }

    #[test]
    fn test_house_is_ok() {
        let ok = [
            Cell::Fixed(Number::One),
            Cell::Fixed(Number::Two),
            Cell::Fixed(Number::Three),
            Cell::Fixed(Number::Four),
            Cell::Fixed(Number::Five),
            Cell::Fixed(Number::Six),
            Cell::Fixed(Number::Seven),
            Cell::Fixed(Number::Eight),
            Cell::Fixed(Number::Nine),
        ];

        let bad = [
            Cell::Fixed(Number::One),
            Cell::Fixed(Number::Two),
            Cell::Fixed(Number::Two),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
        ];

        assert_eq!(house_is_ok(&ok), true);
        assert_eq!(house_is_ok(&bad), false);
    }

    #[test]
    fn test_prune_house() {
        let mut house = [
            Cell::Fixed(Number::One),
            Cell::Fixed(Number::Two),
            Cell::Fixed(Number::Three),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
        ];

        prune_house(&mut house);

        let mut expected_possible = PossibleNums::ALL;
        expected_possible.remove(Number::One);
        expected_possible.remove(Number::Two);
        expected_possible.remove(Number::Three);

        assert_eq!(house[0], Cell::Fixed(Number::One));
        assert_eq!(house[1], Cell::Fixed(Number::Two));
        assert_eq!(house[2], Cell::Fixed(Number::Three));
        assert_eq!(house[3], Cell::Empty(expected_possible));
        assert_eq!(house[4], Cell::Empty(expected_possible));
        assert_eq!(house[5], Cell::Empty(expected_possible));
        assert_eq!(house[6], Cell::Empty(expected_possible));
        assert_eq!(house[7], Cell::Empty(expected_possible));
        assert_eq!(house[8], Cell::Empty(expected_possible));
    }
}
