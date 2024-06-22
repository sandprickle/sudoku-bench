const std = @import("std");
const PossibleNums = @import("possible_nums.zig").PossibleNums;
const Number = @import("number.zig").Number;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

pub const Grid = struct {
    const Self = @This();

    cells: [81]Cell,

    pub fn init() Self {
        return Self{
            .cells = [_]Cell{Cell.INIT} ** 81,
        };
    }

    pub fn fromCsv(input: []const u8) Self {
        var iter = std.mem.splitAny(u8, input, "\n,");
        var output = Self.init();
        var index: usize = 0;

        while (iter.next()) |item| {
            if (index < 81) {
                const cell = if (item.len >= 1)
                    Cell.fromChar(item[0])
                else
                    Cell.INIT;

                output.cells[index] = cell;
                index += 1;
            } else {
                break;
            }
        }

        return output;
    }

    pub fn get(self: *const Self, coord: Coord) Cell {
        return self.cells[coord.index];
    }

    pub fn set(self: *Self, coord: Coord, cell: Cell) void {
        const row, const col = coord.toRowCol();

        const index: u8 = (row * 9) + col;

        self.cells[index] = cell;
    }

    pub fn getRow(self: *const Self, row_num: HouseIndex) [9]Cell {
        var output: [9]Cell = undefined;
        for (rowCoords(row_num), 0..9) |coord, i| {
            output[i] = self.get(coord);
        }
        return output;
    }

    pub fn getCol(self: *const Self, col_num: HouseIndex) [9]Cell {
        var output: [9]Cell = undefined;
        for (colCoords(col_num), 0..9) |coord, i| {
            output[i] = self.get(coord);
        }
        return output;
    }

    pub fn getBox(self: *const Self, box_num: u4) [9]Cell {
        var output: [9]Cell = undefined;
        for (boxCoords(box_num), 0..9) |coord, i| {
            output[i] = self.get(coord);
        }
        return output;
    }

    pub fn rows(self: *const Self) RowIterator {
        return RowIterator{
            .grid = self,
            .index = 0,
        };
    }

    pub const RowIterator = struct {
        grid: *const Grid,
        index: u4,

        pub fn next(self: *RowIterator) ?[9]Cell {
            if (self.index < 9) {
                return self.grid.getRow(self.index);
            } else {
                return null;
            }
        }
    };

    pub fn cols(self: *const Self) ColIterator {
        return ColIterator{
            .grid = self,
            .index = 0,
        };
    }

    pub const ColIterator = struct {
        grid: *const Grid,
        index: u4,

        pub fn next(self: *ColIterator) ?[9]Cell {
            if (self.index < 9) {
                return self.grid.getCol(self.index);
            } else {
                return null;
            }
        }
    };

    pub fn boxes(self: *const Self) BoxIterator {
        return BoxIterator{
            .grid = self,
            .index = 0,
        };
    }

    pub const BoxIterator = struct {
        grid: *const Grid,
        index: u4,

        pub fn next(self: *BoxIterator) ?[9]Cell {
            if (self.index < 9) {
                return self.grid.getBox(self.index);
            } else {
                return null;
            }
        }
    };

    fn isLegal(self: *const Self) bool {
        for (self.rows()) |row| {
            if (!houseIsOk(row)) {
                return false;
            }
        }

        for (self.cols()) |col| {
            if (!houseIsOk(col)) {
                return false;
            }
        }

        for (self.boxes()) |box| {
            if (!houseIsOk(box)) {
                return false;
            }
        }

        return true;
    }

    fn numberIsLegal(self: *const Self, coord: Coord, num: Number) bool {
        const row = coord.parentRow();
        const col = coord.parentCol();
        const box = coord.parentBox();

        for (self.getRow(row)) |cell| {
            if (cell.fixed == num) {
                return false;
            }
        }

        for (self.getCol(col)) |cell| {
            if (cell.fixed == num) {
                return false;
            }
        }

        for (self.getBox(box)) |cell| {
            if (cell.fixed == num) {
                return false;
            }
        }

        return true;
    }

    fn hasSufficientHints(self: *const Self) bool {
        var count: u8 = 0;
        for (self.cells) |cell| {
            if (cell.fixed) {
                count += 1;
            }
        }
        return count >= 17;
    }

    // fn prune(self: *Self) void {}

    // fn pruneParents(self: *Self, coord: Coord) void {}
};

fn pruneHouse(house: *9[Cell]) void {
    var fixed_nums = std.BoundedArray(Number, 9).init(0) catch unreachable;
    for (house) |cell| {
        if (cell.fixed) fixed_nums.append(cell.fixed) catch unreachable;
    }

    for (house) |cell| {
        if (cell.empty) {
            for (fixed_nums) |num| {
                cell.empty.remove(num);
            }
        }
    }
}

fn houseIsOk(house: *const 9[Cell]) bool {
    for (0..8) |i| {
        const current = house[i];
        if (current.fixed) {
            const rest = house[(i + 1)..9];
            for (rest) |cell| {
                if (cell.fixed and cell.fixed == current.fixed) {
                    return false;
                }
            }
        }
    }
    return true;
}

const CellTag = enum { fixed, empty };

/// A Cell in a Sudoku grid
/// Can be a fixed value, or empty
/// Empty cells contain a set of possible numbers
pub const Cell = union(CellTag) {
    const Self = @This();
    fixed: Number,
    empty: PossibleNums,

    pub fn fromChar(char: u8) Self {
        if (Number.fromChar(char)) |num| {
            return Self{ .fixed = num };
        } else {
            return Self.INIT;
        }
    }

    pub const INIT: Self = Self{ .empty = PossibleNums.ALL };
};

pub const Coord = struct {
    const Self = @This();

    index: u7,

    pub fn index(self: Self) u7 {
        return self.index;
    }

    pub fn fromRowCol(row: u4, col: u4) Self {
        const r = @as(u7, clampIndex(row));
        const c = @as(u7, clampIndex(col));
        return Self{ .index = r * 9 + c };
    }

    fn toRowCol(self: Self) .{ .row = u4, .col = u4 } {
        return .{
            .row = self.index / 9,
            .col = self.index % 9,
        };
    }

    pub fn parentRow(self: Self) HouseIndex {
        return self.index / 9;
    }

    pub fn parentCol(self: Self) HouseIndex {
        return self.index % 9;
    }

    pub fn parentBox(self: Self) HouseIndex {
        const row = self.parentRow();
        const col = self.parentCol();
        return (row / 3) * 3 + (col / 3);
    }

    pub fn next(self: Self) ?Self {
        return if (self.index < 80)
            Self{ .index = self.index + 1 }
        else
            null;
    }
};

/// An index from 0 to 8 referring to one of the nine rows, columns, or boxes.
pub const HouseIndex = u4;

fn clampIndex(i: HouseIndex) HouseIndex {
    return if (i > 8) 8 else i;
}

fn rowCoords(row: HouseIndex) [9]Coord {
    var output: [9]Coord = undefined;
    for (0..9) |i| {
        output[i] = Coord.fromRowCol(clampIndex(row), @truncate(i));
    }
    return output;
}

fn colCoords(col: HouseIndex) [9]Coord {
    var output: [9]Coord = undefined;
    for (0..9) |i| {
        output[i] = Coord.fromRowCol(@truncate(i), clampIndex(col));
    }
    return output;
}

fn boxCoords(box: HouseIndex) [9]Coord {
    const box_index = clampIndex(box);
    const row_start = (box_index / 3) * 3;
    const col_start = (box_index % 3) * 3;
    var output: [9]Coord = undefined;

    for (0..9) |i| {
        const row = row_start + i / 3;
        const col = col_start + i % 3;
        output[i] = Coord.fromRowCol(row, col);
    }
    return output;
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
    try expect(first_row[8].fixed == Number.four);
    try expect(eighth_row[7].fixed == Number.three);

    // getCol
    const first_col = puzzle.getCol(0);
    const fifth_col = puzzle.getCol(4);
    try expect(first_col[2].fixed == Number.five);
    try expect(fifth_col[8].fixed == Number.nine);

    // getBox
}

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
    const fixed_cell = test_grid.get(Coord.fromRowCol(0, 8));
    const empty_cell = test_grid.get(Coord.fromRowCol(0, 0));

    try expect(@as(CellTag, fixed_cell) == CellTag.fixed);
    try expect(fixed_cell.fixed == Number.four);
    try expect(@as(CellTag, empty_cell) == CellTag.empty);
}

test Cell {
    const cell_1 = Cell.fromChar('1');
    try expect(@as(CellTag, cell_1) == CellTag.fixed);
    try expect(cell_1.fixed == Number.one);

    const cell_2 = Cell.fromChar('0');
    try expect(@as(CellTag, cell_2) == CellTag.empty);
    try expectEqual(PossibleNums.ALL, cell_2.empty);

    const cell_3 = Cell.fromChar('-');
    try expect(@as(CellTag, cell_3) == CellTag.empty);

    const cell_4 = Cell.INIT;
    try expect(@as(CellTag, cell_4) == CellTag.empty);
}
