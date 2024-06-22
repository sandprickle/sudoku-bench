const std = @import("std");
const BitSet = std.bit_set.IntegerBitSet(9);
const Number = @import("number.zig").Number;

pub const PossibleNums = struct {
    const Self = @This();
    bits: BitSet,

    pub const ALL: PossibleNums = Self{ .bits = BitSet.initFull() };

    pub fn remove(self: *Self, num: Number) void {
        self.bits.unset(num.toInt() - 1);
    }

    pub fn single(self: *Self) ?Number {
        if (self.bits.count() == 1) {
            if (self.bits.findFirstSet()) |i| {
                return Number.fromIntClamp(i + 1);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    pub fn iterator(self: *const Self) Iterator {
        return Iterator{ .bitIter = self.bits.iterator(.{}) };
    }

    pub const Iterator = struct {
        const IterSelf = @This();

        bitIter: BitSet.Iterator(.{}),

        pub fn next(self: *IterSelf) ?Number {
            if (self.bitIter.next()) |i| {
                return Number.fromIntClamp(i + 1);
            } else {
                return null;
            }
        }
    };
};

test PossibleNums {
    const expectEqual = std.testing.expectEqual;
    var possible = PossibleNums.ALL;
    possible.remove(Number.two);
    try expectEqual(null, possible.single());

    var iter = possible.iterator();
    try expectEqual(Number.one, iter.next());
    try expectEqual(Number.three, iter.next());

    possible.remove(Number.one);
    possible.remove(Number.three);
    possible.remove(Number.four);
    possible.remove(Number.six);
    possible.remove(Number.seven);
    possible.remove(Number.eight);
    possible.remove(Number.nine);

    try expectEqual(Number.five, possible.single());
}
