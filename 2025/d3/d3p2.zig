const std = @import("std");
const Reader = std.io.Reader;
const Writer = std.io.Writer;
const Allocator = std.mem.Allocator;

fn parseBank(alloc: Allocator, r: *Reader) !?[]u8 {
    const line = try r.takeDelimiter('\n') orelse return null;
    if (line.len < 12) {
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
/// Asserts that bank is at least length 12 and consists of only ascii digits
fn largestJoltage(bank: []const u8) usize {
    const num_batts: comptime_int = 12;
    std.debug.assert(bank.len >= num_batts);
    // find largest possible first number
    var large_idxs: [num_batts]usize = blk: {
        var idxs: [num_batts]usize = undefined;
        for (&idxs, 0..) |*idx_ptr, idx_val| {
            idx_ptr.* = idx_val;
        }
        break :blk idxs;
    };
    for (&large_idxs, 0..) |*cur_large, cur_idx| {
        cur_large.* = if (cur_idx == 0) 0 else large_idxs[cur_idx - 1] + 1;
        const start_idx = cur_large.* + 1;
        const stop_idx = (bank.len - (num_batts - cur_idx)) + 1;
        for (bank[start_idx..stop_idx], start_idx..) |new_val, new_idx| {
            if (new_val > bank[cur_large.*]) {
                cur_large.* = new_idx;
            }
        }
    }
    const num_str: [num_batts]u8 = blk: {
        var str: [num_batts]u8 = undefined;
        for (&str, 0..) |*char, idx| {
            const batt = bank[large_idxs[idx]];
            std.debug.assert(batt >= '0' and batt <= '9');
            char.* = batt;
        }
        break :blk str;
    };

    return std.fmt.parseInt(usize, num_str[0..], 10) catch unreachable;
}

test largestJoltage {
    try std.testing.expectEqual(987654321111, largestJoltage("987654321111111"));
    try std.testing.expectEqual(811111111119, largestJoltage("811111111111119"));
    try std.testing.expectEqual(434234234278, largestJoltage("234234234234278"));
    try std.testing.expectEqual(888911112111, largestJoltage("818181911112111"));
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
