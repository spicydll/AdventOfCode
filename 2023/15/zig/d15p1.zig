const std = @import("std");

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

fn hashString(str: []const u8) u32 {
    var new_value: u32 = 0;

    for (str) |c| {
        new_value += @as(u32, @intCast(c));
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
