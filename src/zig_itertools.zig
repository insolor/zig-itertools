pub fn SliceIterator(comptime T: type) type {
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

pub const EmptyIterator = struct {
    fn next(self: @This()) ?void {
        _ = self;
        return null;
    }
};
