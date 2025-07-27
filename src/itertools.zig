const std = @import("std");

fn SliceIterator(comptime T: type) type {
    return struct {
        slice: []const T,
        index: usize = 0,

        const Self = @This();

        pub fn init(slice: []const T) Self {
            return Self{ .slice = slice };
        }

        pub fn next(self: *Self) ?T {
            if (self.index >= self.slice.len) return null;
            defer self.index += 1;
            return self.slice[self.index];
        }
    };
}

test "SliceIterator" {
    const array = [_]i32{ 1, 2, 3 };
    var iterator = SliceIterator(i32).init(&array);

    try std.testing.expectEqual(1, iterator.next().?);
    try std.testing.expectEqual(2, iterator.next().?);
    try std.testing.expectEqual(3, iterator.next().?);
    try std.testing.expect(iterator.next() == null);
}

pub fn ChainIterator(comptime I1: type, comptime I2: type, comptime R: type) type {
    const State = enum(u8) { it1, it2, end };

    return struct {
        iterator1: *I1,
        iterator2: *I2,
        state: State = .it1,

        const Self = @This();
        pub fn init(iterator1: *I1, iterator2: *I2) Self {
            return Self{
                .iterator1 = iterator1,
                .iterator2 = iterator2,
            };
        }

        pub fn next(self: *Self) ?R {
            st: switch (self.state) {
                .it1 => {
                    const value = self.iterator1.next();
                    if (value) |v| {
                        return v;
                    }
                    self.state = .it2;
                    continue :st .it2;
                },
                .it2 => {
                    const value = self.iterator2.next();
                    if (value) |v| {
                        return v;
                    }
                    self.state = .end;
                    continue :st .end;
                },
                .end => return null,
            }
        }
    };
}

test "ChainIterator" {
    const array1 = [_]i32{ 1, 2, 3 };
    var iterator1 = SliceIterator(i32).init(&array1);

    const array2 = [_]i32{ 9, 8, 7 };
    var iterator2 = SliceIterator(i32).init(&array2);

    var chain = ChainIterator(@TypeOf(iterator1), @TypeOf(iterator2), i32)
        .init(&iterator1, &iterator2);

    try std.testing.expectEqual(1, chain.next().?);
    try std.testing.expectEqual(2, chain.next().?);
    try std.testing.expectEqual(3, chain.next().?);
    try std.testing.expectEqual(9, chain.next().?);
    try std.testing.expectEqual(8, chain.next().?);
    try std.testing.expectEqual(7, chain.next().?);
    try std.testing.expect(chain.next() == null);
}

const EmptyIterator = struct {
    fn next(self: @This()) ?void {
        _ = self;
        return null;
    }
};

test "ChainIterator empty" {
    var iterator1 = EmptyIterator{};
    var iterator2 = EmptyIterator{};

    var chain = ChainIterator(@TypeOf(iterator1), @TypeOf(iterator2), void)
        .init(&iterator1, &iterator2);

    try std.testing.expect(chain.next() == null);
}
