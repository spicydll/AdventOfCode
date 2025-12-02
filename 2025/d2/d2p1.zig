const std = @import("std");
const Reader = std.io.Reader;
const Writer = std.io.Writer;

const Range = struct {
    begin: usize,
    end: usize,

    pub fn parseRange(r: *Reader) !?Range {
        const range_str = try r.takeDelimiter(',') orelse return null;
        var num_split = std.mem.splitScalar(u8, range_str, '-');
        const begin = num_split.next().?;
        const end = num_split.next().?;
        std.debug.print("{s}-{s}\n", .{begin, end});
        return .{
            .begin = try std.fmt.parseInt(usize, begin, 10),
            .end = try std.fmt.parseInt(usize, end, 10),
        };
    }
};

pub fn main() !void {
    var invalid_id_sum: usize = 0;
    while (try Range.parseRange(stdin)) |range| {
        var cur_id: usize = range.begin;
        while (cur_id <= range.end) : (cur_id += 1) {
            const num_size: usize = @intFromFloat(std.math.log10(@as(f64, @floatFromInt(cur_id))));
            if (num_size & 1 == 1) {
                continue;
            }
            const half_size = num_size / 2;
            const half_to_10 = std.math.pow(usize, 10, half_size);
            const top_part = cur_id / half_to_10;
            const bottom_part = cur_id % half_to_10;

            if (top_part == bottom_part) {
                invalid_id_sum += cur_id;
                std.debug.print("{d} ({d} == {d})\n", .{cur_id, top_part, bottom_part});
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
