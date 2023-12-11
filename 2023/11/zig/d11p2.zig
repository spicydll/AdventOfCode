const std = @import("std");

fn abs(num: i128) i128 {
    if (num < 0) {
        return num * -1;
    }

    return num;
}

const Coordinate = struct {
    x: i128,
    y: i128,

    pub fn distanceTo(self: Coordinate, coord: Coordinate) i128 {
        const rise = abs(coord.y - self.y);
        const run = abs(coord.x - self.x);

        return rise + run;
    }

    pub fn fromUSize(x: usize, y: usize) Coordinate {
        var coord: Coordinate = undefined;

        coord.x = @as(i128, @intCast(x));
        coord.y = @as(i128, @intCast(y));

        return coord;
    }
};

const Universe = struct {
    coords: []const Coordinate,

    pub fn parseUniverse(reader: anytype, allocator: std.mem.Allocator) !Universe {
        var coord_list = std.ArrayList(Coordinate).init(allocator);
        defer coord_list.deinit();

        var text_list = std.ArrayList([]const u8).init(allocator);
        defer text_list.deinit();

        var row_empty_list = std.ArrayList(bool).init(allocator);
        defer row_empty_list.deinit();

        var i: usize = 0;
        while (true) : (i += 1) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();

            var empty = true;
            for (line, 0..) |c, j| {
                if (c == '#') {
                    empty = false;
                    try coord_list.append(Coordinate.fromUSize(j, i));
                }
            }
            try row_empty_list.append(empty);
            try text_list.append(line);
        }

        const text_unexpanded = try text_list.toOwnedSlice();
        const empty_rows = try row_empty_list.toOwnedSlice();
        var coords = try coord_list.toOwnedSlice();

        var empty_col_list = std.ArrayList(bool).init(allocator);
        defer empty_col_list.deinit();
        for (text_unexpanded[0]) |col| {
            if (col == '#') {
                try empty_col_list.append(false);
            } else {
                try empty_col_list.append(true);
            }
        }
        var empty_cols = try empty_col_list.toOwnedSlice();
        for (text_unexpanded[1..]) |row| {
            for (row, 0..) |col, j| {
                if (empty_cols[j] and col == '#') {
                    empty_cols[j] = false;
                }
            }
        }

        for (coords, 0..) |coord, coord_i| {
            const x_size: usize = @as(usize, @intCast(coord.x));
            const y_size: usize = @as(usize, @intCast(coord.y));

            for (empty_rows[0..y_size]) |row_empty| {
                if (row_empty) {
                    coords[coord_i].y += 999999;
                }
            }

            for (empty_cols[0..x_size]) |col_empty| {
                if (col_empty) {
                    coords[coord_i].x += 999999;
                }
            }
        }

        var universe: Universe = undefined;
        universe.coords = coords;

        return universe;
    }

    pub fn measureDistances(self: Universe) i128 {
        var sum: i128 = 0;
        for (self.coords[0..(self.coords.len - 1)], 0..) |coord0, i| {
            for (self.coords[(i + 1)..]) |coord1| {
                sum += coord0.distanceTo(coord1);
            }
        }

        return sum;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    const universe = try Universe.parseUniverse(stdin.reader(), allocator);

    //try universe.print(stdout.writer());
    const sum = universe.measureDistances();
    try stdout.writer().print("Sum: {d}\n", .{sum});
}
