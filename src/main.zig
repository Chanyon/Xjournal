const std = @import("std");
const allocator = std.heap.page_allocator;
const log = std.log;
const file = @import("file.zig");
const build = @import("build.zig").build;
const server = @import("server.zig").createServe;

const clap = @import("clap");

const SubCommand = enum {
    serve, // xj serve --port=8000| -p=8000
    build,
};
const parsers = .{
    .STR = clap.parsers.string,
    .INT = clap.parsers.int(u16, 0),
    .command = clap.parsers.enumeration(SubCommand),
};

// const MainArgs = clap.ResultEx(clap.Help, &params, parsers);
const version = "0.4.0";

pub fn main() !void {
    // try runCmd();
    //xj new dirname
    //xj serve port=8000 | -p=8000
    //xj build
    //xj version | -v
    const params = comptime clap.parseParamsComptime(
        \\-h, --help  display this help and exit.
        \\-v, --version display xj version.
        \\-c, --create <STR> create a new dir.
        \\<command>   eg: 1)use xj serve -p=5000, get a serve port and run.
        \\                2)use xj build, build markdown file to html.
    );
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    var iter = try std.process.ArgIterator.initWithAllocator(gpa.allocator());
    defer iter.deinit();

    _ = iter.next();

    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &params, parsers, &iter, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
        .assignment_separators = "=: ",
        .terminating_positional = 0,
    }) catch return try clap.helpToFile(.stderr(), clap.Help, &params, .{});

    defer res.deinit();
    if (res.args.help != 0) {
        return try clap.helpToFile(.stderr(), clap.Help, &params, .{});
    }

    if (res.args.version != 0) {
        std.log.info("xj version {s}", .{version});
        return;
    }

    if (res.args.create) |dirname| {
        // try file.createNewDir(dirname);
        log.info("create a new dir `{s}`", .{dirname});
        return;
    }

    const command = res.positionals[0] orelse return try clap.helpToFile(.stderr(), clap.Help, &params, .{});
    switch (command) {
        .serve => try getPortAndRun(gpa.allocator(), &iter),
        .build => {
            log.info("static blog build", .{});
            try build();
        },
    }
}

fn getPortAndRun(
    gpa: std.mem.Allocator,
    iter: *std.process.ArgIterator,
    // main_args: MainArgs,
) !void {
    const sub_params = comptime clap.parseParamsComptime(
        \\-p, --port <INT> get serve port.
        \\
    );
    var diag = clap.Diagnostic{};
    var res = clap.parseEx(
        clap.Help,
        &sub_params,
        parsers,
        iter,
        .{
            .diagnostic = &diag,
            .allocator = gpa,
        },
    ) catch return try clap.helpToFile(.stderr(), clap.Help, &sub_params, .{});

    defer res.deinit();
    if (res.args.port) |p| {
        log.info("open http://localhost:{}", .{p});
        try server(gpa, "dist/index.html", p);
    } else {
        return try clap.helpToFile(.stderr(), clap.Help, &sub_params, .{});
    }
}

const yazap = @import("yazap");
const App = yazap.App;
const Arg = yazap.Arg;
fn runCmd() !void {
    var app = App.init(allocator, "xj", "Static blog generation tool");
    defer app.deinit();
    var xj = app.rootCommand();

    var new_cmd = app.createCommand("new", "create a new directories");
    try new_cmd.addArg(Arg.positional("DirName", "dir name", null));
    new_cmd.setProperty(.positional_arg_required);

    var serve_cmd = app.createCommand("serve", "create a new server");
    try serve_cmd.addArg(Arg.singleValueOption("port", 'p', "Don't ignore the command"));

    const build_cmd = app.createCommand("build", "Static blog build");
    try xj.addSubcommand(new_cmd);
    try xj.addSubcommand(serve_cmd);
    try xj.addSubcommand(build_cmd);

    try xj.addArg(Arg.booleanOption("version", 'v', "Static blog generation tool version"));

    const xj_args = app.parseProcess(std.Io.AnyReader, std.process.ArgIterator) catch {
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
        log.info("Xjournal v0.4.0", .{});
        return;
    }
}
