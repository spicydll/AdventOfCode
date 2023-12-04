const std = @import("std");

const Card = struct {
    id: u32,
    winning_numbers: []u32,
    numbers: []u32,

    pub fn score(self: Card) u32 {
        var points: u32 = 0;
        for (self.numbers) |number| {
            for (self.winning_numbers) |winner| {
                if (number == winner) {
                    points = switch (points) {
                        0 => 1,
                        else => points * 2,
                    };
                }
            }
        }

        return points;
    }

    pub fn parse(reader: anytype, allocator: std.mem.Allocator) !?Card {
        var self: Card = undefined;
        var buf: [1024]u8 = undefined;

        const line = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse return null;

        var line_splitter = std.mem.split(u8, line, ":");
        const head_part = line_splitter.next() orelse return error.ParseError;
        const tail_part = line_splitter.next() orelse return error.ParseError;

        var head_splitter = std.mem.split(u8, head_part, " ");
        _ = head_splitter.next().?;
        while (head_splitter.next()) |id_str| {
            self.id = std.fmt.parseUnsigned(u32, id_str, 10) catch continue;
            break;
        }

        var tail_splitter = std.mem.split(u8, tail_part, "|");
        const winning_numbers_str = tail_splitter.next() orelse return error.ParseError;
        const numbers_str = tail_splitter.next() orelse return error.ParseError;

        var winning_numbers = std.ArrayList(u32).init(allocator);
        defer winning_numbers.deinit();
        var winner_splitter = std.mem.split(u8, winning_numbers_str, " ");

        _ = winner_splitter.next().?;
        while (winner_splitter.next()) |number_str| {
            const number: u32 = std.fmt.parseUnsigned(u32, number_str, 10) catch continue;
            try winning_numbers.append(number);
        }

        self.winning_numbers = try winning_numbers.toOwnedSlice();

        var numbers = std.ArrayList(u32).init(allocator);
        defer numbers.deinit();
        var number_splitter = std.mem.split(u8, numbers_str, " ");

        _ = number_splitter.next().?;
        while (number_splitter.next()) |number_str| {
            const number: u32 = std.fmt.parseUnsigned(u32, number_str, 10) catch continue;
            try numbers.append(number);
        }

        self.numbers = try numbers.toOwnedSlice();

        return self;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var cardsList = std.ArrayList(Card).init(allocator);

    const stdin = std.io.getStdIn().reader();
    while (try Card.parse(stdin, allocator)) |card| {
        try cardsList.append(card);
    }

    const cards = try cardsList.toOwnedSlice();

    var sum: u32 = 0;
    for (cards) |card| {
        sum += card.score();
    }

    try std.io.getStdOut().writer().print("Sum: {}\n", .{sum});
}
