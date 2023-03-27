const std = @import("std");

pub fn MakeSettings(comptime AnonOption: type) type {
    if (@typeInfo(AnonOption) != .Enum)
        @compileError(
            @src().fn_name ++ " expected `AnonOption` to be enum, found " ++ @typeName(AnonOption),
        );

    return struct {
        const Self = @This();
        pub const Option = AnonOption;

        options: std.EnumSet(Option) = .{},

        pub fn set(self: *Self, option: Option) void {
            return self.options.insert(option);
        }

        pub fn unset(self: *Self, option: Option) void {
            return self.options.remove(option);
        }

        pub fn isSet(self: *const Self, option: Option) bool {
            return self.options.contains(option);
        }
    };
}

test "settings generator" {
    const CmdSettings = MakeSettings(enum {
        /// will doc comment visible?
        takes_value,
        subcommand_required,
    });
    var settings = CmdSettings{};

    try std.testing.expectEqual(false, settings.isSet(.takes_value));
    settings.set(.takes_value);
    try std.testing.expectEqual(true, settings.isSet(.takes_value));
}
