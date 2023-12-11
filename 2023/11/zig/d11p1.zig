const std = @import("std");

fn abs(num: i32) i32 {
    if (num < 0) {
        return num * -1;
    }

    return num;
}

const Coordinate = struct {
    x: i32,
    y: i32,

    pub fn distanceTo(self: Coordinate, coord: Coordinate) i32 {
        const rise = abs(coord.y - self.y);
        const run = abs(coord.x - self.x);

        return rise + run;
    }

    pub fn fromUSize(x: usize, y: usize) Coordinate {
        var coord: Coordinate = undefined;

        coord.x = @as(i32, @intCast(x));
        coord.y = @as(i32, @intCast(y));

        return coord;
    }
};

const Universe = struct {
    text: []const []const u8,

    pub fn parseUniverse(reader: anytype, allocator: std.mem.Allocator) !Universe {
        var text_list = std.ArrayList([]const u8).init(allocator);
        defer text_list.deinit();

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;

            const line = try line_list.toOwnedSlice();

            var empty = true;
            for (line) |c| {
                if (c == '#') {
                    empty = false;
                    break;
                }
            }

            if (empty) {
                const line_again = try allocator.dupe(u8, line);
                try text_list.append(line_again);
            }
            try text_list.append(line);
        }

        const text_col_unexpanded = try text_list.toOwnedSlice();
        var empty_col_list = std.ArrayList(bool).init(allocator);
        defer empty_col_list.deinit();
        for (text_col_unexpanded[0]) |col| {
            if (col == '#') {
                try empty_col_list.append(false);
            } else {
                try empty_col_list.append(true);
            }
        }
        var empty_cols = try empty_col_list.toOwnedSlice();

        for (text_col_unexpanded[1..]) |row| {
            for (row, 0..) |col, j| {
                if (empty_cols[j] and col == '#') {
                    empty_cols[j] = false;
                }
            }
        }

        var text_expanded_list = std.ArrayList([]const u8).init(allocator);
        defer text_expanded_list.deinit();

        for (text_col_unexpanded) |row| {
            var expanded_row_list = std.ArrayList(u8).init(allocator);
            defer expanded_row_list.deinit();

            for (row, empty_cols) |col, empty| {
                if (empty) {
                    try expanded_row_list.append(col);
                }
                try expanded_row_list.append(col);
            }

            const expanded_row = try expanded_row_list.toOwnedSlice();
            try text_expanded_list.append(expanded_row);
        }

        const text_expanded = try text_expanded_list.toOwnedSlice();

        var universe: Universe = undefined;
        universe.text = text_expanded;

        return universe;
    }

    pub fn measureDistances(self: Universe, allocator: std.mem.Allocator) !i32 {
        var coord_list = std.ArrayList(Coordinate).init(allocator);
        defer coord_list.deinit();

        for (self.text, 0..) |row, i| {
            for (row, 0..) |col, j| {
                if (col == '#') {
                    try coord_list.append(Coordinate.fromUSize(j, i));
                }
            }
        }

        const coords = try coord_list.toOwnedSlice();

        var sum: i32 = 0;
        for (coords[0..(coords.len - 1)], 0..) |coord0, i| {
            for (coords[(i + 1)..]) |coord1| {
                sum += coord0.distanceTo(coord1);
            }
        }

        return sum;
    }

    pub fn print(self: Universe, writer: anytype) !void {
        for (self.text) |line| {
            try writer.print("{s}\n", .{line});
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    const universe = try Universe.parseUniverse(stdin.reader(), allocator);

    try universe.print(stdout.writer());
    const sum = try universe.measureDistances(allocator);
    try stdout.writer().print("Sum: {d}\n", .{sum});
}
