const interface = @import("interface.zig");
const std = @import("std");
const mem = std.mem;
const debug= std.debug;
const TypeInfo = std.builtin.TypeInfo;

pub fn List(comptime T: type) type {
    return struct {
        pub const Impl = struct {
            get: fn (l: *interface.This, idx: usize) T,
            len: fn (l: *interface.This) usize,
        };

        impl: *const Impl,
        data: *interface.This,

        pub fn new(impl: *const Impl, data: anytype) List(T) {
            comptime {
                debug.assert(@typeInfo(@TypeOf(data)).Pointer.size != TypeInfo.Pointer.Size.Slice);
            }
            return List(T){.impl=impl, .data=@ptrCast(*interface.This, data)};
        }

        pub fn get(l: List(T), idx: usize) T {
            return l.impl.get(l.data, idx);
        }

        pub fn len(l: List(T)) usize {
            return l.impl.len(l.data);
        }
    };
}

pub fn ArrayImpl(comptime T: type) *const List(T).Impl {
    return interface.impl(List(T), struct {
        pub fn get(l: *[]T, idx: usize) T {
            return l.*[idx];
        }

        pub fn len(l: *[]T) usize {
            return l.*.len;
        }
    });
}

test {
    var arr = [_]u32{1,2,3};
    var slice: []u32 = arr[0..];
    var list = interface.new(List(u32), ArrayImpl(u32), &slice);

    std.log.info("{}", .{list.len()});
    std.log.info("{}", .{list.get(0)});
}