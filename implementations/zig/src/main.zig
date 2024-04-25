const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Puzzle = [9][9]Cell;

pub fn main() !void {
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const alloc = arena.allocator();

    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    const test_cell = "0";

    const cell = parseCell(test_cell);

    std.debug.print("Cell is: {any}", .{cell});
}

fn parseCsv(input: []const u8) [9][9]Cell {
    var output_puzzle = [_][9]Cell{DEFAULT_ROW} ** 9;

    var iter = std.mem.splitAny(u8, input, "\n");

    while (iter.next()) |row| {
        if (iter.index) |index| {
            output_puzzle[index] = parseRow(row);
        }
    }

    return output_puzzle;
}

fn parseRow(input: []const u8) [9]Cell {
    var output_row = DEFAULT_ROW;

    var iter = std.mem.splitScalar(u8, input, ',');
    std.debug.print("{any}\n", .{iter});

    const first = iter.first();
    output_row[0] = parseCell(first);

    while (iter.next()) |cell| {
        std.debug.print("Cell: {s}\n", .{cell});
        const index = iter.index.?;
        std.debug.print("Index: {any}\n", .{index});
        output_row[index] = parseCell(cell);
    }

    return output_row;
}

test parseRow {
    const empty_row = "0,0,0,0,0,0,0,0,0";

    try expectEqual(parseRow(empty_row), DEFAULT_ROW);
}

fn parseCell(input: []const u8) Cell {
    if (input.len >= 1) {
        const num: u8 = std.fmt.charToDigit(input[0], 10) catch {
            return DEFAULT_CELL;
        };

        if (num >= 1 and num <= 9) {
            return Cell{ .fixed = @as(u4, @intCast(num)) };
        } else {
            return DEFAULT_CELL;
        }
    } else {
        return DEFAULT_CELL;
    }
}

test parseCell {
    try expectEqual(parseCell("9"), Cell{ .fixed = 9 });

    try expectEqual(parseCell("0"), DEFAULT_CELL);
}

fn prettyPrint(puzzle: [81]Cell) !void {
    _ = puzzle;
    const templates = .{
        .line_top = "┏━━━┯━━━┯━━━┳━━━┯━━━┯━━━┳━━━┯━━━┯━━━┓\n",
        .line_mid_thin = "┠───┼───┼───╂───┼───┼───╂───┼───┼───┨\n",
        .line_mid_thick = "┣━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┫\n",
        .line_bottom = "┗━━━┷━━━┷━━━┻━━━┷━━━┷━━━┻━━━┷━━━┷━━━┛",
        .row = "┃ _ │ _ │ _ ┃ _ │ _ │ _ ┃ _ │ _ │ _ ┃\n",
    };

    _ = templates;
}

// fn toRows(puzzle: [81]Cell) [9]*const [9]Cell {
//     return [9]*const [9]Cell{ puzzle[0..9], puzzle[9..18], puzzle[18..27], puzzle[27..36], puzzle[36..45], puzzle[45..54], puzzle[54..63], puzzle[63..72], puzzle[72..81] };
// }

// Cell Type

const CellTag = enum {
    fixed,
    empty,
};

const Cell = union(CellTag) {
    fixed: u4,
    empty: [9]u4,
};

fn formatCell(cell: *const Cell) u8 {
    return switch (cell.*) {
        .fixed => |num| std.fmt.digitToChar(num, std.fmt.Case.upper),
        .empty => |_| ' ',
    };
}

const DEFAULT_CELL = Cell{ .empty = [9]u4{ 1, 2, 3, 4, 5, 6, 7, 8, 9 } };
const DEFAULT_ROW = [_]Cell{DEFAULT_CELL} ** 9;

const Cell2 = packed struct {
    const Self = @This();
    _1: bool,
    _2: bool,
    _3: bool,
    _4: bool,
    _5: bool,
    _6: bool,
    _7: bool,
    _8: bool,
    _9: bool,
    possibleCount: u4,

    pub fn default() Self {
        return Self{
            ._1 = true,
            ._2 = true,
            ._3 = true,
            ._4 = true,
            ._5 = true,
            ._6 = true,
            ._7 = true,
            ._8 = true,
            ._9 = true,
            .possibleCount = 9,
        };
    }

    pub fn isFixed(self: *Self) bool {
        return (self.possibleCount == 1);
    }

    pub fn isEmpty(self: *Self) bool {
        return (self.possibleCount != 1);
    }

    pub fn getNumber(self: *Self) ?u8 {
        return (if (self.isFixed())
            (if (self._1)
                1
            else if (self._2)
                2
            else if (self._3)
                3
            else if (self._4)
                4
            else if (self._5)
                5
            else if (self._6)
                6
            else if (self._7)
                7
            else if (self._8)
                8
            else if (self._9)
                9
            else
                null)
        else
            null);
    }

    pub fn removePossible(self: Self, n: u4) Self {
        if (n == 1) {
            if (self._1) {
                self.possibleCount -= 1;
            }

            self._1 = false;
        } else if (n == 2) {
            if (self._2) {
                self.possibleCount -= 1;
            }

            self._2 = false;
        } else if (n == 3) {
            if (self._3) {
                self.possibleCount -= 1;
            }

            self._3 = false;
        } else if (n == 4) {
            if (self._4) {
                self.possibleCount -= 1;
            }

            self._4 = false;
        } else if (n == 5) {
            if (self._5) {
                self.possibleCount -= 1;
            }

            self._5 = false;
        } else if (n == 6) {
            if (self._6) {
                self.possibleCount -= 1;
            }

            self._6 = false;
        } else if (n == 7) {
            if (self._7) {
                self.possibleCount -= 1;
            }

            self._7 = false;
        } else if (n == 8) {
            if (self._8) {
                self.possibleCount -= 1;
            }

            self._8 = false;
        } else if (n == 9) {
            if (self._9) {
                self.possibleCount -= 1;
            }

            self._9 = false;
        }
    }
};

const test_puzzle_1 =
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
