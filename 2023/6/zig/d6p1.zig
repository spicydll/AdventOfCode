const std = @import("std");

const Race = struct {
    time: i32,
    distance: i32,

    pub fn checkWin(self: Race, hold_time: i32) bool {
        const time_left: i32 = self.time - hold_time;
        if (time_left <= 0) {
            return false;
        }

        const dist_traveled: i32 = time_left * hold_time;

        return self.distance < dist_traveled;
    }
};

pub fn main() !void {
    const races: [4]Race = .{ .{ .time = 46, .distance = 358 }, .{ .time = 68, .distance = 1054 }, .{ .time = 98, .distance = 1807 }, .{ .time = 66, .distance = 1080 } };

    var wins: [4]i32 = .{ 0, 0, 0, 0 };

    for (races, 0..) |race, i| {
        var hold_time: i32 = 1;

        while (hold_time < race.time) : (hold_time += 1) {
            if (race.checkWin(hold_time)) {
                wins[i] += 1;
            }
        }
    }

    var prod: i32 = 1;
    for (wins) |win| {
        prod *= win;
    }

    try std.io.getStdOut().writer().print("Product: {}\n", .{prod});
}
