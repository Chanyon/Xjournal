// server
const std = @import("std");
const httpz = @import("httpz");

const App = struct {
    pub fn notFound(_: *App, req: *httpz.Request, res: *httpz.Response) !void {
        std.log.info("404 {} {s}", .{ req.method, req.url.path });
        res.header("Content-Type", "text/html");
        const path = req.url.path;
        var buf: std.ArrayList(u8) = .empty;
        defer buf.deinit(req.arena);
        const result = try httpz.Url.unescape(req.arena, buf.items, path);
        // std.log.debug("{s}", .{result.value});

        const sub_path = try std.fmt.allocPrint(req.arena, "dist{s}", .{result.value});
        defer req.arena.free(sub_path);

        var file = std.fs.cwd().openFile(sub_path, .{}) catch {
            res.body = "Not Found";
            return;
        };
        defer file.close();

        res.body = try file.readToEndAlloc(req.arena, 1000000);
    }
};

pub fn createServe(al: std.mem.Allocator, dir_path: []const u8, port: u16) !void {
    _ = dir_path;
    var app = App{};
    var server = try httpz.Server(*App).init(al, .{
        .address = .localhost(port),
    }, &app);

    defer {
        server.stop();
        server.deinit();
    }

    // server.notFound(staticFile);
    var router = try server.router(.{});
    router.get("/", index, .{});

    try server.listen();
}

fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    var index_file = try std.fs.cwd().openFile("dist/index.html", .{});
    defer index_file.close();
    res.body = try index_file.readToEndAlloc(req.arena, 100000);
}
