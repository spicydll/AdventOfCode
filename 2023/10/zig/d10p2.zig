const std = @import("std");

test {
    std.testing.refAllDecls(@This());
}

const Coordinate = struct {
    x: usize,
    y: usize,

    pub fn above(self: Coordinate, coord: Coordinate) bool {
        return self.x == coord.x and self.y == coord.y - 1;
    }

    pub fn below(self: Coordinate, coord: Coordinate) bool {
        return self.x == coord.x and self.y == coord.y + 1;
    }

    pub fn leftOf(self: Coordinate, coord: Coordinate) bool {
        return self.x == coord.x - 1 and self.y == coord.y;
    }

    pub fn rightOf(self: Coordinate, coord: Coordinate) bool {
        return self.x == coord.x + 1 and self.y == coord.y;
    }

    pub fn moveUp(self: Coordinate) Coordinate {
        return .{ .x = self.x, .y = self.y - 1 };
    }

    pub fn moveDown(self: Coordinate) Coordinate {
        return .{ .x = self.x, .y = self.y + 1 };
    }

    pub fn moveLeft(self: Coordinate) Coordinate {
        return .{ .x = self.x - 1, .y = self.y };
    }

    pub fn moveRight(self: Coordinate) Coordinate {
        return .{ .x = self.x + 1, .y = self.y };
    }

    pub fn rightOfEdge(self: Coordinate) bool {
        return self.x == 0;
    }

    pub fn leftOfEdge(self: Coordinate, right_edge: usize) bool {
        return self.x == right_edge - 1;
    }

    pub fn belowEdge(self: Coordinate) bool {
        return self.y == 0;
    }

    pub fn aboveEdge(self: Coordinate, bottom_edge: usize) bool {
        return self.y == bottom_edge - 1;
    }

    pub fn in(self: Coordinate, list: []const Coordinate) bool {
        for (list) |coord| {
            if (std.meta.eql(self, coord)) {
                return true;
            }
        }

        return false;
    }
};

const PipeTile = enum {
    vertical,
    horizontal,
    upToRight,
    leftToUp,
    downToRight,
    leftToDown,
    ground,
    start,

    pub fn pipeTile(tile: u8) PipeTile {
        return switch (tile) {
            '|' => PipeTile.vertical,
            '-' => PipeTile.horizontal,
            'L' => PipeTile.upToRight,
            'J' => PipeTile.leftToUp,
            'F' => PipeTile.downToRight,
            '7' => PipeTile.leftToDown,
            'S' => PipeTile.start,
            else => PipeTile.ground,
        };
    }

    pub fn traverse(self: PipeTile, entry: Coordinate, tile: Coordinate) ?Coordinate {
        var next: ?Coordinate = null;
        switch (self) {
            PipeTile.vertical => {
                if (entry.above(tile)) {
                    next = tile.moveDown();
                } else if (entry.below(tile)) {
                    next = tile.moveUp();
                }
            },
            PipeTile.horizontal => {
                if (entry.leftOf(tile)) {
                    next = tile.moveRight();
                } else if (entry.rightOf(tile)) {
                    next = tile.moveLeft();
                }
            },
            PipeTile.upToRight => {
                if (entry.above(tile)) {
                    next = tile.moveRight();
                } else if (entry.rightOf(tile)) {
                    next = tile.moveUp();
                }
            },
            PipeTile.leftToUp => {
                if (entry.leftOf(tile)) {
                    next = tile.moveUp();
                } else if (entry.above(tile)) {
                    next = tile.moveLeft();
                }
            },
            PipeTile.downToRight => {
                if (entry.below(tile)) {
                    next = tile.moveRight();
                } else if (entry.rightOf(tile)) {
                    next = tile.moveDown();
                }
            },
            PipeTile.leftToDown => {
                if (entry.leftOf(tile)) {
                    next = tile.moveDown();
                } else if (entry.below(tile)) {
                    next = tile.moveLeft();
                }
            },
            else => {
                next = null;
            },
        }

        return next;
    }
};

const Maze = struct {
    text: []const []const u8,
    start: Coordinate,

    fn findStart(self: Maze) !Coordinate {
        var coord: Coordinate = undefined;

        for (self.text, 0..) |row, i| {
            for (row, 0..) |c, j| {
                if (c == 'S') {
                    coord.x = j;
                    coord.y = i;
                    return coord;
                }
            }
        }

        return error.StartNotFound;
    }

    pub fn parseMaze(reader: anytype, allocator: std.mem.Allocator) !Maze {
        var maze_row_list = std.ArrayList([]const u8).init(allocator);
        defer maze_row_list.deinit();

        var line_list = std.ArrayList(u8).init(allocator);
        defer line_list.deinit();

        while (true) {
            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();
            try maze_row_list.append(line);
        }

        var maze: Maze = undefined;
        maze.text = try maze_row_list.toOwnedSlice();
        maze.start = try maze.findStart();
        return maze;
    }

    pub fn countInside(self: Maze, allocator: std.mem.Allocator) !usize {
        var cur_coord = self.start;
        const right_edge = self.text[0].len;
        const bottom_edge = self.text.len;
        var check_coords_list = std.ArrayList(Coordinate).init(allocator);
        defer check_coords_list.deinit();

        if (!self.start.rightOfEdge()) {
            try check_coords_list.append(self.start.moveLeft());
        }
        if (!self.start.belowEdge()) {
            try check_coords_list.append(self.start.moveUp());
        }
        if (!self.start.leftOfEdge(right_edge)) {
            try check_coords_list.append(self.start.moveRight());
        }
        if (!self.start.aboveEdge(bottom_edge)) {
            try check_coords_list.append(self.start.moveDown());
        }

        const check_coords = try check_coords_list.toOwnedSlice();
        if (check_coords.len == 0) {
            return error.LoopImpossible;
        }

        var loop_coords = std.ArrayList(Coordinate).init(allocator);
        defer loop_coords.deinit();
        try loop_coords.append(self.start);
        var next_coord: Coordinate = undefined;
        // find a way in from start
        for (check_coords) |coord| {
            if (self.at(coord).traverse(self.start, coord)) |next| {
                cur_coord = coord;
                try loop_coords.append(cur_coord);
                next_coord = next;
                break;
            }
        }

        // traverse the loop until start again
        while (self.at(next_coord).traverse(cur_coord, next_coord)) |next| {
            try loop_coords.append(next_coord);
            cur_coord = next_coord;
            next_coord = next;
        }

        const loop = try loop_coords.toOwnedSlice();

        var inside_coords = std.ArrayList(Coordinate).init(allocator);
        defer inside_coords.deinit();
        // Go right from every coord
        for (loop) |loop_coord| {
            cur_coord = loop_coord;
            var cur_coords = std.ArrayList(Coordinate).init(allocator);
            defer cur_coords.deinit();
            var inside = true;
            var last_in_loop = true;
            while (!cur_coord.leftOfEdge(right_edge)) {
                cur_coord = cur_coord.moveRight();

                if (cur_coord.in(loop)) {
                    if (last_in_loop) {
                        break;
                    }
                    if (inside) {
                        const new_coords = try cur_coords.toOwnedSlice();
                        try inside_coords.appendSlice(new_coords);
                    }
                    inside = !inside;
                    last_in_loop = true;
                } else if (inside) {
                    try cur_coords.append(cur_coord);
                    last_in_loop = false;
                }
            }
        }

        const inside_right = try inside_coords.toOwnedSlice();

        var inside_coords_down = std.ArrayList(Coordinate).init(allocator);
        defer inside_coords_down.deinit();
        for (inside_right) |inside_coord| {
            cur_coord = inside_coord;
            var loop_found = false;
            while (!cur_coord.aboveEdge(bottom_edge)) {
                cur_coord = cur_coord.moveDown();

                if (cur_coord.in(loop)) {
                    loop_found = !loop_found;
                }
            }

            if (loop_found) {
                try inside_coords_down.append(inside_coord);
            }
        }

        const inside_down = try inside_coords_down.toOwnedSlice();

        var inside_coords_up = std.ArrayList(Coordinate).init(allocator);
        defer inside_coords_up.deinit();

        for (inside_down) |inside_coord| {
            cur_coord = inside_coord;
            var loop_found = false;
            while (!cur_coord.belowEdge()) {
                cur_coord = cur_coord.moveUp();

                if (cur_coord.in(loop)) {
                    loop_found = !loop_found;
                }
            }

            if (loop_found) {
                try inside_coords_up.append(inside_coord);
            }
        }

        const inside_up = try inside_coords_up.toOwnedSlice();

        var inside_coords_left = std.ArrayList(Coordinate).init(allocator);
        defer inside_coords_left.deinit();

        for (inside_up) |inside_coord| {
            cur_coord = inside_coord;
            var loop_found = false;
            while (!cur_coord.rightOfEdge()) {
                cur_coord = cur_coord.moveLeft();

                if (cur_coord.in(loop)) {
                    loop_found = !loop_found;
                }
            }

            if (loop_found) {
                try inside_coords_left.append(inside_coord);
            }
        }

        const inside = try inside_coords_left.toOwnedSlice();
        //std.debug.print("{any}\n", .{inside});

        return inside.len;
    }

    pub fn at(self: Maze, coord: Coordinate) PipeTile {
        return PipeTile.pipeTile(self.text[coord.y][coord.x]);
    }

    fn initMazeTest() !Maze {
        var maze: Maze = undefined;
        const text: [5][]const u8 = .{
            ".....",
            ".S-7.",
            ".|FJ.",
            ".LJ..",
            ".....",
        };
        maze.text = &text;
        maze.start = try maze.findStart();

        return maze;
    }

    test "findStart" {
        const maze = try initMazeTest();
        const expected_coord: Coordinate = .{ .x = 1, .y = 1 };
        try std.testing.expectEqualDeep(expected_coord, maze.start);
    }

    test "startToGround" {
        const maze = try initMazeTest();
        const test_coord: Coordinate = .{ .x = 1, .y = 0 };
        const expected: ?Coordinate = null;
        const result = maze.at(test_coord).traverse(maze.start, test_coord);
        try std.testing.expectEqual(expected, result);
    }

    test "startToRight" {
        const maze = try initMazeTest();
        const test_coord: Coordinate = .{ .x = 2, .y = 1 };
        const expected: ?Coordinate = .{ .x = 3, .y = 1 };
        const result = maze.at(test_coord).traverse(maze.start, test_coord);
        try std.testing.expectEqual(expected, result);
    }

    test "horizontalToLeftDown" {
        const maze = try initMazeTest();
        const entry_coord: Coordinate = .{ .x = 2, .y = 1 };
        const test_coord: Coordinate = .{ .x = 3, .y = 1 };
        const expected: ?Coordinate = .{ .x = 3, .y = 2 };
        const result = maze.at(test_coord).traverse(entry_coord, test_coord);
        try std.testing.expectEqual(expected, result);
    }

    test "leftToUpFromUp" {
        const maze = try initMazeTest();
        const entry_coord: Coordinate = .{ .x = 3, .y = 1 };
        const test_coord: Coordinate = .{ .x = 3, .y = 2 };
        const expected: ?Coordinate = .{ .x = 2, .y = 2 };
        const result = maze.at(test_coord).traverse(entry_coord, test_coord);
        try std.testing.expectEqual(expected, result);
    }

    test "downToRightFromRight" {
        const maze = try initMazeTest();
        const entry_coord: Coordinate = .{ .x = 3, .y = 2 };
        const test_coord: Coordinate = .{ .x = 2, .y = 2 };
        const expected: ?Coordinate = .{ .x = 2, .y = 3 };
        const result = maze.at(test_coord).traverse(entry_coord, test_coord);
        try std.testing.expectEqual(expected, result);
    }

    test "measure" {
        const maze = try initMazeTest();
        const dist = maze.measure();
        const expected: u32 = 4;

        try std.testing.expectEqual(expected, dist);
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    var maze = try Maze.parseMaze(stdin.reader(), allocator);
    const dist = try maze.countInside(allocator);

    try std.io.getStdOut().writer().print("Inside Nodes: {d}\n", .{dist});
}
