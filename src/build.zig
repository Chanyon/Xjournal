const std = @import("std");
const toml = @import("zig_toml");
const String = @import("zig_string").String;
const configs = @import("./config.zig");
const idxHtml = @import("./front/index.zig");
const getFilename = @import("./file.zig").getFilename;

pub fn build() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var myString = String.init(allocator);
    defer myString.deinit();
    try myString.concat(idxHtml.html_start);

    var parser = toml.Parser(configs.MasterConfig).init(allocator);
    defer parser.deinit();
    var master_config: configs.MasterConfig = undefined;
    try parser.parseFile("./content/xj.toml", &master_config);

    const title: []const u8 = try std.fmt.allocPrint(allocator, "\n<title>{s}</title>\n", .{master_config.blog_name});
    try myString.concat(title);
    try myString.concat(idxHtml.head_end);
    try myString.concat(idxHtml.header_start);

    const blog_name: []const u8 = try std.fmt.allocPrint(allocator, "<div class=\"basis-1/4 pl-4\"> {s} </div><div class=\"basis-4/5\"><ul class=\"flex flex-row\">", .{master_config.blog_name});
    try myString.concat(blog_name);

    for (master_config.menus) |menu| {
        // TODO js impl link herf
        const nav_link: []const u8 = try std.fmt.allocPrint(allocator, "<li class=\"mx-4\"><a href=\"{s}\">{s}</a></li>", .{ menu.name, menu.url });
        try myString.concat(nav_link);
    }
    try myString.concat(idxHtml.header_end);

    const cwd = std.fs.cwd();
    var parser2 = toml.Parser(configs.ArticleConfig).init(allocator);
    defer parser2.deinit();

    var article_config: configs.ArticleConfig = undefined;

    try myString.concat(idxHtml.main_start);
    for (master_config.issues) |item| {
        // !delete ?
        const toml_file = try getFilename(allocator, cwd, item.path);
        if (toml_file) |file| {
            const path: []const u8 = try std.fmt.allocPrint(allocator, "./{s}/{s}", .{ item.path, file });
            std.log.info("{s}", .{path});
            try parser2.parseFile(path, &article_config);
            // section tag
            const section_start = "<section class=\"h-auto border-b-2 border-black border-double\">";
            try myString.concat(section_start);

            const h3: []const u8 = try std.fmt.allocPrint(allocator, 
            "<h3 class=\"h-16 p-2 text-center text-2xl\">{s}</h3> <ul class=\"divide-y divide-black divide-dashed\">", 
            .{item.title});

            try myString.concat(h3);
            // TODO js impl link herf
            for (article_config.articles) |link| {
                std.log.info("{s}", .{link.author});
                const li_link: []const u8 = try std.fmt.allocPrint(allocator, 
                "<li class=\"h-16 p-2\"><a href=\"#\">{s}</a></li>", .{link.title});
                try myString.concat(li_link);

                // TODO create file.html to build dir
                // _ = genHtml();
            }

            const section_end = "</ul></section>";
            try myString.concat(section_end);
        } else {
            std.log.info("toml file content is null or doesn't exist", .{});
        }
    }

    try myString.concat(idxHtml.main_end);
    try myString.concat(idxHtml.footer_start);
    const footer_end: []const u8 = try std.fmt.allocPrint(allocator, "{s}</footer>", .{master_config.github});
    try myString.concat(footer_end);
    try myString.concat(idxHtml.html_end);
    std.debug.print("{s} \n", .{myString.str()});
}
