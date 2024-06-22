const std = @import("std");

pub const Coord = struct {
    const Self = @This();

    index: u7,

    pub fn index(self: *const Self) u7 {
        return self.index;
    }

    pub fn from_row_col(row: u4, col: u4) Self {
        return Self{ .row = row, .col = col };
    }

    pub fn to_row_col(self: *const Self) .{ .row = u4, .col = u4 } {
        return .{
            .row = self.index / 9,
            .col = self.index % 9,
        };
    }
};
