const std = @import("std");
const yazap = @import("yazap");
const App = yazap.App;
const flag = yazap.flag;
/// command line args
pub const Arg = struct {
    app: App,
    const Self = @This();
    // init arg
    pub fn new(gpa: std.mem.Allocator) !Arg {
        var app = App.init(gpa, "myls", null);
        var myls = app.rootCommand();
        // try myls.addArg(flag.boolean("all", 'a', "Don't ignore the hidden directories"));
        _ = myls;
        return Arg{ .app = app };
    }
    pub fn deinit(self: *Self) void {
        self.app.deinit();
    }
};
