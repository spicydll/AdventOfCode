const std = @import("std");

const Operation = enum {
    remove,
    assign,

    pub fn fromChar(c: u8) !Operation {
        return switch (c) {
            '-' => Operation.remove,
            '=' => Operation.assign,
            else => error.InvalidOperation,
        };
    }
};

const Lens = struct {
    label: []const u8,
    focal_length: u8,
    const Self = @This();

    pub fn is(self: Self, str: []const u8) bool {
        return std.mem.eql(u8, self.label, str);
    }
};

const Instruction = struct {
    label: []const u8,
    label_hash: usize,
    operation: Operation,
    focal_length: ?u8,

    pub fn parseInstruction(str: []const u8, allocator: std.mem.Allocator) !Instruction {
        var label_list = std.ArrayList(u8).init(allocator);
        defer label_list.deinit();

        var operation: ?Operation = null;
        var i: usize = 1;
        for (str) |c| {
            const opOrNull: ?Operation = Operation.fromChar(c) catch null;

            if (opOrNull) |op| {
                operation = op;
                break;
            } else {
                try label_list.append(c);
            }
            i += 1;
        }

        if (operation == null) {
            return error.InstructionParseError;
        }

        var focal_length: ?u8 = null;
        if (operation == Operation.assign) {
            focal_length = try std.fmt.parseUnsigned(u8, str[i..], 10);
        }

        const label = try label_list.toOwnedSlice();
        const label_hash = hashString(label);
        return Instruction{ .label = label, .label_hash = label_hash, .operation = operation, .focal_length = focal_length };
    }
};

const Box = []Lens;

const HASHMAP = struct {
    boxes: [256]Box,
    allocator: std.mem.Allocator,
    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        var hashmap: HASHMAP = undefined;

        for (hashmap.boxes, 0..) |_, i| {
            hashmap.boxes[i] = &.{};
        }

        hashmap.allocator = allocator;
        return hashmap;
    }

    pub fn deinit(self: *Self) void {
        for (self.boxes, 0..) |_, i| {
            self.boxes[i].deinit();
        }
    }

    pub fn step(self: *Self, instruction: Instruction) !void {
        const box: *Box = &self.boxes[instruction.label_hash];
        switch (instruction.operation) {
            Operation.remove => {
                var cur_box_list: std.ArrayList(Lens) = try std.ArrayList(Lens).fromOwnedSlice(self.allocator, box.*);
                defer cur_box_list.deinit();
                for (box, 0..) |item, i| {
                    if (item.is(instruction.label)) {
                        cur_box_list.orderedRemove(i);
                        box.* = try cur_box_list.toOwnedSlice();
                        return;
                    }
                }
            },
            Operation.assign => {
                for (box, 0..) |item, i| {
                    if (item.is(instruction.label)) {
                        box[i].focal_length = instruction.focal_length.?;
                        return;
                    }
                }

                var cur_box_list: std.ArrayList(Lens) = try std.ArrayList(Lens).fromOwnedSlice(self.allocator, box.*);
                defer cur_box_list.deinit();

                const lens: Lens = .{ .label = instruction.label, .focal_length = instruction.focal_length.? };
                try cur_box_list.append(lens);
                box.* = try cur_box_list.toOwnedSlice();
            },
        }
    }
};

fn parseInput(reader: anytype, allocator: std.mem.Allocator) ![]const []const u8 {
    var string_list = std.ArrayList([]const u8).init(allocator);
    defer string_list.deinit();

    var line_list = std.ArrayList(u8).init(allocator);
    defer line_list.deinit();

    try reader.streamUntilDelimiter(line_list.writer(), '\n', null);
    const line = try line_list.toOwnedSlice();

    var splitter = std.mem.splitScalar(u8, line, ',');

    while (splitter.next()) |part| {
        const part_copy = try allocator.dupe(u8, part);
        try string_list.append(part_copy);
    }

    return try string_list.toOwnedSlice();
}

fn hashString(str: []const u8) usize {
    var new_value: usize = 0;

    for (str) |c| {
        new_value += @as(usize, @intCast(c));
        new_value *= 17;
        new_value = new_value % 256;
    }

    return new_value;
}

fn initTest(allocator: std.mem.Allocator) ![]const []const u8 {
    var strings_list = std.ArrayList([]const u8).init(allocator);
    defer strings_list.deinit();

    try strings_list.append("rn=1");
    try strings_list.append("cm-");
    try strings_list.append("qp=3");
    try strings_list.append("cm=2");
    try strings_list.append("qp-");
    try strings_list.append("pc=4");
    try strings_list.append("ot=9");
    try strings_list.append("ab=5");
    try strings_list.append("pc-");
    try strings_list.append("pc=6");
    try strings_list.append("ot=7");
    return try strings_list.toOwnedSlice();
}

fn expectedHashResults(allocator: std.mem.Allocator) ![]const u32 {
    var expected_list = std.ArrayList(u32).init(allocator);
    defer expected_list.deinit();

    try expected_list.append(30);
    try expected_list.append(253);
    try expected_list.append(97);
    try expected_list.append(47);
    try expected_list.append(14);
    try expected_list.append(180);
    try expected_list.append(9);
    try expected_list.append(197);
    try expected_list.append(48);
    try expected_list.append(214);
    try expected_list.append(231);

    return try expected_list.toOwnedSlice();
}

test "hash" {
    const string = "HASH";
    const expected: u32 = 52;

    const actual = hashString(string);
    try std.testing.expectEqual(expected, actual);
}

test "second" {
    const expected: u32 = 253;

    const actual = hashString("cm-");
    try std.testing.expectEqual(expected, actual);
}

test "main" {
    const allocator = std.heap.page_allocator;

    const strings = try initTest(allocator);
    const expected_result = try expectedHashResults(allocator);

    for (strings, expected_result) |string, expected| {
        const current_value = hashString(string);
        try std.testing.expectEqual(expected, current_value);
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    const strings = try parseInput(stdin.reader(), allocator);

    var sum: u32 = 0;
    for (strings) |str| {
        sum += hashString(str);
    }

    try std.io.getStdOut().writer().print("Sum: {d}\n", .{sum});
}
