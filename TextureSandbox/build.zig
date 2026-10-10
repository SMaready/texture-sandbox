const std = @import("std");

// TextureSandbox build script.
//
//   zig build            -> builds into zig-out/bin/
//   zig build run        -> builds and runs
//   zig build -Doptimize=ReleaseFast

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    if (target.result.os.tag != .windows) {
        std.debug.print("TextureSandbox uses Direct3D 11 and only builds for Windows targets.\n", .{});
    }

    // ---------------------------------------------------------------- GLFW (static lib)
    const glfw_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    glfw_mod.addIncludePath(b.path("libs/glfw/include"));
    glfw_mod.addCSourceFiles(.{
        .root = b.path("libs/glfw/src"),
        .files = &glfw_common_sources ++ glfw_win32_sources,
        .flags = &.{"-D_GLFW_WIN32"},
    });
    glfw_mod.linkSystemLibrary("gdi32", .{});
    glfw_mod.linkSystemLibrary("user32", .{});
    glfw_mod.linkSystemLibrary("shell32", .{});

    const glfw = b.addLibrary(.{
        .name = "glfw",
        .linkage = .static,
        .root_module = glfw_mod,
    });

    // ---------------------------------------------------------------- TextureSandbox.exe
    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    exe_mod.addIncludePath(b.path("libs/glfw/include"));
    exe_mod.addIncludePath(b.path("src"));
    exe_mod.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "main.cpp",
        },
        .flags = &.{
            "-std=c++23",
            "-Wall",
            "-Wextra",
        },
    });
    exe_mod.linkLibrary(glfw);
    exe_mod.linkSystemLibrary("d3d11", .{});
    exe_mod.linkSystemLibrary("dxgi", .{});
    exe_mod.linkSystemLibrary("d3dcompiler_47", .{});
    exe_mod.addWin32ResourceFile(.{ .file = b.path("resource/resource.rc") });

    const exe = b.addExecutable(.{
        .name = "TextureSandbox",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    // Shaders are compiled at runtime from zig-out/bin/shaders/, so copy them next to the exe.
    // Edit src/shaders/*.hlsl, re-run `zig build`, and the new version gets picked up.
    b.installDirectory(.{
        .source_dir = b.path("src/shaders"),
        .install_dir = .bin,
        .install_subdir = "shaders",
    });

    // ---------------------------------------------------------------- zig build run
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Build and run TextureSandbox");
    run_step.dependOn(&run_cmd.step);
}

const glfw_common_sources = [_][]const u8{
    "context.c",
    "init.c",
    "input.c",
    "monitor.c",
    "platform.c",
    "vulkan.c",
    "window.c",
    "egl_context.c",
    "osmesa_context.c",
    "null_init.c",
    "null_monitor.c",
    "null_window.c",
    "null_joystick.c",
};

const glfw_win32_sources = [_][]const u8{
    "win32_init.c",
    "win32_joystick.c",
    "win32_module.c",
    "win32_monitor.c",
    "win32_thread.c",
    "win32_time.c",
    "win32_window.c",
    "wgl_context.c",
};