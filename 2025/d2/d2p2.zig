const std = @import("std");
const Reader = std.io.Reader;
const Writer = std.io.Writer;
const Allocator = std.mem.Allocator;

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

fn toStr(alloc: Allocator, number: usize) ![]u8 {
    return try std.fmt.allocPrint(alloc, "{d}", .{number}); 
}

fn isRepeating(string: []const u8) bool {
    outer: for (2..string.len + 1) |num_splits| {
        if (string.len % num_splits != 0) {
            continue;
        }
        const size = string.len / num_splits;
        const check = string[0..size];
        var idx = size;
        while (idx < string.len) : (idx += size) {
            const compare = string[idx..idx + size];
            if (!std.mem.eql(u8, check, compare)) {
                continue :outer;
            }
        }
        return true;
    }
    return false;
}

test isRepeating {
    try std.testing.expect(isRepeating("12341234"));
    try std.testing.expect(isRepeating("11111111"));
    try std.testing.expect(!isRepeating("11112111"));
    try std.testing.expect(isRepeating("1111111"));
    try std.testing.expect(!isRepeating("1211111"));
}

pub fn main() !void {
    const page_alloc = std.heap.page_allocator;
    var arena: std.heap.ArenaAllocator = .init(page_alloc);
    defer arena.deinit();
    const alloc = arena.allocator();
    
    var invalid_id_sum: usize = 0;
    while (try Range.parseRange(stdin)) |range| {
        var cur_id: usize = range.begin;
        while (cur_id <= range.end) : (cur_id += 1) {
            const id_str = try toStr(alloc, cur_id);
            defer alloc.free(id_str);

            if (isRepeating(id_str)) {
                invalid_id_sum += cur_id;
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
