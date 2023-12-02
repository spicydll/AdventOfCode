const std = @import("std");

const digits = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

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

fn isDigit(c: u8) bool {
    return switch (c) {
        '0'...'9' => true,
        else => false,
    };
}

fn parseTextDigit(text: []const u8) !?u8 {
    for (digits, '0'..) |digit, i| {
        if (text.len >= digit.len) {
            const slice = text[0..digit.len];
            var found = true;
            for (slice, digit) |t, d| {
                if (t != d) {
                    found = false;
                    break;
                }
            }
            if (found) return @as(?u8, @intCast(i));
        }
    }

    return null;
}

fn parseLine(line: []const u8) !?u64 {
    var num = [_]u8{ 0, 0 };
    var first = true;

    for (line, 0..) |c, i| {
        if (isDigit(c)) {
            if (first) {
                num[0] = c;
                first = false;
            } else {
                num[1] = c;
            }
        } else {
            if (first) {
                num[0] = (try parseTextDigit(line[i..])) orelse continue;
                first = false;
            } else {
                num[1] = (try parseTextDigit(line[i..])) orelse continue;
            }
        }
    }

    if (num[1] == 0) num[1] = num[0];

    return try std.fmt.parseInt(u64, &num, 10);
}

pub fn main() !void {
    var buffer: [64]u8 = undefined;
    var sum: u64 = 0;

    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    while (true) {
        const input = (try nextLine(stdin.reader(), &buffer)) orelse break;

        sum += (try parseLine(input)) orelse continue;
    }

    try stdout.writer().print("Sum: {d}\n", .{sum});
}
