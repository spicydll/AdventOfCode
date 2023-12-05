const std = @import("std");

const Mapping = struct {
    destination: u64,
    source: u64,
    range: u64,

    pub fn parseMapping(buf: []const u8) !Mapping {
        var mapping: Mapping = undefined;
        var splitter = std.mem.split(u8, buf, " ");

        const dest_str = splitter.next() orelse return error.ParseError;
        mapping.destination = try std.fmt.parseUnsigned(u64, dest_str, 10);

        const src_str = splitter.next() orelse return error.ParseError;
        mapping.source = try std.fmt.parseUnsigned(u64, src_str, 10);

        const range_str = splitter.next() orelse return error.ParseError;
        mapping.range = try std.fmt.parseUnsigned(u64, range_str, 10);

        return mapping;
    }

    pub fn map(self: Mapping, src_number: u64) ?u64 {
        if (src_number < self.source or (self.source + self.range) <= src_number) {
            return null;
        }

        const difference: u64 = src_number - self.source;

        return self.destination + difference;
    }
};

fn mapInList(mapping_list: []const Mapping, src_number: u64) u64 {
    for (mapping_list) |mapping| {
        if (mapping.map(src_number)) |dest_number| {
            return dest_number;
        }
    }

    return src_number;
}

const MappingList = []const Mapping;

fn parseMappingList(reader: anytype, allocator: std.mem.Allocator) !?MappingList {
    var buf: [1024]u8 = undefined;
    _ = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse return null;

    var mappingList = std.ArrayList(Mapping).init(allocator);
    defer mappingList.deinit();
    while (true) {
        const line = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse break;
        const mapping = Mapping.parseMapping(line) catch break;

        try mappingList.append(mapping);
    }

    return try mappingList.toOwnedSlice();
}

fn parseSeeds(reader: anytype, allocator: std.mem.Allocator) ![]const u64 {
    var buf: [1024]u8 = undefined;
    const line = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse return error.ParseError;

    var splitter = std.mem.split(u8, line, " ");
    _ = splitter.next();

    var seed_list = std.ArrayList(u64).init(allocator);
    defer seed_list.deinit();
    while (splitter.next()) |num_str| {
        const number = std.fmt.parseUnsigned(u64, num_str, 10) catch break;
        try seed_list.append(number);
    }

    return seed_list.toOwnedSlice();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    const seeds = try parseSeeds(stdin.reader(), allocator);

    try stdin.reader().skipUntilDelimiterOrEof('\n');

    var map_lists = std.ArrayList(MappingList).init(allocator);
    defer map_lists.deinit();

    while (try parseMappingList(stdin.reader(), allocator)) |mapping_list| {
        try map_lists.append(mapping_list);
    }

    const mapping_lists = try map_lists.toOwnedSlice();

    var low_location: ?u64 = null;
    for (seeds) |seed| {
        var src_num: u64 = seed;
        for (mapping_lists) |mapping_list| {
            src_num = mapInList(mapping_list, src_num);
        }

        if (low_location == null or src_num < low_location.?) {
            low_location = src_num;
        }
    }

    try std.io.getStdOut().writer().print("Low Location: {d}\n", .{low_location.?});
}
