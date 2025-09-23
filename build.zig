const std = @import("std");
const Build = std.Build;

pub const SdkOpts = struct {
    build_examples: bool = false,
};

const Example = struct {
    description: ?[]const u8,
    output: []const u8,
    input: []const u8,

    pub fn init(output: []const u8, input: []const u8, desc: ?[]const u8) Example {
        return Example{
            .description = desc,
            .output = output,
            .input = input,
        };
    }
};

pub const examples = &[_]Example{
    Example.init("simple", "examples/simple.zig", "A simple hello world app"),
    //Example.init("capi", "examples/capi.zig", "Using the C-api directly"),
    Example.init("customwidget", "examples/customwidget.zig", "Custom widget example"),
    Example.init("image", "examples/image.zig", "Simple image example"),
    Example.init("input", "examples/input.zig", "Simple input example"),
    Example.init("mixed", "examples/mixed.zig", "Mixing both c and zig apis"),
    Example.init("editor", "examples/editor.zig", "More complex example"),
    Example.init("layout", "examples/layout.zig", "Layout example"),
    Example.init("valuators", "examples/valuators.zig", "valuators example"),
    Example.init("channels", "examples/channels.zig", "Use messages to handle events"),
    Example.init("editormsgs", "examples/editormsgs.zig", "Use messages in the editor example"),
    Example.init("browser", "examples/browser.zig", "Browser example"),
    Example.init("flex", "examples/flex.zig", "Flex example"),
    Example.init("threadawake", "examples/threadawake.zig", "Thread awake example"),
    Example.init("handle", "examples/handle.zig", "Handle example"),
    Example.init("flutterlike", "examples/flutterlike.zig", "Flutter-like example"),
    // Example.init("glwin", "examples/glwin.zig", "OpenGL window example"),
    Example.init("tile", "examples/tile.zig", "Tile group example"),
};

var opts: SdkOpts = undefined;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    opts = SdkOpts{
        .build_examples = b.option(bool, "zfltk-build-examples", "Build zfltk examples") orelse false,
    };

    const zfltk = b.addModule("zfltk", .{
        .root_source_file = b.path("src/zfltk.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    const cfltk_pkg = b.dependency("cfltk", .{
        .target = target,
        .optimize = optimize,
    });
    const cfltk_lib = cfltk_pkg.artifact("cfltk");

    zfltk.linkLibrary(cfltk_lib);

    if (opts.build_examples) {
        const examples_step = b.step("examples", "build the zfltk examples");
        for (examples) |ex| {
            const exe = b.addExecutable(.{
                .name = ex.output,
                .root_module = b.createModule(.{
                    .root_source_file = b.path(ex.input),
                    .target = target,
                    .optimize = optimize,
                    .link_libc = true,
                    .link_libcpp = true,
                }),
            });

            exe.root_module.addImport("zfltk", zfltk);
            examples_step.dependOn(&exe.step);
            b.installArtifact(exe);
        }
    }
}
