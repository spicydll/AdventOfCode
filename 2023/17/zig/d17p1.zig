const std = @import("std");

const Vertex = struct {
    x: usize,
    y: usize,
};

const Graph = struct {
    points: []const []const u8,
    allocator: std.mem.Allocator,
    const Self = @This();

    pub fn parseGraph(reader: anytype, allocator: std.mem.Allocator) !Graph {
        var points_list = std.ArrayList([]const u8).init(allocator);
        defer points_list.deinit();

        while (true) {
            var line_list = std.ArrayList(u8).init(allocator);
            defer line_list.deinit();

            reader.streamUntilDelimiter(line_list.writer(), '\n', null) catch break;

            const line = try line_list.toOwnedSlice();
            var points_row_list = std.ArrayList(u8).init(allocator);
            defer points_row_list.deinit();

            for (line, 0..) |_, i| {
                const point = try std.fmt.parseUnsigned(u8, line[i .. i + 1], 10);
                try points_row_list.append(point);
            }

            const points_row = try points_row_list.toOwnedSlice();
            try points_list.append(points_row);
        }

        const points = try points_list.toOwnedSlice();

        return Graph{ .points = points, .allocator = allocator };
    }

    pub fn deinit(self: Self) void {
        for (self.points, 0..) |_, i| {
            self.allocator.free(self.points[i]);
        }
        self.allocator.free(self.points);
    }

    pub fn dijkstra(self: Graph) !u32 {
        var dist_list = std.ArrayList([]u32).init(self.allocator);
        defer dist_list.deinit();

        var last_list = std.ArrayList([]?Vertex).init(self.allocator);
        defer last_list.deinit();

        var queue_list = std.ArrayList(Vertex).init(self.allocator);
        defer queue_list.deinit();

        for (self.points, 0..) |row, i| {
            var dist_row_list = std.ArrayList(u32).init(self.allocator);
            defer dist_row_list.deinit();

            var last_row_list = std.ArrayList(?Vertex).init(self.allocator);
            defer last_row_list.deinit();
            for (row, 0..) |_, j| {
                try dist_row_list.append(std.math.maxInt(u32));
                try last_row_list.append(null);
                try queue_list.append(Vertex{ .x = j, .y = i });
            }
            const dist_row = try dist_row_list.toOwnedSlice();
            try dist_list.append(dist_row);

            const last_row = try last_row_list.toOwnedSlice();
            try last_list.append(last_row);
        }

        var dist = try dist_list.toOwnedSlice();
        defer self.allocator.free(dist);
        var last = try last_list.toOwnedSlice();
        defer self.allocator.free(last);
        dist[0][0] = 0;

        while (queue_list.items.len > 0) {
            var next_vertex: Vertex = queue_list.items[0];
            var next_vertex_dist: u32 = dist[next_vertex.y][next_vertex.x];
            var next_vertex_i: usize = 0;
            for (queue_list.items[1..], 1..) |vertex, i| {
                const cur_vertext_dist = dist[vertex.y][vertex.x];
                if (cur_vertext_dist < next_vertex_dist) {
                    next_vertex_dist = cur_vertext_dist;
                    next_vertex = vertex;
                    next_vertex_i = i;
                }
            }

            std.debug.print("Next vertex: {any}\n", .{next_vertex});
            _ = queue_list.orderedRemove(next_vertex_i);
            var neighbors_list = std.ArrayList(Vertex).init(self.allocator);
            defer neighbors_list.deinit();

            var last_last = next_vertex;
            var cur_last = last[next_vertex.y][next_vertex.x];
            var row_count: usize = 0;
            var row_direction_horizontal: bool = undefined;
            while (cur_last) |cur_last_vertex| {
                if (row_count == 0) {
                    if (last_last.y == cur_last_vertex.y) {
                        row_direction_horizontal = true;
                    } else {
                        row_direction_horizontal = false;
                    }
                    row_count = 1;
                    continue;
                }

                if (row_count >= 3 or (row_direction_horizontal and last_last.y != cur_last_vertex.y) or (!row_direction_horizontal and last_last.x != cur_last_vertex.x)) {
                    break;
                }
                row_count += 1;
                last_last = cur_last_vertex;
                cur_last = last[cur_last_vertex.y][cur_last_vertex.x];
            }

            const last_vertex = last[next_vertex.y][next_vertex.x];
            if (row_count < 3 or row_direction_horizontal) {
                if (next_vertex.y > 0) {
                    const up_vertex = Vertex{ .y = next_vertex.y - 1, .x = next_vertex.x };
                    if (last_vertex == null or !std.meta.eql(up_vertex, last_vertex.?)) {
                        try neighbors_list.append(up_vertex);
                    }
                }
                if (next_vertex.y < self.points.len - 1) {
                    const down_vertex = Vertex{ .y = next_vertex.y + 1, .x = next_vertex.x };
                    if (last_vertex == null or !std.meta.eql(down_vertex, last_vertex.?)) {
                        try neighbors_list.append(down_vertex);
                    }
                }
            }
            if (row_count < 3 or !row_direction_horizontal) {
                if (next_vertex.x > 0) {
                    const left_vertex = Vertex{ .x = next_vertex.x - 1, .y = next_vertex.y };
                    if (last_vertex == null or !std.meta.eql(left_vertex, last_vertex.?)) {
                        try neighbors_list.append(left_vertex);
                    }
                }
                if (next_vertex.y < self.points[0].len - 1) {
                    const right_vertex = Vertex{ .x = next_vertex.x + 1, .y = next_vertex.y };
                    if (last_vertex == null or !std.meta.eql(right_vertex, last_vertex.?)) {
                        try neighbors_list.append(right_vertex);
                    }
                }
            }

            const neighbors = try neighbors_list.toOwnedSlice();
            defer self.allocator.free(neighbors);
            for (neighbors) |neighbor| {
                var in_Q = false;
                for (queue_list.items) |v| {
                    if (std.meta.eql(neighbor, v)) {
                        in_Q = true;
                        break;
                    }
                }

                if (!in_Q) {
                    continue;
                }

                const alt: u32 = dist[next_vertex.y][next_vertex.x] + self.points[neighbor.y][neighbor.x];
                if (alt < dist[neighbor.y][neighbor.x]) {
                    std.debug.print("Dist to {any} = {d}\n", .{ neighbor, alt });
                    dist[neighbor.y][neighbor.x] = alt;
                    last[neighbor.y][neighbor.x] = next_vertex;
                }
            }
        }

        return dist[self.points.len - 1][self.points[0].len - 1];
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stdin = std.io.getStdIn();

    var graph = try Graph.parseGraph(stdin.reader(), allocator);
    defer graph.deinit();

    const dist = try graph.dijkstra();

    try std.io.getStdOut().writer().print("Distance: {d}\n", .{dist});
}
