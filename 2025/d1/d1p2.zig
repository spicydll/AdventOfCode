const std = @import("std");
const Reader = std.io.Reader;

fn parseLine(r: *Reader) !?i32 {
    const line = try r.takeDelimiter('\n') orelse return null;
    
    if (line.len < 2) {
        return error.BadInput;
    }

    const num = try std.fmt.parseInt(i32, line[1..], 10);
    return switch (line[0]) {
        'L' => -num,
        'R' => num,
        else => error.BadInput,
    };
}

pub fn main() !void {
    var pos: i32 = 50;
    var pass: u32 = 0;

    while (try parseLine(stdin)) |move| {
        try stdout.print("{d} -> ", .{pos});
        const dist_to_0: i32 = if (move < 0)
            pos
        else
            100 - pos;

        const remaining_move = if (move < 0)
            move + dist_to_0
        else
            move - dist_to_0;

           

        if (@abs(move) > dist_to_0) {
            pass += 1 + (@abs(move) / 100); 
        }
        while (pos < 0) {
            pos += 100;
        }
        while (pos >= 100) {
            pos -= 100;
        }
        if (pos == 0) {
            pass += 1;
        }
        try stdout.print("{d}\n", .{pos});
        try stdout.flush();
    }

    try stdout.print("Pass: {d}\n", .{pass});
    try stdout.flush();
}

var inbuf: [1024]u8 = undefined;
var in_reader = std.fs.File.stdin().reader(&inbuf);
const stdin = &in_reader.interface;

var outbuf: [1024]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&outbuf);
const stdout = &out_writer.interface;
