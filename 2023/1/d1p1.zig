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

fn isDigit(c: u8) bool {
    return switch (c) {
        '0'...'9' => true,
        else => false,
    };
}

pub fn main() !void {
    var buffer: [64]u8 = undefined;
    var sum: u64 = 0;

    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    while (true) {
        const input = (try nextLine(stdin.reader(), &buffer)) orelse break;

        var num = [_]u8{ 0, 0 };
        var first = true;
        for (input) |c| {
            if (isDigit(c)) {
                if (first) {
                    num[0] = c;
                    first = false;
                } else {
                    num[1] = c;
                }
            }
        }
        if (num[1] == 0) num[1] = num[0];

        sum += (try std.fmt.parseInt(u64, &num, 10));
    }

    try stdout.writer().print("Sum: {d}\n", .{sum});
}
