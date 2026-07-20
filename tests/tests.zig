const std = @import("std");

const itertools = @import("zig_itertools");
const SliceIterator = itertools.SliceIterator;
const ChainIterator = itertools.ChainIterator;
const EmptyIterator = itertools.EmptyIterator;

test "SliceIterator" {
    const array = [_]i32{ 1, 2, 3 };
    var iterator = SliceIterator(i32).init(&array);

    var result = try itertools.collectTo(std.ArrayList(i32), std.testing.allocator, &iterator);
    defer result.deinit(std.testing.allocator);

    try std.testing.expectEqualDeep(&array, result.items);
}

test "ChainIterator" {
    const array1 = [_]i32{ 1, 2, 3 };
    var iterator1 = SliceIterator(i32).init(&array1);

    const array2 = [_]i32{ 9, 8, 7 };
    var iterator2 = SliceIterator(i32).init(&array2);

    var chain = ChainIterator(@TypeOf(iterator1), @TypeOf(iterator2), i32)
        .init(&iterator1, &iterator2);

    var result = try itertools.collectTo(std.ArrayList(i32), std.testing.allocator, &chain);
    defer result.deinit(std.testing.allocator);

    try std.testing.expectEqualDeep(&[_]i32{ 1, 2, 3, 9, 8, 7 }, result.items);
}

test "ChainIterator empty" {
    var iterator1 = EmptyIterator{};
    var iterator2 = EmptyIterator{};

    var chain = ChainIterator(@TypeOf(iterator1), @TypeOf(iterator2), void)
        .init(&iterator1, &iterator2);

    try std.testing.expect(chain.next() == null);
}
