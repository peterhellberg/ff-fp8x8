const ff = @import("ff");

const Architecture = @import("8x8/Architecture.zig").Architecture;
const Checked = @import("8x8/Checked.zig").Checked;
const Dashes = @import("8x8/Dashes.zig").Dashes;
const Dither = @import("8x8/Dither.zig").Dither;
const Dots = @import("8x8/Dots.zig").Dots;
const Grid = @import("8x8/Grid.zig").Grid;
const Lines = @import("8x8/Lines.zig").Lines;
const Nature = @import("8x8/Nature.zig").Nature;
const Other = @import("8x8/Other.zig").Other;
const Radial = @import("8x8/Radial.zig").Radial;
const Rectilinear = @import("8x8/Rectilinear.zig").Rectilinear;
const Round = @import("8x8/Round.zig").Round;
const Symbols = @import("8x8/Symbols.zig").Symbols;
const Waves = @import("8x8/Waves.zig").Waves;
const Woven = @import("8x8/Woven.zig").Woven;

const draw = ff.draw;

var buf: [1735]u8 = undefined;
var fff: ff.Font = undefined;
var btn: ff.Buttons = undefined;
var pre: ff.Buttons = undefined;
var pad: ff.Pad = undefined;
var old: ff.Pad = undefined;
var pal: ff.Palette = .{
    .black = 0x000000,
    .gray = 0x292929,
    .white = 0xffffff,
    .orange = 0xf7a41d,
};

pub export fn boot() void {
    app.boot();
}

pub export fn update() void {
    app.update();
}

pub export fn render() void {
    app.render();
}

const App = struct {
    palette: PaletteW4 = .MacPaint,
    gallery: Gallery = .Nature,
    number: i32 = 16,
    color: ff.Color = .white,

    fn boot(self: *App) void {
        fff = ff.loadFile("font", buf[0..]);

        pal.set();
        self.setPalette();
    }

    fn update(self: *App) void {
        const me = ff.getMe();

        btn = ff.readButtons(me);
        pad = ff.readPad(me).?;

        if (pad.y < -50 and old.y > -50) self.prevGallery();
        if (pad.y > 50 and old.y < 50) self.nextGallery();
        if (pad.x < -50 and old.x > -50) self.prevPattern();
        if (pad.x > 50 and old.x < 50) self.nextPattern();
        if (btn.n and !pre.n) self.nextPalette();
        if (btn.s and !pre.s) {
            self.color = if (self.color == .white) .black else .white;
        }

        pre = btn;
        old = pad;
    }

    fn render(self: *App) void {
        const s = self.gallery.sprite(self.number);

        ff.clearScreen(if (self.color == .white) .black else .white);

        for (0..600) |i| {
            const n: i32 = @intCast(i);
            const x: i32 = @mod(n, 30) * 8;
            const y: i32 = @divTrunc(n, 30) * 8;

            self.blit(x, y, s);
        }

        if (!btn.e) {
            zoom(self.gallery, self.color, s);
        }
    }

    fn nextPalette(self: *App) void {
        self.palette = self.palette.next();
        self.setPalette();
    }

    fn setPalette(self: *App) void {
        const p = self.palette.colors();

        ff.setColorHex(.black, p[0]);
        ff.setColorHex(.white, p[1]);
    }

    fn prevGallery(self: *App) void {
        self.gallery = self.gallery.prev();
    }

    fn nextGallery(self: *App) void {
        self.gallery = self.gallery.next();
    }

    fn prevPattern(self: *App) void {
        self.number -|= 1;
    }

    fn nextPattern(self: *App) void {
        self.number += 1;
    }

    fn blit(self: *App, x: i32, y: i32, sprite: [8]u8) void {
        var bytes = sprite;

        if (self.color == .white) {
            for (&bytes) |*byte| {
                byte.* = ~byte.*;
            }
        }

        img[0x6..0xE].* = bytes;

        ff.drawImage(&img, ff.Point.new(x, y));
    }

    fn zoom(g: Gallery, c: ff.Color, sprite: [8]u8) void {
        const s = ff.Style{ .fill_color = c, .stroke_color = if (c == .white) .black else .white, .stroke_width = 1 };

        for (0.., sprite) |r, u| {
            const y: i32 = @intCast(r * 20);

            if (u & 0b00000001 != 0) ff.draw.rect(40 + 7 * 20, y, 19, 19, s);
            if (u & 0b00000010 != 0) ff.draw.rect(40 + 6 * 20, y, 19, 19, s);
            if (u & 0b00000100 != 0) ff.draw.rect(40 + 5 * 20, y, 19, 19, s);
            if (u & 0b00001000 != 0) ff.draw.rect(40 + 4 * 20, y, 19, 19, s);
            if (u & 0b00010000 != 0) ff.draw.rect(40 + 3 * 20, y, 19, 19, s);
            if (u & 0b00100000 != 0) ff.draw.rect(40 + 2 * 20, y, 19, 19, s);
            if (u & 0b01000000 != 0) ff.draw.rect(40 + 1 * 20, y, 19, 19, s);
            if (u & 0b10000000 != 0) ff.draw.rect(40 + 0 * 20, y, 19, 19, s);
        }

        const tn = @tagName(g);
        const pt = ff.Point.new(10, 10);

        ff.draw.rect(8, 3, @intCast(3 + tn.len * 6), 12, .{ .fill_color = .black });
        ff.draw.Text(tn, fff, pt, .white);
    }

    var img = [14]u8{
        // Heaader
        0x21,
        1, // BPP
        8, 0, // stride (lower/upper)
        0x10, // transparent

        // Palette swaps
        0b00001100,

        // Raw image bytes
        0b00000000,
        0b00000000,
        0b00000000,
        0b00000000,
        0b00000000,
        0b00000000,
        0b00000000,
        0b00000000,
    };
};
var app = App{};

const Gallery = enum {
    Architecture,
    Checked,
    Dashes,
    Dither,
    Dots,
    Grid,
    Lines,
    Nature,
    Other,
    Radial,
    Rectilinear,
    Round,
    Symbols,
    Waves,
    Woven,

    fn wrapIndex(value: i32, count: i32) i32 {
        var r = @mod(value, count);
        if (r < 0) r += count;

        return r;
    }

    fn sprite(self: Gallery, number: i32) [8]u8 {
        const idx = switch (self) {
            .Dither => wrapIndex(number, Dither.Count),
            .Dots => wrapIndex(number, Dots.Count),
            .Dashes => wrapIndex(number, Dashes.Count),
            .Lines => wrapIndex(number, Lines.Count),
            .Waves => wrapIndex(number, Waves.Count),
            .Grid => wrapIndex(number, Grid.Count),
            .Checked => wrapIndex(number, Checked.Count),
            .Rectilinear => wrapIndex(number, Rectilinear.Count),
            .Radial => wrapIndex(number, Radial.Count),
            .Round => wrapIndex(number, Round.Count),
            .Woven => wrapIndex(number, Woven.Count),
            .Architecture => wrapIndex(number, Architecture.Count),
            .Nature => wrapIndex(number, Nature.Count),
            .Symbols => wrapIndex(number, Symbols.Count),
            .Other => wrapIndex(number, Other.Count),
        };

        return switch (self) {
            .Dither => Dither.sprite(@enumFromInt(idx)),
            .Dots => Dots.sprite(@enumFromInt(idx)),
            .Dashes => Dashes.sprite(@enumFromInt(idx)),
            .Lines => Lines.sprite(@enumFromInt(idx)),
            .Waves => Waves.sprite(@enumFromInt(idx)),
            .Grid => Grid.sprite(@enumFromInt(idx)),
            .Checked => Checked.sprite(@enumFromInt(idx)),
            .Rectilinear => Rectilinear.sprite(@enumFromInt(idx)),
            .Radial => Radial.sprite(@enumFromInt(idx)),
            .Round => Round.sprite(@enumFromInt(idx)),
            .Woven => Woven.sprite(@enumFromInt(idx)),
            .Architecture => Architecture.sprite(@enumFromInt(idx)),
            .Nature => Nature.sprite(@enumFromInt(idx)),
            .Symbols => Symbols.sprite(@enumFromInt(idx)),
            .Other => Other.sprite(@enumFromInt(idx)),
        };
    }

    fn prev(self: Gallery) Gallery {
        return switch (self) {
            .Dither => .Other,
            .Dots => .Dither,
            .Dashes => .Dots,
            .Lines => .Dashes,
            .Waves => .Lines,
            .Grid => .Waves,
            .Checked => .Grid,
            .Rectilinear => .Checked,
            .Radial => .Rectilinear,
            .Round => .Radial,
            .Woven => .Round,
            .Architecture => .Woven,
            .Nature => .Architecture,
            .Symbols => .Nature,
            .Other => .Symbols,
        };
    }

    fn next(self: Gallery) Gallery {
        return switch (self) {
            .Dither => .Dots,
            .Dots => .Dashes,
            .Dashes => .Lines,
            .Lines => .Waves,
            .Waves => .Grid,
            .Grid => .Checked,
            .Checked => .Rectilinear,
            .Rectilinear => .Radial,
            .Radial => .Round,
            .Round => .Woven,
            .Woven => .Architecture,
            .Architecture => .Nature,
            .Nature => .Symbols,
            .Symbols => .Other,
            .Other => .Dither,
        };
    }
};

const PaletteW4 = enum {
    OneBitMonitorGlow, // https://lospec.com/palette-list/1bit-monitor-glow
    ObraDinnIBM8503, // https://lospec.com/palette-list/obra-dinn-ibm-8503
    MacPaint, // https://lospec.com/palette-list/mac-paint
    Note2C, // https://lospec.com/palette-list/note-2c
    IBM51, // https://lospec.com/palette-list/ibm-51

    fn colors(self: PaletteW4) [4]u32 {
        return switch (self) {
            .OneBitMonitorGlow => .{ 0xf0f6f0, 0x222323, 0, 0 },
            .ObraDinnIBM8503 => .{ 0xebe5ce, 0x2e3037, 0, 0 },
            .MacPaint => .{ 0x8bc8fe, 0x051b2c, 0, 0 },
            .Note2C => .{ 0xedf2e2, 0x222a3d, 0, 0 },
            .IBM51 => .{ 0xd3c9a1, 0x323c39, 0, 0 },
        };
    }

    fn next(self: PaletteW4) PaletteW4 {
        return switch (self) {
            .OneBitMonitorGlow => .ObraDinnIBM8503,
            .ObraDinnIBM8503 => .MacPaint,
            .MacPaint => .Note2C,
            .Note2C => .IBM51,
            .IBM51 => .OneBitMonitorGlow,
        };
    }
};
