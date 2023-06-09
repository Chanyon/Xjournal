const std = @import("std");
const toml = @import("zig-toml");
const String = @import("zig-string").String;
const configs = @import("./config.zig");
const idxHtml = @import("./front/index.zig");
const idxJs = @import("./front/index-js.zig");
const getFilename = @import("./file.zig").getFilename;
const createFile = @import("./file.zig").createHtmlAndJsFile;
const genHtml = @import("./file.zig").md2Html;
const template2Html = @import("./file.zig").genTemplateHtml;
const splitTwoStep = @import("./file.zig").spiltTwoStep;
const splitFirst = @import("./file.zig").splitFisrt;

pub fn build() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var myString = String.init(allocator);
    defer myString.deinit();
    try myString.concat(idxHtml.html_start);

    var jsString = String.init(allocator);
    defer jsString.deinit();
    try jsString.concat(idxJs.script_start);

    var parser = toml.Parser(configs.MasterConfig).init(allocator);
    defer parser.deinit();
    var master_config: configs.MasterConfig = undefined;
    //TODO: free allocator of master_config
    try parser.parseFile("./content/xj.toml", &master_config);

    const title: []const u8 = try std.fmt.allocPrint(allocator, "\n<title>{s}</title>\n", .{master_config.blog_name});
    try myString.concat(title);
    try myString.concat(idxHtml.head_end);
    try myString.concat(idxHtml.header_start);

    const blog_name: []const u8 = try std.fmt.allocPrint(allocator, "<div class=\"basis-1/4 pl-4\"> {s} </div><div class=\"basis-4/5\"><ul class=\"flex flex-row\">", .{master_config.blog_name});
    try myString.concat(blog_name);

    for (master_config.menus) |menu| {
        //* link herf
        const nav_link: []const u8 = try std.fmt.allocPrint(allocator, "<li class=\"mx-4\"><a data-href=\"{s}\">{s}</a></li>", .{ menu.url, menu.name });
        try myString.concat(nav_link);
    }
    try myString.concat(idxHtml.header_end);

    var home = std.fs.cwd();
    defer home.close();

    var parser2 = toml.Parser(configs.ArticleConfig).init(allocator);
    defer parser2.deinit();

    var article_config: configs.ArticleConfig = undefined;

    try myString.concat(idxHtml.main_start);
    for (master_config.issues) |item| {
        // !delete ?
        const toml_file = try getFilename(allocator, home, item.path);
        if (toml_file) |file| {
            const path: []const u8 = try std.fmt.allocPrint(allocator, "./{s}/{s}", .{ item.path, file });
            try parser2.parseFile(path, &article_config);
            // section tag
            const section_start = "<section class=\"h-auto border-b-2 border-black border-double\">";
            try myString.concat(section_start);

            const h3: []const u8 = try std.fmt.allocPrint(allocator, "<h5 class=\"h-16 p-2 text-center text-2xl\">{s}</h5> <ul class=\"divide-y divide-black divide-dashed\">", .{item.title});

            try myString.concat(h3);
            //* article link
            const dir_path = splitTwoStep(item.path, "/");
            for (article_config.articles) |link| {
                const file_name = splitFirst(link.file, ".");
                const li_link: []const u8 = try std.fmt.allocPrint(allocator, "<li class=\"h-16 p-2\"><a data-href=\"/{s}/{s}\">{s}</a><p class=\"pub-date\">{s}</p></li>", .{ dir_path, file_name, link.title, link.pub_date });
                try myString.concat(li_link);

                const obj_key_val = try std.fmt.allocPrint(allocator, "\n\"/{s}/{s}\":\"./{s}/{s}.html\",\n", .{ dir_path, file_name, dir_path, file_name });
                try jsString.concat(obj_key_val);

                std.debug.print("{s} {s} => html\n", .{ item.path, link.file });
                // 遍历生成html file
                try genHtml(home, &master_config, item.path, link.file, link.title);
            }

            const section_end = "</ul></section>";
            try myString.concat(section_end);
        } else {
            std.log.info("toml file content is null or doesn't exist", .{});
        }
    }

    try myString.concat(idxHtml.main_end);
    try myString.concat(idxHtml.footer_start);
    var footer = try template2Html(allocator, home, master_config.template.*.footer);
    defer footer.?.deinit();
    var str = try std.mem.join(allocator, "", footer.?.out.items);
    var res = str[0..str.len];
    const footer_end: []const u8 = try std.fmt.allocPrint(allocator, "{s}</footer> </div>", .{res});
    try myString.concat(footer_end);
    //script
    try jsString.concat("}\n");
    try jsString.concat(idxJs.script_end);
    try myString.concat(jsString.str());
    try myString.concat(idxHtml.html_end);

    // create index.html
    try createFile(home, master_config.output, myString.str(), "index.html");

    //about.pd => about.html
    var about = try template2Html(allocator, home, master_config.template.*.about);
    defer about.?.deinit();
    str = try std.mem.join(allocator, "", about.?.out.items);
    res = str[0..str.len];

    try createFile(home, master_config.output, res, "about.html");
}
