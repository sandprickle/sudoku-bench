enum Cell {
    Fixed(u8),
    Empty([u8; 9]),
}

pub fn parse_csv(input: &str) -> [Cell; 81] {
    let cells: Vec<Vec<&str>> = input
        .split('\n')
        .map(|row| row.split(',').collect())
        .collect();
}
