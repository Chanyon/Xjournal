const std = @import("std");
const prog = @import("progdoc");
const yazap = @import("yazap");
const allocator = std.heap.page_allocator;
const log = std.log;
const flag = yazap.flag;
const App = yazap.App;
const file = @import("file.zig");

pub fn main() !void {
    try runCmd();
}

fn runCmd() !void {
    var app = App.init(allocator, "xj", "Static blog generation tool");
    defer app.deinit();
    var xj = app.rootCommand();

    var new_cmd = app.createCommand("new", "create a new directories");
    try new_cmd.takesSingleValue("DirName");
    new_cmd.setSetting(.positional_arg_required);

    var serve_cmd = app.createCommand("serve", "create a new server");
    try serve_cmd.addArg(flag.argOne("port", 'p', "Don't ignore the command"));

    var build_cmd = app.createCommand("build", "Static blog build");
    try xj.addSubcommand(new_cmd);
    try xj.addSubcommand(serve_cmd);
    try xj.addSubcommand(build_cmd);

    try xj.addArg(flag.boolean("version", 'v', "Static blog generation tool version"));

    const xj_args = try app.parseProcess();

    if (!(xj_args.hasArgs())) {
        try app.displayHelp();
        return;
    }

    if (xj_args.subcommandContext("new")) |new_args| {
        if (!(new_args.hasArgs())) {
            try app.displaySubcommandHelp();
            return;
        }
        //1. create new dir
        //2. create file or dir in new dir
        const val = new_args.valueOf("DirName").?;
        try file.createNewDir(val);
        return;
    }

    if (xj_args.subcommandContext("serve")) |serve_args| {
        if (!(serve_args.hasArgs())) {
            try app.displaySubcommandHelp();
            return;
        }
        if (serve_args.valueOf("port")) |port| {
            log.info("port {s}", .{port});
        }
        return;
    }

    if (xj_args.isPresent("build")) {
        log.info("static blog build", .{});
        // std.fs.cwd(), 进入软件执行位置
        //读取content目录下的xj.toml文件反序例化 -> zig struct
        //拿到数组issue中path的值，遍历，读取子目录中的toml文件反序例化 -> zig struct
        //遍历article数组，拿到file path，读取对应文件，渲染到html
        //todo 思考如何拼接html相关内容,以及对应创建文件？
        //创建build目录，往里写入html、css、js文件
        return;
    }

    if (xj_args.isPresent("version")) {
        log.info("v0.1.0", .{});
        return;
    }
}

fn genHtml() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var al = arena.allocator();
    //打开输入文件目录，并一次性读入到内存
    var home = std.fs.cwd();
    defer home.close();
    //解析生成html
    const str =
        \\ progdoc格式说明
        \\简介
        \\progdoc格式主要用于编写软件开发和程序设计方面的设计、使用说明、API等文档。
        \\progdoc把符合progdoc格式的文本文件转换为单一html文件。
        \\progdoc格式文件的文件名后缀通常是 `.pd` ，文件编码必须是UTF-8。
        \\progdoc格式设计原则为：
        \\#- 格式尽可能简约，以降低学习使用难度
        \\#- 使用 # #` 这两个程序设计中很少使用的字符作为格式前导字符
        \\#- 有内嵌html功能，以用于文档中插入latex数学公式等需求
    ;
    var s = try prog.@"Tprogdoc格式转换状态机".createStatusMachine(al, str);
    try s.parseProgdoc();
    //  创建输出文件，并一次性写入解析结果
    var outfile = try home.createFile("pc.html", .{});
    defer outfile.close();
    try outfile.writeAll(s.out.items);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
