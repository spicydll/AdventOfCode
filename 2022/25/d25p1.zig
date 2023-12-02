const std = @import("std");

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;

    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

fn pow(x: i64, y: u64) i64 {
    var prod: i64 = 1;
    for (1..@as(usize, y)) |_| {
        prod *= x;
    }

    return prod;
}

fn fromSnafu(buffer: []const u8) ?i64 {
    var num: i64 = 0;

    for (buffer, 0..) |c, i| {
        const digit: ?i64 = switch (c) {
            '2' => 2,
            '1' => 1,
            '0' => 0,
            '-' => -1,
            '=' => -2,
            else => null,
        };

        if (digit) |d| {
            num += d * pow(5, @as(u64, @intCast(buffer.len - i)));
        } else {
            return null;
        }
    }

    return num;
}

fn toSnafu(number: i64, buffer: []u8) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var stack = std.ArrayList(u8).init(allocator);
    var carry = false;
    var digit: u8 = undefined;
    var l_number = number;

    while (l_number != 0) {
        var r: i64 = @mod(l_number, 5);
        defer l_number = @divFloor(l_number, 5);

        if (carry) {
            r += 1;
            carry = false;
        }

        if (r > 2) {
            r -= 5;
            carry = true;
        }
        digit = switch (r) {
            0 => '0',
            1 => '1',
            2 => '2',
            -2 => '=',
            -1 => '-',
            else => '?',
        };

        try stack.append(digit);
    }

    const stack_size = stack.items.len;
    for (0..stack_size) |i| {
        buffer[i] = stack.pop();
    }

    return stack_size;
}

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    var buffer: [64]u8 = undefined;
    var sum: i64 = 0;
    var out: [100]u8 = undefined;

    while (true) {
        const input = (try nextLine(stdin.reader(), &buffer)) orelse break;

        sum += fromSnafu(input).?;
    }

    const size: usize = (try toSnafu(sum, &out));
    try stdout.writer().print("Sum: {s}\n", .{out[0..size]});
}
