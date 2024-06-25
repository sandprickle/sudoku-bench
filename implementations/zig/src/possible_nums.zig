const std = @import("std");
const BitSet = std.bit_set.IntegerBitSet(9);
const Number = @import("number.zig").Number;

pub const PossibleNums = struct {
    const Self = @This();
    bits: BitSet,

    pub const INIT_ALL: PossibleNums = Self{ .bits = BitSet.initFull() };

    pub fn remove(self: *Self, num: Number) void {
        self.bits.unset(num.toInt() - 1);
    }

    pub fn single(self: Self) ?Number {
        if (self.bits.count() == 1) {
            if (self.bits.findFirstSet()) |i| {
                return Number.fromIntClamp(i + 1);
            }
        }

        return null;
    }
    pub const List = std.BoundedArray(Number, 9);
    pub fn list(self: Self) List {
        var nums = List.init(0) catch unreachable;

        var iter = self.iterator();
        while (iter.next()) |num| {
            nums.append(num) catch unreachable;
        }

        return nums;
    }

    pub fn iterator(self: Self) Iterator {
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
    var possible = PossibleNums.INIT_ALL;
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

// test "PossibleNums.Iterator" {
//     var possible = PossibleNums.ALL;
//     var iter1 = possible.iterator();

//     std.debug.print("\nAll Numbers:\n", .{});
//     while (iter1.next()) |num| {
//         std.debug.print("{any}\n", .{num});
//     }

//     possible.remove(Number.one);
//     possible.remove(Number.five);
//     possible.remove(Number.nine);

//     var iter2 = possible.iterator();
//     std.debug.print("\nFewer Numbers:\n", .{});
//     while (iter2.next()) |num| {
//         std.debug.print("{any}\n", .{num});
//     }

//     std.debug.print("\nA Single Number?\n", .{});
//     if (possible.single()) |num| {
//         std.debug.print("Yep: {any}", .{num});
//     } else {
//         std.debug.print("Nope.", .{});
//     }

//     possible.remove(Number.two);
//     possible.remove(Number.three);
//     possible.remove(Number.four);
//     possible.remove(Number.six);
//     possible.remove(Number.eight);

//     std.debug.print("\nA Single Number?\n", .{});
//     if (possible.single()) |num| {
//         std.debug.print("Yep: {any}", .{num});
//     } else {
//         std.debug.print("Nope.", .{});
//     }

//     std.debug.print("\ndone\n", .{});
// }
