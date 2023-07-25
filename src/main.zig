const std = @import("std");
const yazap = @import("yazap");
const allocator = std.heap.page_allocator;
const log = std.log;
const App = yazap.App;
const Arg = yazap.Arg;
const file = @import("file.zig");
const build = @import("build.zig").build;
const server = @import("server.zig").createServe;

pub fn main() !void {
    try runCmd();
}

fn runCmd() !void {
    var app = App.init(allocator, "xj", "Static blog generation tool");
    defer app.deinit();
    var xj = app.rootCommand();

    var new_cmd = app.createCommand("new", "create a new directories");
    try new_cmd.addArg(Arg.positional("DirName", "dir name", null));
    new_cmd.setProperty(.positional_arg_required);

    var serve_cmd = app.createCommand("serve", "create a new server");
    try serve_cmd.addArg(Arg.singleValueOption("port", 'p', "Don't ignore the command"));

    var build_cmd = app.createCommand("build", "Static blog build");
    try xj.addSubcommand(new_cmd);
    try xj.addSubcommand(serve_cmd);
    try xj.addSubcommand(build_cmd);

    try xj.addArg(Arg.booleanOption("version", 'v', "Static blog generation tool version"));

    const xj_args = app.parseProcess() catch {
        try app.displayHelp();
        return;
    };

    if (!(xj_args.containsArgs())) {
        try app.displayHelp();
        return;
    }

    if (xj_args.subcommandMatches("new")) |new_args| {
        //1. create new dir
        const val = new_args.getSingleValue("DirName").?;
        try file.createNewDir(val);
        return;
    }

    if (xj_args.subcommandMatches("serve")) |serve_args| {
        const port = serve_args.getSingleValue("port") orelse "3000";
        log.info("open http://localhost:{s}", .{port});
        try server(allocator, "dist/index.html", port);
        return;
    }

    if (xj_args.containsArg("build")) {
        log.info("static blog build", .{});
        // std.fs.cwd()
        //读取content目录下的xj.toml文件反序例化 -> zig struct
        //拿到数组issue中path的值，遍历，读取子目录中的toml文件反序例化 -> zig struct
        //遍历article数组，拿到file path，读取对应文件，渲染到html
        //创建build目录，往里写入html、css、js文件
        try build();
        return;
    }

    if (xj_args.containsArg("version")) {
        log.info("Xjournal v0.1.0", .{});
        return;
    }
}
