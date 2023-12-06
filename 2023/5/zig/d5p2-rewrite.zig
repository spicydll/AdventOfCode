const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,

    pub fn parseRange(buf: []const u8) ?Range {
        var splitter = std.mem.split(u8, buf, " ");

        var range: Range = undefined;

        const start_part = splitter.next() orelse return null;
        range.start = std.fmt.parseUnsigned(u64, start_part, 10) catch return null;

        const length_part = splitter.next() orelse return null;
        const length: u64 = std.fmt.parseUnsigned(u64, length_part, 10) catch return null;

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

    pub fn parseRangeMap(buf: []const u8) ?RangeMap {
        var splitter = std.mem.split(u8, buf, " ");

        var destination: Range = undefined;
        const destination_part = splitter.next() orelse return null;
        destination.start = std.fmt.parseUnsigned(u64, destination_part, 10) catch return null;

        if (destination_part.len + 1 >= buf.len) {
            return null;
        }

        const source_part = buf[(destination_part.len + 1)..];
        const source = Range.parseRange(source_part) orelse return null;

        destination.end = destination.start + (source.end - source.start);

        return .{ .source = source, .destination = destination };
    }
};
