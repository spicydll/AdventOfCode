const std = @import("std");
const Reader = std.io.Reader;
const Writer = std.io.Writer;

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

fn moveCountZero(pos: *i32, move: i32) u32 {
    const super_pos = pos.* + move;
    var pass: u32 = @abs(@divFloor(super_pos, 100));
    const new_pos: i32 = @mod(super_pos, 100);

    if (move < 0) {
        if (pos.* == 0) {
            pass -|= 1;
        }
        if (new_pos == 0) {
            pass += 1;
        }
    }

    pos.* = new_pos;
    return pass;
}

test moveCountZero {
    var pos: i32 = 50;
    const pos_ptr = &pos;

    const TestCase = struct {
        move: i32,
        pos: i32,
        pass: u32,
    };

    const test_cases = [_]TestCase{
        .{ .move = -68, .pos = 82, .pass = 1 },
        .{ .move = -30, .pos = 52, .pass = 0 },
        .{ .move = 48, .pos = 0, .pass = 1 },
        .{ .move = -5, .pos = 95, .pass = 0 },
        .{ .move = 60, .pos = 55, .pass = 1 },
        .{ .move = -55, .pos = 0, .pass = 1 },
        .{ .move = -1, .pos = 99, .pass = 0 },
        .{ .move = -99, .pos = 0, .pass = 1 },
        .{ .move = 14, .pos = 14, .pass = 0 },
        .{ .move = -82, .pos = 32, .pass = 1 },
    };

    for (test_cases) |case| {
        try std.testing.expectEqual(case.pass, moveCountZero(pos_ptr, case.move));
        try std.testing.expectEqual(case.pos, pos);
    }
}

fn getPass(r: *Reader, w: *Writer) !u32 {
    var pos: i32 = 50;
    var pass: u32 = 0;

    while (try parseLine(r)) |move| {
        try w.print("{d} -> ", .{pos});
        pass += moveCountZero(&pos, move);

        try w.print("{d}\n", .{pos});
        try w.flush();
    }

    try w.print("Pass: {d}\n", .{pass});
    try w.flush();

    return pass;
}

test {
    const test_input = 
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;

    var test_reader: Reader = .fixed(test_input[0..]);
    const r = &test_reader;
    var the_void: [1024]u8 = undefined;
    var test_writer: Writer.Discarding = .init(&the_void);
    const w = &test_writer.writer;
    
    try std.testing.expectEqual(6, try getPass(r, w));
}

pub fn main() !void {
    _ = try getPass(stdin, stdout);
}

var inbuf: [1024]u8 = undefined;
var in_reader = std.fs.File.stdin().reader(&inbuf);
const stdin = &in_reader.interface;

var outbuf: [1024]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&outbuf);
const stdout = &out_writer.interface;
