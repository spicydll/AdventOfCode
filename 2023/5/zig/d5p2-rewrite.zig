const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,

    pub fn parseRange(buf: []const u8) !?Range {
        var splitter = std.mem.split(u8, buf, " ");

        var range: Range = undefined;

        const start_part = splitter.next() orelse return null;
        range.start = std.fmt.parseUnsigned(u64, start_part, 10) catch return error.ParseError;

        const length_part = splitter.next() orelse return error.ParseError;
        const length: u64 = std.fmt.parseUnsigned(u64, length_part, 10) catch return error.ParseError;

        range.end = range.start + length;

        return range;
    }

    pub fn matchRange(self: Range, range: Range) RangeMatchResult {
        var result: RangeMatchResult = .{ null, null, null };

        if (range.start < self.start) {
            result.low.start = range.start;

            // all are too low
            if (range.end < self.start) {
                result.low.end = range.end;
                return result;
            }

            result.low.end = self.start;
            result.match.start = self.start;
            if (range.end <= self.range.end) {
                result.match.end = range.end;
                return result;
            }

            result.match.end = self.end;
            result.high.start = self.end;
            result.high.end = range.end;
            return result;
        }

        if (range.start < self.end) {
            result.match.start = range.start;

            if (range.end <= self.end) {
                result.match.end = range.end;
                return result;
            }

            result.match.end = self.end;
            result.high.start = self.end;
            result.high.end = range.end;
            return result;
        }

        result.high.start = range.start;
        result.high.end = range.end;
        return result;
    }

    pub fn mergeRange(self: Range, merge: Range) RangeMergeResult {
        const matching = self.matchRange(merge);

        if (matching.match == null) {
            if (matching.high == null) {
                return .{ .low = merge, .high = self };
            }

            return .{ .low = self, .high = merge };
        }

        if (matching.high == null) {
            if (matching.low == null) {
                return .{ .low = self, .high = null };
            }

            return .{ .low = .{ .start = matching.low.start, .end = matching.match.end }, .high = null };
        }

        return .{ .low = .{ .start = matching.match.start, .end = matching.high.end }, .high = null };
    }

    pub fn lessThan(context: void, a: Range, b: Range) bool {
        _ = context;
        return a.start < b.start;
    }
};

const RangeMergeResult = struct { low: Range, high: ?Range };

const RangeMatchResult = struct {
    low: ?Range,
    match: ?Range,
    high: ?Range,
};

const RangeMapResult = struct {
    low: ?Range,
    mapped: ?Range,
    high: ?Range,
};

const RangeMap = struct {
    source: Range,
    destination: Range,

    pub fn parseRangeMap(buf: []const u8) !?RangeMap {
        var splitter = std.mem.split(u8, buf, " ");

        var destination: Range = undefined;
        const destination_part = splitter.next() orelse return null;
        destination.start = std.fmt.parseUnsigned(u64, destination_part, 10) catch return error.ParseError;

        if (destination_part.len + 1 >= buf.len) {
            return error.ParseError;
        }

        const source_part = buf[(destination_part.len + 1)..];
        const source = (try Range.parseRange(source_part)) orelse return error.ParseError;

        destination.end = destination.start + (source.end - source.start);

        return .{ .source = source, .destination = destination };
    }

    pub fn mapRange(self: RangeMap, range: Range) RangeMapResult {
        const matching = self.source.matchRange(range);

        var match = matching.match;

        if (match) |mapped| {
            match.start = self.destination.start + (mapped.start - self.source.start);
            match.end = self.destination.end - (self.source.end - mapped.end);
        }

        return .{
            .low = matching.low,
            .mapped = match,
            .high = matching.high,
        };
    }

    pub fn lessThan(context: void, a: RangeMap, b: RangeMap) bool {
        return Range.lessThan(context, a.source, b.source);
    }
};

const RangeMapSet = struct {
    name: []const u8,
    maps: []RangeMap,
    allocator: std.mem.Allocator,

    pub fn parseRangeMapSet(reader: std.io.AnyReader, allocator: std.mem.Allocator) !?RangeMapSet {
        var name_list = std.ArrayList(u8).init(allocator);
        defer name_list.deinit();

        reader.streamUntilDelimiter(name_list.writer(), '\n', null) catch return null;

        var range_map_set: RangeMapSet = undefined;
        range_map_set.name = try name_list.toOwnedSlice();

        var range_map_list = std.ArrayList(RangeMap).init(allocator);
        defer range_map_list.deinit();

        var line = std.ArrayList(u8).init(allocator);
        defer line.deinit();

        while (reader.streamUntilDelimiter(line.writer(), '\n', null)) {
            const line_str = line.toOwnedSlice();
            const range_map = (try RangeMap.parseRangeMap(line_str)) orelse break;
            try range_map_list.append(range_map);
        }

        var maps = range_map_list.toOwnedSlice();
        maps[0] = maps[0];
        std.mem.sort(RangeMap, maps, null, RangeMap.lessThan);
        range_map_set.maps = maps;
        range_map_set.allocator = allocator;

        return range_map_set;
    }

    pub fn mapRanges(self: RangeMapSet, ranges: []const Range) []Range {
        var mapped_ranges = std.ArrayList(Range).init(self.allocator);
        defer mapped_ranges.deinit();

        for ()
    }
};
