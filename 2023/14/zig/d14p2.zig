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
    memos: [][]usize,
    const Self = @This();

    pub fn parseDish(reader: anytype, allocator: std.mem.Allocator) !Dish {
        var rocks_list = std.ArrayList([]RockType).init(allocator);
        defer rocks_list.deinit();
        var memos_list = std.ArrayList([]usize).init(allocator);
        defer memos_list.deinit();

        var cur_memos_list = std.ArrayList(usize).init(allocator);
        defer cur_memos_list.deinit();
        var cur_memos: ?[]usize = null;

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();

            var row_list = std.ArrayList(RockType).init(allocator);
            defer row_list.deinit();
            var memo_list = std.ArrayList(usize).init(allocator);
            defer memo_list.deinit();

            for (line) |c| {
                const rock = try RockType.fromChar(c);
                try row_list.append(rock);
                if (cur_memos == null) {
                    try cur_memos_list.append(0);
                }
            }

            if (cur_memos == null) {
                cur_memos = try cur_memos_list.toOwnedSlice();
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

    pub fn rollRocksWest(self: *Self) void {
        for (self.rocks[0], 0..) |_, col| {
            if (col == 0) {
                continue;
            }

            for (self.rocks, 0..) |_, row| {
                if (self.rocks[row][col] == RockType.round) {
                    var k: usize = col;
                    while (k > 0 and self.rocks[row][k] == RockType.empty) : (k -= 1) {
                        self.rocks[row][k - 1] = RockType.round;
                        self.rocks[row][k] = RockType.empty;
                    }
                }
            }
        }
    }

    pub fn rollRocksSouth(self: *Self) void {
        var row: usize = self.rocks.len - 2;
        while (row >= 0) : (row -= 1) {
            for (self.rocks[row], 0..) |_, col| {
                if (self.rocks[row][col] == RockType.round) {
                    var k: usize = row;
                    while (k < self.rocks.len - 1 and self.rocks[k + 1][col] == RockType.empty) : (k += 1) {
                        self.rocks[k + 1][col] = RockType.round;
                        self.rocks[k][col] = RockType.empty;
                    }
                }
            }
            if (row == 0) {
                break;
            }
        }
    }

    pub fn rollRocksEast(self: *Self) void {
        var col: usize = self.rocks[0].len - 2;
        while (col >= 0) : (col -= 1) {
            for (self.rocks, 0..) |_, row| {
                if (self.rocks[row][col] == RockType.round) {
                    var k: usize = col;
                    while (k < self.rocks[row].len - 1 and self.rocks[row][k + 1] == RockType.empty) : (k += 1) {
                        self.rocks[row][k + 1] = RockType.round;
                        self.rocks[row][k] = RockType.empty;
                    }
                }
            }
            if (col == 0) {
                break;
            }
        }
    }

    pub fn spinCycle(self: *Self, cycles: usize) void {
        var print_cycle: i32 = 0;
        for (0..cycles) |i| {
            defer print_cycle += 1;
            if (print_cycle >= 999999) {
                std.debug.print("Cycle: {d}\r", .{i + 1});
                print_cycle = -1;
            }
            self.rollRocksNorth();
            self.rollRocksWest();
            self.rollRocksSouth();
            self.rollRocksEast();
        }
        std.debug.print("\n", .{});
    }

    pub fn calculateLoad(self: *Self) u64 {
        self.spinCycle(1000000000);
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
