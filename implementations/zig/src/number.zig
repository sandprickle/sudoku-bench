const std = @import("std");

pub const Number = enum {
    const Self = @This();
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,

    pub fn toInt(self: Self) u4 {
        return switch (self) {
            .one => 1,
            .two => 2,
            .three => 3,
            .four => 4,
            .five => 5,
            .six => 6,
            .seven => 7,
            .eight => 8,
            .nine => 9,
        };
    }

    pub fn fromIntClamp(int: usize) Self {
        return switch (int) {
            0, 1 => .one,
            2 => .two,
            3 => .three,
            4 => .four,
            5 => .five,
            6 => .six,
            7 => .seven,
            8 => .eight,
            else => .nine,
        };
    }

    pub fn toChar(self: Self) u8 {
        return switch (self) {
            .one => '1',
            .two => '2',
            .three => '3',
            .four => '4',
            .five => '5',
            .six => '6',
            .seven => '7',
            .eight => '8',
            .nine => '9',
        };
    }

    pub fn fromChar(char: u8) ?Self {
        return switch (char) {
            '1' => .one,
            '2' => .two,
            '3' => .three,
            '4' => .four,
            '5' => .five,
            '6' => .six,
            '7' => .seven,
            '8' => .eight,
            '9' => .nine,
            else => null,
        };
    }
};
