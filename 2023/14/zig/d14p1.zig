const std = @import("std");

const RockType = enum {
    round,
    cube,
    empty,

    pub fn fromChar(c: u8) !RockType {
        return switch (c) {
            'O' => RockType.round,
            '#' => RockType.cube,
            '.' => RockType.empty,
            else => error.InvalidRockType,
        };
    }
};

const Dish = struct {
    rocks: [][]RockType,
    const Self = @This();

    pub fn parseDish(reader: anytype, allocator: std.mem.Allocator) !Dish {
        var rocks_list = std.ArrayList([]RockType).init(allocator);
        defer rocks_list.deinit();

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();

            var row_list = std.ArrayList(RockType).init(allocator);
            defer row_list.deinit();

            for (line) |c| {
                const rock = try RockType.fromChar(c);
                try row_list.append(rock);
            }

            const row = try row_list.toOwnedSlice();
            try rocks_list.append(row);
        }

        const rocks = try rocks_list.toOwnedSlice();

        return .{ .rocks = rocks };
    }

    pub fn rollRocksNorth(self: *Self) void {
        for (self.rocks, 0..) |row, i| {
            if (i == 0) {
                continue;
            }

            for (row, 0..) |_, j| {
                if (self.rocks[i][j] == RockType.round) {
                    var k: usize = i;
                    while (k > 0 and self.rocks[k - 1][j] == RockType.empty) : (k -= 1) {
                        self.rocks[k - 1][j] = RockType.round;
                        self.rocks[k][j] = RockType.empty;
                    }
                }
            }
        }
    }

    pub fn calculateLoad(self: *Self) u64 {
        self.rollRocksNorth();

        var load: u64 = 0;
        var row_load: u64 = @as(u64, @intCast(self.rocks.len));
        for (self.rocks) |row| {
            defer row_load -= 1;
            for (row) |col| {
                if (col == RockType.round) {
                    load += row_load;
                }
            }
        }

        return load;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    var dish = try Dish.parseDish(stdin.reader(), allocator);
    const load = dish.calculateLoad();

    try std.io.getStdOut().writer().print("Load: {d}\n", .{load});
}
