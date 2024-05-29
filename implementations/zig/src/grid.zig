const std = @import("std");
const expect = std.testing.expect;

pub const Grid = struct {
    const Self = @This();

    cells: [81]Cell,

    pub fn init() Self {
        return Self{
            .cells = [_]Cell{Cell.init()} ** 81,
        };
    }

    pub fn get(self: *Self, coord: Coord) *Cell {
        const index = coord.toIndex();
        return &self.cells[index];
    }

    pub fn set(
        self: *Self,
        row_col: struct { row: u4, col: u4 },
        cell: Cell,
    ) void {
        const row = normalizeHouseIndex(row_col.row);
        const col = normalizeHouseIndex(row_col.col);
        const index: u8 = (row * 9) + col;

        self.cells[index] = cell;
    }

    pub fn getRow(self: *Self, row_num: u4) [9]*Cell {
        const row_index: u8 = normalizeHouseIndex(row_num);
        const start = @as(u8, row_index) * 9;

        var output: [9]*Cell = undefined;
        for (self.cells[start..][0..9], 0..) |*cell, i| {
            output[i] = cell;
        }

        return output;
    }

    pub fn getCol(self: *Self, col_num: u4) [9]*Cell {
        var output: [9]*Cell = undefined;

        for (0..9) |i| {
            output[i] = &self.cells[Coord.new(@truncate(i), col_num).toIndex()];
        }

        return output;
    }

    pub fn getBox(self: *Self, box_num: u4) [9]*Cell {
        var output: [9]*Cell = undefined;

        // box_row and box_col represent one of the three
        // rows or columns a box can be in, if you consider a puzzle as a
        // 3x3 grid of boxes.
        const box_row = box_num / 3;
        const box_col = box_num % 3;
    }

    pub fn rows(self: *Self) RowIterator {
        return RowIterator.init(&self.cells);
    }

    pub fn fromCsv(input: []const u8) Self {
        var iter = std.mem.splitAny(u8, input, "\n,");
        var output = Self.init();
        var index: usize = 0;

        while (iter.next()) |item| {
            if (index < 81) {
                const cell = if (item.len >= 1) Cell.fromChar(item[0]) else Cell.init();
                output.cells[index] = cell;
                index += 1;
            } else {
                break;
            }
        }

        return output;
    }

    fn normalizeHouseIndex(i: u4) u4 {
        return if (i > 8) 8 else i;
    }
};

test "Grid.fromCsv" {
    const test_input =
        \\0,0,0,0,0,2,1,0,4
        \\0,0,8,0,0,1,0,0,3
        \\5,0,0,0,6,0,0,9,0
        \\0,9,0,0,8,0,0,4,6
        \\6,0,0,7,0,0,0,0,0
        \\1,0,0,0,0,0,0,8,0
        \\0,3,7,2,0,0,0,1,9
        \\0,0,0,0,0,0,0,3,0
        \\0,0,0,0,9,0,0,0,0
    ;

    var test_grid = Grid.fromCsv(test_input);
    const fixed_cell = test_grid.get(.{ .row = 0, .col = 8 }).*;
    const empty_cell = test_grid.get(.{ .row = 0, .col = 0 }).*;

    try expect(@as(CellTag, fixed_cell) == CellTag.fixed);
    try expect(fixed_cell.fixed == 4);
    try expect(@as(CellTag, empty_cell) == CellTag.empty);
}

test Grid {
    const test_input =
        \\0,0,0,0,0,2,1,0,4
        \\0,0,8,0,0,1,0,0,3
        \\5,0,0,0,6,0,0,9,0
        \\0,9,0,0,8,0,0,4,6
        \\6,0,0,7,0,0,0,0,0
        \\1,0,0,0,0,0,0,8,0
        \\0,3,7,2,0,0,0,1,9
        \\0,0,0,0,0,0,0,3,0
        \\0,0,0,0,9,0,0,0,0
    ;

    var puzzle = Grid.fromCsv(test_input);

    // getRow
    const first_row = puzzle.getRow(0);
    const eighth_row = puzzle.getRow(7);
    try expect(first_row[8].*.fixed == 4);
    try expect(eighth_row[7].*.fixed == 3);

    // getCol
    const first_col = puzzle.getCol(0);
    const fifth_col = puzzle.getCol(4);
    try expect(first_col[2].*.fixed == 5);
    try expect(fifth_col[8].*.fixed == 9);

    // getBox
}

pub const RowIterator = struct {
    const Self = @This();
    cells: *[81]Cell,
    index: u4,

    pub fn next(self: *Self) ?*[9]Cell {
        const i = self.index;
        if (i <= 8) {
            self.index += 1;
            const start = i * 9;
            const end = start + 9;
            return self.cells[start..end];
        } else {
            return null;
        }
    }

    pub fn init(cells: *[81]Cell) Self {
        return Self{
            .cells = cells,
            .index = 0,
        };
    }
};

const CellTag = enum { fixed, empty };
/// A Cell in a Sudoku grid
/// Can be a fixed value, or empty
/// Empty cells contain a BoundedArray of possible numbers
pub const Cell = union(CellTag) {
    const Self = @This();
    fixed: u4,
    empty: PossibleNums,

    const PossibleNums = std.BoundedArray(u4, 9);

    pub fn fromChar(char: u8) Self {
        const digit = std.fmt.charToDigit(char, 10) catch 0;

        return (if (digit >= 1 and digit <= 9)
            Self{ .fixed = @intCast(digit) }
        else
            Self.init());
    }

    pub fn init() Self {
        return Self{
            .empty = PossibleNums.fromSlice(&[9]u4{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }) catch unreachable,
        };
    }
};

test Cell {
    const cell_1 = Cell.fromChar('1');
    try expect(@as(CellTag, cell_1) == CellTag.fixed);
    try expect(cell_1.fixed == 1);

    const cell_2 = Cell.fromChar('0');
    try expect(@as(CellTag, cell_2) == CellTag.empty);
    try expect(cell_2.empty.get(8) == 9);

    const cell_3 = Cell.fromChar('-');
    try expect(@as(CellTag, cell_3) == CellTag.empty);

    const cell_4 = Cell.init();
    try expect(@as(CellTag, cell_4) == CellTag.empty);
    try expect(cell_4.empty.get(8) == 9);
}

pub const Coord = struct {
    const Self = @This();
    row: u4,
    col: u4,

    pub fn toIndex(self: *const Self) u7 {
        return (@as(u7, self.row) * 9) + @as(u7, self.col);
    }

    pub fn new(row: u4, col: u4) Self {
        return Self{ .row = row, .col = col };
    }
};
