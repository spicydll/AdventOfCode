const std = @import("std");

const Pull = struct { red: u32, green: u32, blue: u32 };

const Color = enum { red, green, blue };

// very much a hack!!
fn whichColor(buf: []const u8) ?Color {
    return switch (buf.len) {
        3 => Color.red,
        4 => Color.blue,
        5 => Color.green,
        else => null,
    };
}

const Game = struct {
    pullList: std.ArrayList(Pull),
    id: u32,

    pub fn init(allocator: std.mem.Allocator) Game {
        return Game{
            .id = undefined,
            .pullList = std.ArrayList(Pull).init(allocator),
        };
    }

    pub fn deinit(self: Game) void {
        self.pullList.deinit();
    }

    pub fn parseGame(reader: anytype, allocator: std.mem.Allocator) !?Game {
        var game = Game.init(allocator);
        var buffer: [1000]u8 = undefined;

        // Read in ID
        const idInput = (try reader.readUntilDelimiterOrEof(&buffer, ':')) orelse return null;
        var idSplitter = std.mem.split(u8, idInput, " ");
        _ = idSplitter.next().?; // Don't need first half
        const column_half = idSplitter.next() orelse return null;
        game.id = std.fmt.parseUnsigned(u32, column_half, 10) catch return error.ParseError;

        // Read in pullList
        const pullsInput = try reader.readUntilDelimiter(&buffer, '\n');
        var pullsSplitter = std.mem.split(u8, pullsInput, ";");
        while (true) {
            const singlePull = pullsSplitter.next() orelse break;
            //std.debug.print("Debug: {s}\n", .{singlePull});
            var colorSplitter = std.mem.split(u8, singlePull, ",");

            while (true) {
                var pull: Pull = .{ .red = 0, .green = 0, .blue = 0 };
                const singleColor = colorSplitter.next() orelse break;
                var valueSplitter = std.mem.split(u8, singleColor, " ");

                _ = valueSplitter.next().?;
                const col1 = valueSplitter.next() orelse return error.ParseError;
                const col2 = valueSplitter.next() orelse return error.ParseError;
                //std.debug.print("Num: {s}\n", .{col1});
                //std.debug.print("Color: {s}\n", .{col2});

                const num = std.fmt.parseUnsigned(u32, col1, 10) catch break;

                const color = whichColor(col2).?;
                switch (color) {
                    Color.red => {
                        pull.red = num;
                    },
                    Color.green => {
                        pull.green = num;
                    },
                    Color.blue => {
                        pull.blue = num;
                    },
                }

                try game.pullList.append(pull);
            }
        }

        return game;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    var gameList = std.ArrayList(Game).init(allocator);

    while (true) {
        const game = (try Game.parseGame(stdin.reader(), allocator)) orelse break;

        try gameList.append(game);
    }

    var sum: u32 = 0;
    for (gameList.items) |game| {
        var set: Pull = .{ .red = 0, .green = 0, .blue = 0 };

        for (game.pullList.items) |pull| {
            if (pull.red > set.red) {
                set.red = pull.red;
            }
            if (pull.green > set.green) {
                set.green = pull.green;
            }
            if (pull.blue > set.blue) {
                set.blue = pull.blue;
            }
        }
        const power = set.red * set.green * set.blue;
        sum += power;
    }

    try stdout.writer().print("Sum: {}\n", .{sum});
}
