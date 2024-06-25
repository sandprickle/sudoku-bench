use crate::number::Number;
use crate::possible_nums::PossibleNums;
use std::array;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Cell {
    Fixed(Number),
    Empty(PossibleNums),
}
impl Cell {
    pub fn from_char(char: char) -> Cell {
        match Number::from_char(char) {
            Some(num) => Cell::Fixed(num),
            None => Self::init_empty(),
        }
    }

    pub fn to_char(self: &Self) -> char {
        match self {
            Cell::Fixed(num) => num.to_char(),
            Cell::Empty(_) => ' ',
        }
    }

    pub fn init_empty() -> Cell {
        Cell::Empty(PossibleNums::ALL)
    }
}

/// Represents a coordinate on the grid.
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub struct Coord {
    index: u8,
}
impl Coord {
    pub const FIRST: Self = Self { index: 0 };

    pub fn from_row_col(row: u8, col: u8) -> Self {
        Self {
            index: normalize_index(row) * 9 + normalize_index(col),
        }
    }

    /// The row that contains this cell, numbered from 0 to 8.
    pub fn parent_row(&self) -> u8 {
        self.index / 9
    }

    /// The column that contains this cell, numbered from 0 to 8.
    pub fn parent_col(&self) -> u8 {
        self.index % 9
    }

    /// The box that contains this cell, numbered from 0 to 8.
    pub fn parent_box(&self) -> u8 {
        let row = self.parent_row();
        let col = self.parent_col();

        (row / 3) * 3 + (col / 3)
    }

    pub fn next(self: &Self) -> Option<Self> {
        if self.index < 80 {
            Some(Self {
                index: self.index + 1,
            })
        } else {
            None
        }
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Grid {
    cells: [Cell; 81],
}
impl Grid {
    pub fn from_csv_str(input: &str) -> Self {
        let cells = input
            .split(|c| c == ',' || c == '\n')
            .map(|str| match str.chars().next() {
                Some(char) => Cell::from_char(char),
                None => Cell::init_empty(),
            });

        let mut output: Self = Self {
            cells: array::from_fn(|_| Cell::init_empty()),
        };

        for (i, cell) in cells.enumerate() {
            if i < 81 {
                output.cells[i] = cell;
            } else {
                break;
            }
        }

        return output;
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

        let row_strs = self.rows().map(|row| format_row(&row));

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

    pub fn get(&self, c: Coord) -> Cell {
        self.cells[c.index as usize]
    }

    pub fn set(&mut self, c: Coord, cell: Cell) {
        self.cells[c.index as usize] = cell;
    }

    pub fn get_row(&self, row_num: u8) -> [Cell; 9] {
        let coords = row_coords(normalize_index(row_num));
        array::from_fn(|i| self.get(coords[i]))
    }

    pub fn get_col(&self, col_num: u8) -> [Cell; 9] {
        let coords = col_coords(normalize_index(col_num));
        array::from_fn(|i| self.get(coords[i]))
    }

    pub fn get_box(&self, box_num: u8) -> [Cell; 9] {
        let coords = box_coords(normalize_index(box_num));
        array::from_fn(|i| self.get(coords[i]))
    }

    pub fn rows(&self) -> RowIterator {
        RowIterator {
            grid: &self,
            row: 0,
        }
    }

    pub fn cols(&self) -> ColIterator {
        ColIterator {
            grid: &self,
            col: 0,
        }
    }

    pub fn boxes(&self) -> BoxIterator {
        BoxIterator {
            grid: &self,
            box_: 0,
        }
    }

    pub fn solve(&mut self) -> Result<(), SolveError> {
        if !self.is_legal() {
            return Err(SolveError::IllegalPuzzle);
        } else if !self.has_sufficient_hints() {
            return Err(SolveError::TooFewHints);
        } else {
            self.prune();
            match solve_helper(self, Coord::FIRST) {
                Ok(solved) => {
                    *self = solved;
                    Ok(())
                }
                Err(err) => Err(err),
            }
        }
    }

    pub fn prune(&mut self) {
        let old_grid = self.clone();
        let mut coords: [Coord; 9];
        let mut house: [Cell; 9] = array::from_fn(|_| Cell::init_empty());

        for i in 0..9 {
            // Prune rows
            coords = row_coords(i as u8);
            for (j, coord) in coords.into_iter().enumerate() {
                house[j] = self.get(coord);
            }
            prune_house(&mut house);
            for j in 0..9 {
                self.set(coords[j], house[j]);
            }

            // Prune Cols
            coords = col_coords(i as u8);
            for (j, coord) in coords.into_iter().enumerate() {
                house[j] = self.get(coord);
            }
            prune_house(&mut house);
            for j in 0..9 {
                self.set(coords[j], house[j]);
            }

            // Prune Boxes
            coords = box_coords(i as u8);
            for (j, coord) in coords.into_iter().enumerate() {
                house[j] = self.get(coord);
            }
            prune_house(&mut house);
            for j in 0..9 {
                self.set(coords[j], house[j]);
            }
        }

        if *self != old_grid {
            self.prune();
        }
    }

    fn prune_parents(&mut self, coord: &Coord) {
        let mut house: [Cell; 9] = array::from_fn(|_| Cell::init_empty());
        let mut coords = row_coords(coord.parent_row());

        // Prune row
        for (j, coord) in coords.into_iter().enumerate() {
            house[j] = self.get(coord);
        }
        prune_house(&mut house);
        for j in 0..9 {
            self.set(coords[j], house[j]);
        }

        // Prune Col
        coords = col_coords(coord.parent_col());
        for (j, coord) in coords.into_iter().enumerate() {
            house[j] = self.get(coord);
        }
        prune_house(&mut house);
        for j in 0..9 {
            self.set(coords[j], house[j]);
        }

        // Prune Box
        coords = box_coords(coord.parent_box());
        for (j, coord) in coords.into_iter().enumerate() {
            house[j] = self.get(coord);
        }
        prune_house(&mut house);
        for j in 0..9 {
            self.set(coords[j], house[j]);
        }
    }

    fn has_sufficient_hints(&self) -> bool {
        let mut count = 0;

        for cell in self.cells.iter() {
            if let Cell::Fixed(_) = cell {
                count += 1;
            }
        }

        count >= 17
    }

    fn is_legal(&self) -> bool {
        self.rows().all(|row| house_is_ok(&row))
            && self.cols().all(|col| house_is_ok(&col))
            && self.boxes().all(|box_| house_is_ok(&box_))
    }

    fn number_is_legal(&self, coord: Coord, num: Number) -> bool {
        let current_cell = self.get(coord);

        match current_cell {
            Cell::Fixed(_) => false,
            Cell::Empty(_) => {
                let mut test_grid = *self;
                test_grid.set(coord, Cell::Fixed(num));
                let row = test_grid.get_row(coord.parent_row());
                let col = test_grid.get_col(coord.parent_col());
                let box_ = test_grid.get_box(coord.parent_box());

                house_is_ok(&row) && house_is_ok(&col) && house_is_ok(&box_)
            }
        }
    }
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

    for cell in house.iter_mut() {
        if let Cell::Empty(possible_nums) = cell {
            for num in fixed_nums.iter() {
                possible_nums.remove(*num);
            }
            if let Some(num) = possible_nums.single() {
                *cell = Cell::Fixed(num);
            }
        }
    }
}

fn house_is_ok(house: &[Cell; 9]) -> bool {
    for i in 0..8 {
        let current = house[i];
        let next = &house[(i + 1)..9];
        if let Cell::Fixed(_) = current {
            if next.contains(&current) {
                return false;
            }
        }
    }

    return true;
}

fn normalize_index(index: u8) -> u8 {
    if index > 8 {
        8
    } else {
        index
    }
}

fn solve_helper(grid: &Grid, c: Coord) -> Result<Grid, SolveError> {
    match grid.get(c) {
        Cell::Fixed(_) => match c.next() {
            Some(next_c) => solve_helper(grid, next_c),
            None => Ok(*grid),
        },
        Cell::Empty(possible_nums) => {
            for num in possible_nums.iter() {
                if grid.number_is_legal(c, num) {
                    let mut new_grid = *grid;
                    new_grid.set(c, Cell::Fixed(num));
                    match c.next() {
                        Some(next_coord) => {
                            new_grid.prune_parents(&c);
                            if let Ok(solution) = solve_helper(&new_grid, next_coord) {
                                return Ok(solution);
                            }
                        }
                        None => {
                            return Ok(new_grid);
                        }
                    }
                }
            }
            Err(SolveError::NoSolutionFound)
        }
    }
}

// Error enums

#[derive(Debug)]
pub enum SolveError {
    TooFewHints,
    IllegalPuzzle,
    NoSolutionFound,
}

pub struct RowIterator<'a> {
    grid: &'a Grid,
    row: u8,
}
impl<'a> Iterator for RowIterator<'a> {
    type Item = [Cell; 9];

    fn next(&mut self) -> Option<Self::Item> {
        if self.row < 9 {
            let output = array::from_fn(|col| {
                let c = Coord::from_row_col(self.row, col as u8);
                self.grid.get(c)
            });

            self.row += 1;

            Some(output)
        } else {
            None
        }
    }
}

pub struct ColIterator<'a> {
    grid: &'a Grid,
    col: u8,
}
impl<'a> Iterator for ColIterator<'a> {
    type Item = [Cell; 9];

    fn next(&mut self) -> Option<Self::Item> {
        if self.col < 9 {
            let output = array::from_fn(|row| {
                let c = Coord::from_row_col(row as u8, self.col);
                self.grid.get(c)
            });

            self.col += 1;

            Some(output)
        } else {
            None
        }
    }
}

pub struct BoxIterator<'a> {
    grid: &'a Grid,
    box_: u8,
}
impl<'a> Iterator for BoxIterator<'a> {
    type Item = [Cell; 9];

    fn next(&mut self) -> Option<Self::Item> {
        if self.box_ < 9 {
            let mut output = array::from_fn(|_| Cell::init_empty());
            let row_start = (self.box_ / 3) * 3;
            let col_start = (self.box_ % 3) * 3;

            for i in 0..3 {
                for j in 0..3 {
                    let coord = Coord::from_row_col(row_start + i, col_start + j);
                    output[i as usize * 3 + j as usize] = self.grid.get(coord);
                }
            }

            self.box_ += 1;
            Some(output)
        } else {
            None
        }
    }
}

fn row_coords(row: u8) -> [Coord; 9] {
    let row_index = normalize_index(row);
    array::from_fn(|col| Coord::from_row_col(row_index, col as u8))
}

fn col_coords(col: u8) -> [Coord; 9] {
    let col_index = normalize_index(col);
    array::from_fn(|row| Coord::from_row_col(row as u8, col_index))
}

fn box_coords(box_: u8) -> [Coord; 9] {
    let box_index = normalize_index(box_);
    let row_start = (box_index / 3) * 3;
    let col_start = (box_index % 3) * 3;

    array::from_fn(|i| {
        let row = row_start + (i as u8 / 3);
        let col = col_start + (i as u8 % 3);
        Coord::from_row_col(row, col)
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::puzzles;

    #[test]
    fn test_normalize_row() {
        assert_eq!(normalize_index(9), 8);
        assert_eq!(normalize_index(6), 6);
    }

    #[test]
    fn test_from_csv_str() {
        let grid = Grid::from_csv_str(puzzles::OK);

        assert_eq!(
            grid.get(Coord::from_row_col(3, 7)),
            Cell::Fixed(Number::Four)
        );
        assert_eq!(
            grid.get(Coord::from_row_col(6, 1)),
            Cell::Fixed(Number::Three)
        );
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
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::Fixed(Number::Five),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::init_empty(),
            Cell::Fixed(Number::Two),
            Cell::Fixed(Number::Two),
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

    #[test]
    fn test_row_coords() {
        let coords = row_coords(3);
        assert_eq!(coords[0], Coord::from_row_col(3, 0));
        assert_eq!(coords[8], Coord::from_row_col(3, 8));
    }

    #[test]
    fn test_col_coords() {
        let coords = col_coords(3);
        assert_eq!(coords[0], Coord::from_row_col(0, 3));
        assert_eq!(coords[8], Coord::from_row_col(8, 3));
    }

    #[test]
    fn test_box_coords() {
        let coords = box_coords(2);
        assert_eq!(coords[0], Coord::from_row_col(0, 6));
        assert_eq!(coords[8], Coord::from_row_col(2, 8));
    }
}
