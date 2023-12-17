const std = @import("std");

const Coordinate = struct {
    x: i32,
    y: i32,

    pub fn moveUp(self: Coordinate) Coordinate {
        return Coordinate{ .x = self.x, .y = self.y - 1 };
    }

    pub fn moveDown(self: Coordinate) Coordinate {
        return Coordinate{ .x = self.x, .y = self.y + 1 };
    }

    pub fn moveLeft(self: Coordinate) Coordinate {
        return Coordinate{ .x = self.x - 1, .y = self.y };
    }

    pub fn moveRight(self: Coordinate) Coordinate {
        return Coordinate{ .x = self.x + 1, .y = self.y };
    }

    pub fn xSize(self: Coordinate) usize {
        return @as(usize, @intCast(self.x));
    }

    pub fn ySize(self: Coordinate) usize {
        return @as(usize, @intCast(self.y));
    }
};

const Direction = enum {
    up,
    down,
    left,
    right,
};

const Beam = struct {
    coord: Coordinate,
    direction: Direction,

    pub fn moveRight(self: Beam) Beam {
        return Beam{ .coord = self.coord.moveRight(), .direction = Direction.right };
    }

    pub fn moveLeft(self: Beam) Beam {
        return Beam{ .coord = self.coord.moveLeft(), .direction = Direction.left };
    }

    pub fn moveUp(self: Beam) Beam {
        return Beam{ .coord = self.coord.moveUp(), .direction = Direction.up };
    }

    pub fn moveDown(self: Beam) Beam {
        return Beam{ .coord = self.coord.moveDown(), .direction = Direction.down };
    }
};

const TraverseResult = struct {
    beam1: Beam,
    beam2: ?Beam,
};

const Cell = enum {
    vertical,
    horizontal,
    leftDown,
    leftUp,
    empty,

    pub fn fromChar(c: u8) !Cell {
        return switch (c) {
            '|' => Cell.vertical,
            '-' => Cell.horizontal,
            '\\' => Cell.leftDown,
            '/' => Cell.leftUp,
            '.' => Cell.empty,
            else => error.InvalidCellChar,
        };
    }

    pub fn traverse(self: Cell, beam: Beam) TraverseResult {
        switch (self) {
            Cell.empty => {
                return switch (beam.direction) {
                    Direction.right => TraverseResult{
                        .beam1 = beam.moveRight(),
                        .beam2 = null,
                    },
                    Direction.left => TraverseResult{
                        .beam1 = beam.moveLeft(),
                        .beam2 = null,
                    },
                    Direction.up => TraverseResult{
                        .beam1 = beam.moveUp(),
                        .beam2 = null,
                    },
                    Direction.down => TraverseResult{
                        .beam1 = beam.moveDown(),
                        .beam2 = null,
                    },
                };
            },
            Cell.horizontal => {
                return switch (beam.direction) {
                    Direction.right => TraverseResult{
                        .beam1 = beam.moveRight(),
                        .beam2 = null,
                    },
                    Direction.left => TraverseResult{
                        .beam1 = beam.moveLeft(),
                        .beam2 = null,
                    },
                    Direction.up, Direction.down => TraverseResult{
                        .beam1 = beam.moveLeft(),
                        .beam2 = beam.moveRight(),
                    },
                };
            },
            Cell.vertical => {
                return switch (beam.direction) {
                    Direction.up => TraverseResult{
                        .beam1 = beam.moveUp(),
                        .beam2 = null,
                    },
                    Direction.down => TraverseResult{
                        .beam1 = beam.moveDown(),
                        .beam2 = null,
                    },
                    Direction.left, Direction.right => TraverseResult{
                        .beam1 = beam.moveUp(),
                        .beam2 = beam.moveDown(),
                    },
                };
            },
            Cell.leftUp => {
                return switch (beam.direction) {
                    Direction.right => TraverseResult{
                        .beam1 = beam.moveUp(),
                        .beam2 = null,
                    },
                    Direction.down => TraverseResult{
                        .beam1 = beam.moveLeft(),
                        .beam2 = null,
                    },
                    Direction.left => TraverseResult{
                        .beam1 = beam.moveDown(),
                        .beam2 = null,
                    },
                    Direction.up => TraverseResult{
                        .beam1 = beam.moveRight(),
                        .beam2 = null,
                    },
                };
            },
            Cell.leftDown => {
                return switch (beam.direction) {
                    Direction.right => TraverseResult{
                        .beam1 = beam.moveDown(),
                        .beam2 = null,
                    },
                    Direction.down => TraverseResult{
                        .beam1 = beam.moveRight(),
                        .beam2 = null,
                    },
                    Direction.left => TraverseResult{
                        .beam1 = beam.moveUp(),
                        .beam2 = null,
                    },
                    Direction.up => TraverseResult{
                        .beam1 = beam.moveLeft(),
                        .beam2 = null,
                    },
                };
            },
        }
    }
};

const Traversed = struct {
    up: bool,
    down: bool,
    left: bool,
    right: bool,
    const Self = @This();

    pub fn init() Traversed {
        return Traversed{
            .up = false,
            .down = false,
            .left = false,
            .right = false,
        };
    }

    pub fn inDirection(self: Traversed, direction: Direction) bool {
        return switch (direction) {
            Direction.up => self.up,
            Direction.down => self.down,
            Direction.left => self.left,
            Direction.right => self.right,
        };
    }

    pub fn markDirection(self: *Self, direction: Direction) void {
        switch (direction) {
            Direction.up => {
                self.up = true;
            },
            Direction.down => {
                self.down = true;
            },
            Direction.left => {
                self.left = true;
            },
            Direction.right => {
                self.right = true;
            },
        }
    }
};

const Contraption = struct {
    cells: []const []const Cell,
    energized: [][]bool,
    traversed: [][]Traversed,
    const Self = @This();

    pub fn parseContraption(reader: anytype, allocator: std.mem.Allocator) !Contraption {
        var cells_list = std.ArrayList([]const Cell).init(allocator);
        defer cells_list.deinit();

        var energized_list = std.ArrayList([]bool).init(allocator);
        defer energized_list.deinit();

        var traversed_list = std.ArrayList([]Traversed).init(allocator);
        defer traversed_list.deinit();

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
            const line = try line_list.toOwnedSlice();

            var cell_list = std.ArrayList(Cell).init(allocator);
            defer cell_list.deinit();

            var energized_row_list = std.ArrayList(bool).init(allocator);
            defer energized_row_list.deinit();

            var traversed_row_list = std.ArrayList(Traversed).init(allocator);
            defer traversed_row_list.deinit();

            for (line) |c| {
                const cell = try Cell.fromChar(c);
                try cell_list.append(cell);
                try energized_row_list.append(false);
                try traversed_row_list.append(Traversed.init());
            }

            const row = try cell_list.toOwnedSlice();
            try cells_list.append(row);

            const energized_row = try energized_row_list.toOwnedSlice();
            try energized_list.append(energized_row);

            const traversed_row = try traversed_row_list.toOwnedSlice();
            try traversed_list.append(traversed_row);
        }

        const cells = try cells_list.toOwnedSlice();
        const energized = try energized_list.toOwnedSlice();
        const traversed = try traversed_list.toOwnedSlice();
        return Contraption{ .cells = cells, .energized = energized, .traversed = traversed };
    }

    pub fn traverse(self: *Self, beam: Beam) void {
        if (!self.coordInBounds(beam.coord)) {
            return;
        }

        const x = beam.coord.xSize();
        const y = beam.coord.ySize();

        if (self.traversed[y][x].inDirection(beam.direction)) {
            return;
        }

        self.energized[y][x] = true;
        self.traversed[y][x].markDirection(beam.direction);

        const result = self.cells[y][x].traverse(beam);

        self.traverse(result.beam1);

        if (result.beam2) |beam2| {
            self.traverse(beam2);
        }
    }

    fn coordInBounds(self: Contraption, coord: Coordinate) bool {
        const xlen = self.cells[0].len;
        const ylen = self.cells.len;

        if (coord.x < 0 or coord.y < 0) {
            return false;
        }

        if (coord.xSize() >= xlen or coord.ySize() >= ylen) {
            return false;
        }

        return true;
    }

    pub fn countEnergized(self: Contraption) u32 {
        var sum: u32 = 0;
        for (self.energized) |row| {
            for (row) |col| {
                if (col) {
                    sum += 1;
                }
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

    const start_beam = Beam{ .coord = Coordinate{ .x = 0, .y = 0 }, .direction = Direction.right };
    var contraption = try Contraption.parseContraption(stdin.reader(), allocator);
    contraption.traverse(start_beam);

    const sum = contraption.countEnergized();

    try std.io.getStdOut().writer().print("Energized: {d}\n", .{sum});
}
