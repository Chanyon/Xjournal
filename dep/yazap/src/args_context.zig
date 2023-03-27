//! A structure for querying the parser result
//! which includes the getting command's raw value, flag's value, subcommand's args result and so on.

const std = @import("std");
const Arg = @import("Arg.zig");
const Help = @import("help.zig").Help;
const ArgHashMap = std.StringHashMap(MatchedArgValue);

pub const MatchedArgValue = union(enum) {
    none,
    single: []const u8,
    many: std.ArrayList([]const u8),

    pub fn count(val: MatchedArgValue) usize {
        if (val.isSingle()) {
            return 1;
        } else if (val.isMany()) {
            return val.many.items.len;
        } else {
            return 0;
        }
    }

    pub fn isNone(self: MatchedArgValue) bool {
        return (!self.isSingle() and !self.isMany());
    }

    pub fn isSingle(self: MatchedArgValue) bool {
        return (self == .single);
    }

    pub fn isMany(self: MatchedArgValue) bool {
        return (self == .many);
    }
};

pub const MatchedSubCommand = struct {
    name: []const u8,
    ctx: ?ArgsContext,

    pub fn init(name: []const u8, args_ctx: ?ArgsContext) MatchedSubCommand {
        return MatchedSubCommand{ .name = name, .ctx = args_ctx };
    }

    pub fn deinit(self: *MatchedSubCommand) void {
        if (self.ctx) |*ctx| ctx.deinit();
    }
};

pub const ArgsContext = struct {
    allocator: std.mem.Allocator,
    args: ArgHashMap,
    subcommand: ?*MatchedSubCommand,

    pub fn init(allocator: std.mem.Allocator) ArgsContext {
        return ArgsContext{
            .allocator = allocator,
            .args = ArgHashMap.init(allocator),
            .subcommand = null,
        };
    }

    pub fn deinit(self: *ArgsContext) void {
        var args_value_iter = self.args.valueIterator();

        while (args_value_iter.next()) |value| {
            if (value.isMany()) value.many.deinit();
        }
        self.args.deinit();

        if (self.subcommand) |subcommand| {
            subcommand.deinit();
            self.allocator.destroy(subcommand);
        }
    }

    pub fn setSubcommand(self: *ArgsContext, subcommand: MatchedSubCommand) !void {
        if (self.subcommand != null) return;

        var alloc_subcmd = try self.allocator.create(MatchedSubCommand);
        alloc_subcmd.* = subcommand;
        self.subcommand = alloc_subcmd;
    }

    /// Checks if argument or subcommand is present
    pub fn isPresent(self: *const ArgsContext, name_to_lookup: []const u8) bool {
        if (self.args.contains(name_to_lookup)) {
            return true;
        } else if (self.subcommand) |subcmd| {
            if (std.mem.eql(u8, subcmd.name, name_to_lookup))
                return true;
        }

        return false;
    }

    /// Checks if arguments were present on command line or not
    pub fn hasArgs(self: *const ArgsContext) bool {
        return ((self.args.count() >= 1) or (self.subcommand != null));
    }

    /// Returns the single value of an argument if found otherwise null
    pub fn valueOf(self: *const ArgsContext, arg_name: []const u8) ?[]const u8 {
        if (self.args.get(arg_name)) |value| {
            if (value.isSingle()) return value.single;
        } else if (self.subcommand) |subcmd| {
            if (subcmd.ctx) |ctx| {
                return ctx.valueOf(arg_name);
            }
        }

        return null;
    }

    /// Returns the array of values of an argument if found otherwise null
    pub fn valuesOf(self: *const ArgsContext, name_to_lookup: []const u8) ?[][]const u8 {
        if (self.args.get(name_to_lookup)) |value| {
            if (value.isMany()) return value.many.items[0..];
        }
        return null;
    }

    /// Returns the subcommand `ArgsContext` if subcommand is present otherwise null
    pub fn subcommandContext(self: *const ArgsContext, subcmd_name: []const u8) ?ArgsContext {
        if (self.subcommand) |subcmd| {
            if (std.mem.eql(u8, subcmd.name, subcmd_name)) {
                return subcmd.ctx;
            }
        }
        return null;
    }
};

test "emit methods docs" {
    std.testing.refAllDecls(@This());
}
