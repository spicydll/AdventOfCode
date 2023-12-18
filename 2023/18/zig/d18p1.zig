const std = @import("std");

const Direction = enum {
    up,
    down,
    left,
    right,

    pub fn fromChar(c: u8) !Direction {
        return switch (c) {
            'U' => Direction.up,
            'D' => Direction.down,
            'L' => Direction.left,
            'R' => Direction.right,
            else => error.InvalidDirection,
        };
    }
};

const Instruction = struct {
    direction: Direction,
    distance: u32,

    pub fn parseInstruction(string: []const u8) !Instruction {
        var splitter = std.mem.splitScalar(u8, string, ' ');

        const dir_part = splitter.next() orelse return error.ParseError;
        if (dir_part.len > 1) {
            return error.ParseError;
        }
        const direction = try Direction.fromChar(dir_part[0]);

        const dist_part = splitter.next() orelse return error.ParseError;
        const distance: u32 = try std.fmt.parseUnsigned(u32, dist_part, 10);

        return Instruction{ .direction = direction, .distance = distance };
    }
};

const Coordinate = struct {
    x: i32,
    y: i32,

    pub fn move(self: Coordinate, instruction: Instruction) Coordinate {
        var new_coord = self;
        const dist: i32 = @as(i32, @intCast(instruction.distance));
        switch (instruction.direction) {
            Direction.up => new_coord.y += dist,
            Direction.down => new_coord.y -= dist,
            Direction.left => new_coord.x -= dist,
            Direction.right => new_coord.x += dist,
        }

        return new_coord;
    }

    pub fn origin() Coordinate {
        return Coordinate{ .x = 0, .y = 0 };
    }
};

fn parseInstructions(allocator: std.mem.Allocator, reader: anytype) ![]const Instruction {
    var ins_list = std.ArrayList(Instruction).init(allocator);
    defer ins_list.deinit();

    while (true) {
        var line_list = std.ArrayList(u8).init(allocator);
        defer line_list.deinit();

        reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;
        const line = try line_list.toOwnedSlice();
        const ins = try Instruction.parseInstruction(line);

        try ins_list.append(ins);
    }

    return try ins_list.toOwnedSlice();
}

fn calcArea(instructions: []const Instruction) i32 {
    var area: i32 = 0;
    var perimeter: i32 = 0;
    var last_coord = Coordinate.origin();

    for (instructions) |ins| {
        const cur_coord = last_coord.move(ins);
        area += (last_coord.x * cur_coord.y) - (cur_coord.x * last_coord.y);
        perimeter += @as(i32, @intCast(ins.distance));
        last_coord = cur_coord;
    }

    if (area < 0) {
        area *= -1;
    }

    area = @divFloor(area - perimeter, 2) + perimeter + 1;
    return area;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    const instructions = try parseInstructions(allocator, stdin.reader());
    const area = calcArea(instructions);

    try std.io.getStdOut().writer().print("Area: {d} cubic meters\n", .{area});
}
