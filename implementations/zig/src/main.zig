const std = @import("std");
const grid = @import("grid.zig");
const expectEqual = std.testing.expectEqual;

const Cell = grid.Cell;
const Grid = grid.Grid;

pub fn main() !void {
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const alloc = arena.allocator();

    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    const puzzle = Grid.fromCsv(test_puzzle_1);
    _ = puzzle;
}

// fn parseCsv(input: []const u8) [9][9]Cell {
//     var output_puzzle = [_][9]Cell{DEFAULT_ROW} ** 9;

//     var iter = std.mem.splitAny(u8, input, "\n");

//     while (iter.next()) |row| {
//         if (iter.index) |index| {
//             output_puzzle[index] = parseRow(row);
//         }
//     }

//     return output_puzzle;
// }

// fn parseRow(input: []const u8) [9]Cell {
//     var output_row = DEFAULT_ROW;

//     var iter = std.mem.splitScalar(u8, input, ',');
//     std.debug.print("{any}\n", .{iter});

//     const first = iter.first();
//     output_row[0] = parseCell(first);

//     while (iter.next()) |cell| {
//         std.debug.print("Cell: {s}\n", .{cell});
//         const index = iter.index.?;
//         std.debug.print("Index: {any}\n", .{index});
//         output_row[index] = parseCell(cell);
//     }

//     return output_row;
// }

// test parseRow {
//     const empty_row = "0,0,0,0,0,0,0,0,0";

//     try expectEqual(parseRow(empty_row), DEFAULT_ROW);
// }

// fn parseCell(input: []const u8) Cell {
//     if (input.len >= 1) {
//         const num: u8 = std.fmt.charToDigit(input[0], 10) catch {
//             return DEFAULT_CELL;
//         };

//         if (num >= 1 and num <= 9) {
//             return Cell{ .fixed = @as(u4, @intCast(num)) };
//         } else {
//             return DEFAULT_CELL;
//         }
//     } else {
//         return DEFAULT_CELL;
//     }
// }

// test parseCell {
//     try expectEqual(parseCell("9"), Cell{ .fixed = 9 });

//     try expectEqual(parseCell("0"), DEFAULT_CELL);
// }

// fn prettyPrint(puzzle: [81]Cell) !void {
//     _ = puzzle;
//     const templates = .{
//         .line_top = "┏━━━┯━━━┯━━━┳━━━┯━━━┯━━━┳━━━┯━━━┯━━━┓\n",
//         .line_mid_thin = "┠───┼───┼───╂───┼───┼───╂───┼───┼───┨\n",
//         .line_mid_thick = "┣━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┫\n",
//         .line_bottom = "┗━━━┷━━━┷━━━┻━━━┷━━━┷━━━┻━━━┷━━━┷━━━┛",
//         .row = "┃ _ │ _ │ _ ┃ _ │ _ │ _ ┃ _ │ _ │ _ ┃\n",
//     };

//     _ = templates;
// }

// // fn toRows(puzzle: [81]Cell) [9]*const [9]Cell {
// //     return [9]*const [9]Cell{ puzzle[0..9], puzzle[9..18], puzzle[18..27], puzzle[27..36], puzzle[36..45], puzzle[45..54], puzzle[54..63], puzzle[63..72], puzzle[72..81] };
// // }

// // Cell Type

// const CellTag = enum {
//     fixed,
//     empty,
// };

// const Cell = union(CellTag) {
//     fixed: u4,
//     empty: [9]u4,
// };

// fn formatCell(cell: *const Cell) u8 {
//     return switch (cell.*) {
//         .fixed => |num| std.fmt.digitToChar(num, std.fmt.Case.upper),
//         .empty => |_| ' ',
//     };
// }

// const DEFAULT_CELL = Cell{ .empty = [9]u4{ 1, 2, 3, 4, 5, 6, 7, 8, 9 } };
// const DEFAULT_ROW = [_]Cell{DEFAULT_CELL} ** 9;

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
