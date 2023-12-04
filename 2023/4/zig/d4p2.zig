const std = @import("std");

fn pow(x: u32, y: u32) u32 {
    if (y == 0) {
        return 1;
    }
    return x * pow(x, y - 1);
}

const Card = struct {
    id: u32,
    winning_numbers: []u32,
    numbers: []u32,

    pub fn numWinners(self: Card) u32 {
        var winners: u32 = 0;
        for (self.numbers) |number| {
            for (self.winning_numbers) |winner| {
                if (number == winner) {
                    winners += 1;
                }
            }
        }
        return winners;
    }

    pub fn score(self: Card) u32 {
        var points: u32 = 0;
        const winners = self.numWinners();

        if (winners > 0) {
            points = pow(2, winners - 1);
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

fn countCards(cards: []const Card, index: usize) u32 {
    if (index >= cards.len) {
        return 0;
    }

    const num_winners = cards[index].numWinners();
    var sum: u32 = 1;

    for ((index + 1)..(index + num_winners + 1)) |new_index| {
        sum += countCards(cards, new_index);
    }

    return sum;
}

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
    for (0..cards.len) |index| {
        sum += countCards(cards, index);
    }

    try std.io.getStdOut().writer().print("Sum: {}\n", .{sum});
}
