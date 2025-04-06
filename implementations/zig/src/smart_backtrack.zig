const std = @import("std");
const PossibleNums = @import("possible_nums.zig").PossibleNums;
const Number = @import("number.zig").Number;

/// An index from 0 to 8 referring to one of the nine rows, columns, or boxes.
pub const HouseIndex = u4;

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

    // pub fn prettyPrint(self: *Grid) [1669]u8 {
    //     const topBorder =
    //         "┏━━━┯━━━┯━━━┳━━━┯━━━┯━━━┳━━━┯━━━┯━━━┓\n";
    //     const midBorderThick =
    //         "┣━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┫\n";
    //     const midBorderThin =
    //         "┠───┼───┼───╂───┼───┼───╂───┼───┼───┨\n";
    //     const bottomBorder =
    //         "┗━━━┷━━━┷━━━┻━━━┷━━━┷━━━┻━━━┷━━━┷━━━┛\n";

    //     var lines: [19][]const u8 = undefined;
    //     lines[0] = topBorder;
    // }

    pub fn get(self: *const Self, coord: Coord) Cell {
        return self.cells[coord.ix];
    }

    pub fn set(self: *Self, coord: Coord, cell: Cell) void {
        self.cells[coord.ix] = cell;
    }

    pub fn getRow(self: *const Self, row_num: HouseIndex) [9]Cell {
        var output: [9]Cell = undefined;
        for (rowCoords(row_num), 0..9) |coord, i| {
            output[i] = self.get(coord);
        }
        return output;
    }

    fn setRow(self: *Self, row_num: HouseIndex, row: [9]Cell) void {
        const coords = rowCoords(row_num);
        for (row, coords) |cell, coord| {
            self.set(coord, cell);
        }
    }

    pub fn getCol(self: *const Self, col_num: HouseIndex) [9]Cell {
        var output: [9]Cell = undefined;
        for (colCoords(col_num), 0..9) |coord, i| {
            output[i] = self.get(coord);
        }
        return output;
    }

    fn setCol(self: *Self, col_num: HouseIndex, col: [9]Cell) void {
        const coords = colCoords(col_num);
        for (col, coords) |cell, coord| {
            self.set(coord, cell);
        }
    }

    pub fn getBox(self: *const Self, box_num: u4) [9]Cell {
        var output: [9]Cell = undefined;
        for (boxCoords(box_num), 0..9) |coord, i| {
            output[i] = self.get(coord);
        }
        return output;
    }

    fn setBox(self: *Self, box_num: HouseIndex, box: [9]Cell) void {
        const coords = colCoords(box_num);
        for (box, coords) |cell, coord| {
            self.set(coord, cell);
        }
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
        var row_iter = self.rows();
        var col_iter = self.cols();
        var box_iter = self.boxes();

        while (row_iter.next()) |row| {
            if (!houseIsOk(&row)) {
                return false;
            }
        }
        while (col_iter.next()) |col| {
            if (!houseIsOk(&col)) {
                return false;
            }
        }
        while (box_iter.next()) |box| {
            if (!houseIsOk(&box)) {
                return false;
            }
        }

        return true;
    }

    fn numberIsLegal(self: *const Self, coord: Coord, num: Number) bool {
        for (self.getRow(coord.parentRow())) |cell| {
            switch (cell) {
                .fixed => |fixed_num| {
                    if (fixed_num == num) return false;
                },
                .empty => {},
            }
        }

        for (self.getCol(coord.parentCol())) |cell| {
            switch (cell) {
                .fixed => |fixed_num| {
                    if (fixed_num == num) return false;
                },
                .empty => {},
            }
        }

        for (self.getBox(coord.parentBox())) |cell| {
            switch (cell) {
                .fixed => |fixed_num| {
                    if (fixed_num == num) return false;
                },
                .empty => {},
            }
        }

        return true;
    }

    fn hasSufficientHints(self: *const Self) bool {
        var count: u8 = 0;
        for (self.cells) |cell| {
            if (std.mem.eql(u8, @tagName(cell), "fixed")) {
                count += 1;
            }
        }
        return count >= 17;
    }

    fn prune(self: *Self) void {
        var old_grid: Self = undefined;
        var house: [9]Cell = undefined;

        while (!std.meta.eql(old_grid, self.*)) {
            old_grid = self.*;

            for (0..9) |i_usize| {
                const i: u4 = @intCast(i_usize);

                house = self.getRow(i);
                pruneHouse(&house);
                self.setRow(i, house);

                house = self.getCol(i);
                pruneHouse(&house);
                self.setCol(i, house);

                house = self.getBox(i);
                pruneHouse(&house);
                self.setBox(i, house);
            }
        }
    }

    fn pruneParents(self: *Self, coord: Coord) void {
        var house_index = coord.parentRow();
        var house = self.getRow(house_index);
        pruneHouse(&house);
        self.setRow(house_index, house);

        house_index = coord.parentCol();
        house = self.getCol(house_index);
        pruneHouse(&house);
        self.setCol(house_index, house);

        house_index = coord.parentBox();
        house = self.getBox(house_index);
        pruneHouse(&house);
        self.setBox(house_index, house);
    }

    pub fn solve(self: *Self) !void {
        // if (!self.isLegal()) {
        //     return error.IllegalPuzzle;
        // } else

        if (!self.hasSufficientHints()) {
            return error.TooFewHints;
        }

        // self.prune();

        const solved = try solveHelper(self, Coord.FIRST);

        self.* = solved;
    }
};

fn solveHelper(grid: *const Grid, c: Coord) !Grid {
    switch (grid.get(c)) {
        .fixed => {
            if (c.next()) |next| {
                return solveHelper(grid, next);
            } else {
                return grid.*;
            }
        },
        .empty => |possible| {
            var iter = possible.iterator();
            while (iter.next()) |num| {
                if (grid.numberIsLegal(c, num)) {
                    std.debug.print("Legal number: {any}\n", .{num});
                    var new_grid = grid.*;
                    new_grid.set(c, Cell{ .fixed = num });
                    if (c.next()) |next| {
                        new_grid.pruneParents(c);
                        const solved = try solveHelper(&new_grid, next);
                        return solved;
                    } else {
                        return new_grid;
                    }
                }
            }
            return error.NoSolutionFound;
        },
    }
}

fn pruneHouse(house: *[9]Cell) void {
    var fixed_nums = std.BoundedArray(Number, 9).init(0) catch unreachable;
    for (house) |cell| {
        switch (cell) {
            .fixed => |num| fixed_nums.append(num) catch unreachable,
            .empty => {},
        }
    }

    for (house, 0..) |cell, i| {
        switch (cell) {
            .empty => {
                for (fixed_nums.constSlice()) |num| {
                    house[i].empty.remove(num);
                }
                if (house[i].empty.single()) |num| {
                    house[i] = Cell{ .fixed = num };
                }
            },
            .fixed => {},
        }
    }
}

fn houseIsOk(house: *const [9]Cell) bool {
    for (0..8) |i| {
        const current = house[i];
        if (std.mem.eql(u8, @tagName(current), "fixed")) {
            const rest = house[(i + 1)..9];
            for (rest) |cell| {
                switch (cell) {
                    .fixed => {
                        if (cell.fixed == current.fixed) {
                            return false;
                        }
                    },
                    .empty => {},
                }
            }
        }
    }
    return true;
}

// const CellTag = enum { fixed, empty };

/// A Cell in a Sudoku grid
/// Can be a fixed value, or empty
/// Empty cells contain a set of possible numbers
pub const Cell = union(enum) {
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

    pub const INIT: Self = Self{ .empty = PossibleNums.INIT_ALL };
};

pub const Coord = struct {
    const Self = @This();

    ix: u7,

    pub const FIRST = Self{ .ix = 0 };

    pub fn index(self: Self) u7 {
        return self.ix;
    }

    pub fn fromRowCol(row: u4, col: u4) Self {
        const r = @as(u7, clampIndex(row));
        const c = @as(u7, clampIndex(col));
        return Self{ .ix = r * 9 + c };
    }

    pub fn parentRow(self: Self) HouseIndex {
        return @intCast(self.ix / 9);
    }

    pub fn parentCol(self: Self) HouseIndex {
        return @intCast(self.ix % 9);
    }

    pub fn parentBox(self: Self) HouseIndex {
        const row = self.parentRow();
        const col = self.parentCol();
        return @intCast((row / 3) * 3 + (col / 3));
    }

    pub fn next(self: Self) ?Self {
        return if (self.ix < 80)
            Self{ .ix = self.ix + 1 }
        else
            null;
    }
};

fn clampIndex(i: HouseIndex) HouseIndex {
    return if (i > 8) 8 else i;
}

fn rowCoords(row: HouseIndex) [9]Coord {
    var output: [9]Coord = undefined;
    for (0..9) |i| {
        output[i] = Coord.fromRowCol(clampIndex(row), @intCast(i));
    }
    return output;
}

fn colCoords(col: HouseIndex) [9]Coord {
    var output: [9]Coord = undefined;
    for (0..9) |i| {
        output[i] = Coord.fromRowCol(@intCast(i), clampIndex(col));
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
        output[i] = Coord.fromRowCol(@intCast(row), @intCast(col));
    }
    return output;
}

// TESTS
//
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

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

    try expect(std.mem.eql(u8, @tagName(fixed_cell), "fixed"));
    try expect(fixed_cell.fixed == Number.four);
    try expect(std.mem.eql(u8, @tagName(empty_cell), "empty"));
}

test Cell {
    const cell_1 = Cell.fromChar('1');
    try expect(std.mem.eql(u8, @tagName(cell_1), "fixed"));
    try expect(cell_1.fixed == Number.one);

    const cell_2 = Cell.fromChar('0');
    try expect(std.mem.eql(u8, @tagName(cell_2), "empty"));
    try expectEqual(PossibleNums.INIT_ALL, cell_2.empty);

    const cell_3 = Cell.fromChar('-');
    try expect(std.mem.eql(u8, @tagName(cell_3), "empty"));

    const cell_4 = Cell.INIT;
    try expect(std.mem.eql(u8, @tagName(cell_4), "empty"));
}

test "pruneHouse" {
    var house = [9]Cell{
        Cell{ .fixed = Number.one },
        Cell{ .fixed = Number.five },
        Cell.INIT,
        Cell.INIT,
        Cell.INIT,
        Cell.INIT,
        Cell.INIT,
        Cell{ .fixed = Number.three },
        Cell.INIT,
    };
    pruneHouse(&house);

    try expect(house[0].fixed == Number.one);
    try expect(house[1].fixed == Number.five);
    try expect(house[7].fixed == Number.three);

    var expected_possible = PossibleNums.INIT_ALL;
    expected_possible.remove(Number.one);
    expected_possible.remove(Number.five);
    expected_possible.remove(Number.three);

    const expected_cell = Cell{ .empty = expected_possible };

    try expectEqual(expected_cell, house[2]);
    try expectEqual(expected_cell, house[8]);

    var house_2 = [9]Cell{
        Cell{ .fixed = Number.one },
        Cell{ .fixed = Number.two },
        Cell{ .fixed = Number.three },
        Cell{ .fixed = Number.four },
        Cell{ .fixed = Number.five },
        Cell{ .fixed = Number.six },
        Cell{ .fixed = Number.seven },
        Cell{ .fixed = Number.eight },
        Cell.INIT,
    };

    pruneHouse(&house_2);

    try expectEqual(Cell{ .fixed = Number.nine }, house_2[8]);
}
