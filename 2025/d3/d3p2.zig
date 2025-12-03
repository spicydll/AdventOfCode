const std = @import("std");
const Reader = std.io.Reader;
const Writer = std.io.Writer;
const Allocator = std.mem.Allocator;

fn parseBank(alloc: Allocator, r: *Reader) !?[]u8 {
    const line = try r.takeDelimiter('\n') orelse return null;
    if (line.len < 2) {
        return error.BankTooSmall;
    }
    for (line) |char| {
        if (char < '0' or char > '9') {
            return error.InvalidBank;
        }
    }
    return try alloc.dupe(u8, line);
}

/// Calculates joltage from bank
/// Asserts that bank is at least length 2 and consists of only ascii digits
fn largestJoltage(bank: []const u8) usize {
    std.debug.assert(bank.len >= 2);
    // find largest possible first number
    var first_large_idx: usize = 0;
    for (bank[1..bank.len - 1], 1..) |first, idx| {
        if (first > bank[first_large_idx]) {
            first_large_idx = idx;
        }
    }

    // find largest possible second number
    var second_large_idx = first_large_idx + 1;
    for (bank[first_large_idx + 1..], first_large_idx + 1..) |second, idx| {
        if (second > bank[second_large_idx]) {
            second_large_idx = idx;
        }
    }

    const num_str: [2]u8 = .{ bank[first_large_idx], bank[second_large_idx] };
    std.debug.assert(num_str[0] >= '0' and num_str[0] <= '9');
    std.debug.assert(num_str[1] >= '0' and num_str[1] <= '9');
    return std.fmt.parseInt(usize, num_str[0..], 10) catch unreachable;
}

pub fn main() !void {
    const alloc = std.heap.smp_allocator;
    var sum: usize = 0;

    while (try parseBank(alloc, stdin)) |bank| {
        sum += largestJoltage(bank);
    }
    try stdout.print("Sum: {d}\n", .{sum});
    try stdout.flush();
}

var inbuf: [1024]u8 = undefined;
var in_reader = std.fs.File.stdin().reader(&inbuf);
const stdin = &in_reader.interface;

var outbuf: [1024]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&outbuf);
const stdout = &out_writer.interface;
