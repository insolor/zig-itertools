const std = @import("std");

const itertools = @import("zig_itertools");
const SliceIterator = itertools.SliceIterator;
const ChainIterator = itertools.ChainIterator;
const EmptyIterator = itertools.EmptyIterator;

test "SliceIterator" {
    const array = [_]i32{ 1, 2, 3 };
    var iterator = SliceIterator(i32).init(&array);

    try std.testing.expectEqual(1, iterator.next().?);
    try std.testing.expectEqual(2, iterator.next().?);
    try std.testing.expectEqual(3, iterator.next().?);
    try std.testing.expect(iterator.next() == null);
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

test "ChainIterator empty" {
    var iterator1 = EmptyIterator{};
    var iterator2 = EmptyIterator{};

    var chain = ChainIterator(@TypeOf(iterator1), @TypeOf(iterator2), void)
        .init(&iterator1, &iterator2);

    try std.testing.expect(chain.next() == null);
}
