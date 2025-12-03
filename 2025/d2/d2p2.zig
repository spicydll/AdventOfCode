const std = @import("std");
const Reader = std.io.Reader;
const Writer = std.io.Writer;

const Range = struct {
    begin: usize,
    end: usize,

    pub fn parseRange(r: *Reader) !?Range {
        const range_str = try r.takeDelimiter(',') orelse return null;
        var num_split = std.mem.splitAny(u8, range_str, "-\r\n");
        const begin = num_split.next().?;
        const end = num_split.next().?;
        return .{
            .begin = try std.fmt.parseInt(usize, begin, 10),
            .end = try std.fmt.parseInt(usize, end, 10),
        };
    }
};

const SplitNumber = struct {
    high: usize,
    low: usize,

    pub fn split(number: usize) ?SplitNumber {
        const num_size = @as(usize, @intFromFloat(std.math.log10(@as(f64, @floatFromInt(number))))) + 1;
        if (num_size & 1 == 1) {
            return null;
        }
        const half_size = num_size / 2;
        const half_to_10 = std.math.pow(usize, 10, half_size);
        const top_part = number / half_to_10;
        const bottom_part = number % half_to_10;

        return .{
            .high = top_part,
            .low = bottom_part,
        };
    }
};

test SplitNumber {
    const TestCase = struct {
        expect: ?SplitNumber,
        input: usize,
    };
    const test_cases = [_]TestCase{
        .{ 
            .expect = .{ .high = 1234, .low = 5678 },
            .input = 12345678,
        },
        .{ 
            .expect = .{ .high = 5678, .low = 5678 },
            .input = 56785678,
        },
        .{ 
            .expect = null,
            .input = 5678567,
        },
    };

    for (test_cases) |case| {
        try std.testing.expectEqualDeep(case.expect, SplitNumber.split(case.input));
    }
}
pub fn main() !void {
    var invalid_id_sum: usize = 0;
    while (try Range.parseRange(stdin)) |range| {
        var cur_id: usize = range.begin;
        while (cur_id <= range.end) : (cur_id += 1) {
            const maybe_split: ?SplitNumber = .split(cur_id);
            if (maybe_split) |split| {
                if (split.high == split.low) {
                    invalid_id_sum += cur_id;
                    std.debug.print("{d} ({d} == {d})\n", .{cur_id, split.high, split.low});
                }
            }
        }
    }
    try stdout.print("Sum: {d}\n", .{invalid_id_sum});
    try stdout.flush();
}

var inbuf: [1024]u8 = undefined;
var in_reader = std.fs.File.stdin().reader(&inbuf);
const stdin = &in_reader.interface;

var outbuf: [1024]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&outbuf);
const stdout = &out_writer.interface;
