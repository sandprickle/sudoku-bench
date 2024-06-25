const std = @import("std");
const smart_backtrack = @import("smart_backtrack.zig");
const number = @import("number.zig");
const possible_nums = @import("possible_nums.zig");
const expectEqual = std.testing.expectEqual;

const Number = number.Number;
const PossibleNums = possible_nums.PossibleNums;
const Cell = smart_backtrack.Cell;
const Coord = smart_backtrack.Coord;
const Grid = smart_backtrack.Grid;

pub fn main() !void {
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const alloc = arena.allocator();

    const stdout = std.io.getStdOut().writer();

    var puzzle = Grid.fromCsv(test_puzzle_1);

    try stdout.print("\n{any}\n", .{puzzle});
    try puzzle.solve();
    try stdout.print("\n{any}\n", .{puzzle});
}
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
