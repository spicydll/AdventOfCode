const std = @import("std");

const HandType = enum { highCard, onePair, twoPair, threeOfAKind, fullHouse, fourOfAKind, fiveOfAKind };

fn cardValue(card: u8) u8 {
    return switch (card) {
        'A' => 13,
        'K' => 12,
        'Q' => 11,
        'J' => 10,
        'T' => 9,
        '2'...'9' => card - '0' - 1,
        else => 0,
    };
}

const Hand = struct {
    cards: []const u8,
    bid: u32,
    type: HandType,

    fn getType(self: Hand) HandType {
        var pop_count: u32 = 0;
        var pop_card: ?u8 = null;

        for (self.cards) |card| {
            if (pop_card != null and pop_card.? == card) {
                continue;
            }
            const card_count = self.count(card);

            if (card_count >= pop_count) {
                pop_count = card_count;

                if (card_count > 1) {
                    pop_card = card;
                }
            }
        }

        switch (pop_count) {
            5 => {
                return HandType.fiveOfAKind;
            },
            4 => {
                return HandType.fourOfAKind;
            },
            3 => {
                for (self.cards) |card| {
                    if (card != pop_card.?) {
                        if (self.count(card) == 2) {
                            return HandType.fullHouse;
                        }
                        return HandType.threeOfAKind;
                    }
                }
            },
            2 => {
                var found_card = false;

                for (self.cards) |card| {
                    if (card != pop_card.?) {
                        if (self.count(card) == 2) {
                            return HandType.twoPair;
                        }
                        if (found_card) {
                            return HandType.onePair;
                        }
                        found_card = true;
                    }
                }

                return HandType.onePair;
            },
            else => {
                return HandType.highCard;
            },
        }

        return HandType.highCard;
    }

    pub fn parseHands(reader: anytype, allocator: std.mem.Allocator) ![]Hand {
        var buf: [64]u8 = undefined;

        var hands = std.ArrayList(Hand).init(allocator);
        defer hands.deinit();
        while (true) {
            const line = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse break;

            var splitter = std.mem.split(u8, line, " ");
            const cards = splitter.next() orelse return error.ParseError;
            const bid_str = splitter.next() orelse return error.ParseError;
            const bid = try std.fmt.parseUnsigned(u32, bid_str, 10);
            var hand: Hand = undefined;
            hand.cards = try allocator.dupe(u8, cards);
            hand.bid = bid;
            hand.type = hand.getType();

            try hands.append(hand);
        }

        var sorted_hands = try hands.toOwnedSlice();
        sorted_hands[0] = sorted_hands[0];
        std.mem.sort(Hand, sorted_hands, {}, Hand.lessThan);

        return sorted_hands;
    }

    pub fn lessThan(context: void, a: Hand, b: Hand) bool {
        _ = context;
        const a_type = @intFromEnum(a.type);
        const b_type = @intFromEnum(b.type);

        if (a_type < b_type) {
            return true;
        }

        if (a_type > b_type) {
            return false;
        }

        for (a.cards, b.cards) |a_card, b_card| {
            const a_rank = cardValue(a_card);
            const b_rank = cardValue(b_card);

            if (a_rank < b_rank) {
                return true;
            }

            if (a_rank > b_rank) {
                return false;
            }
        }

        return false;
    }

    pub fn count(self: Hand, card: u8) u32 {
        var num: u32 = 0;
        for (self.cards) |c| {
            if (c == card) {
                num += 1;
            }
        }

        return num;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    const sorted_hands = try Hand.parseHands(stdin.reader(), allocator);

    var sum: u32 = 0;
    var rank: u32 = 1;

    for (sorted_hands) |hand| {
        defer rank += 1;
        std.debug.print("{} * {}: {s} ({})\n", .{ rank, hand.bid, hand.cards, hand.type });
        sum += rank * hand.bid;
    }

    try stdout.writer().print("Sum: {}\n", .{sum});
}
