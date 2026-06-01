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
    gallery: Gallery = .Nature,
    palette: Palette = .ObraDinnIBM8503,
    number: i32 = 16,

    color: ff.Color = .white,

    sprite: [8]u8 = @splat(0),
    imgv2: [4 + 19200]u8 = @splat(0),

    dirty: bool = true,

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
            self.dirty = true;
        }

        pre = btn;
        old = pad;

        if (self.dirty) self.clean();
    }

    fn clean(self: *App) void {
        self.sprite = self.gallery.sprite(self.number);

        if (self.color == .white) {
            for (self.sprite, 0..) |b, i| imgv1[6 + i] = ~b;
        } else {
            imgv1[6..14].* = self.sprite;
        }

        self.convert();
        self.dirty = false;
    }

    fn render(self: *App) void {
        ff.clearScreen(if (self.color == .white) .black else .white);
        ff.drawImage(&self.imgv2, .{});

        if (!btn.e) {
            zoom(self.gallery, self.color, self.sprite);
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

        self.dirty = true;
    }

    fn prevGallery(self: *App) void {
        self.gallery = self.gallery.prev();
        self.dirty = true;
    }

    fn nextGallery(self: *App) void {
        self.gallery = self.gallery.next();
        self.dirty = true;
    }

    fn prevPattern(self: *App) void {
        self.number -|= 1;
        self.dirty = true;
    }

    fn nextPattern(self: *App) void {
        self.number += 1;
        self.dirty = true;
    }

    fn convert(self: *App) void {
        self.imgv2[0..4].* = .{ 0x22, 240, 0, 0xFF };

        const src = imgv1[6..14];

        var tile: [8][4]u8 = undefined;

        inline for (0..8) |row| {
            const bits = src[row];

            inline for (0..4) |i| {
                const b0: u8 = if (((bits >> @as(u3, @intCast(7 - i * 2))) & 1) != 0) 0 else 12;
                const b1: u8 = if (((bits >> @as(u3, @intCast(6 - i * 2))) & 1) != 0) 0 else 12;

                tile[row][i] = (b0 << 4) | b1;
            }
        }

        for (0..20) |ty| {
            inline for (0..8) |row| {
                const dst_row = 4 + (ty * 8 + row) * 120;

                for (0..30) |tx| {
                    const dst = dst_row + tx * 4;

                    self.imgv2[dst + 0] = tile[row][0];
                    self.imgv2[dst + 1] = tile[row][1];
                    self.imgv2[dst + 2] = tile[row][2];
                    self.imgv2[dst + 3] = tile[row][3];
                }
            }
        }
    }

    fn zoom(g: Gallery, c: ff.Color, sprite: [8]u8) void {
        const s = ff.Style{
            .fill_color = c,
            .stroke_color = if (c == .white) .black else .white,
            .stroke_width = 1,
        };

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

    var imgv1 = [14]u8{
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

const Palette = enum {
    OneBitMonitorGlow, // https://lospec.com/palette-list/1bit-monitor-glow
    ObraDinnIBM8503, // https://lospec.com/palette-list/obra-dinn-ibm-8503
    MacPaint, // https://lospec.com/palette-list/mac-paint
    Note2C, // https://lospec.com/palette-list/note-2c
    IBM51, // https://lospec.com/palette-list/ibm-51

    fn colors(self: Palette) [2]u32 {
        return switch (self) {
            .OneBitMonitorGlow => .{ 0xf0f6f0, 0x222323 },
            .ObraDinnIBM8503 => .{ 0xebe5ce, 0x2e3037 },
            .MacPaint => .{ 0x8bc8fe, 0x051b2c },
            .Note2C => .{ 0xedf2e2, 0x222a3d },
            .IBM51 => .{ 0xd3c9a1, 0x323c39 },
        };
    }

    fn next(self: Palette) Palette {
        return switch (self) {
            .OneBitMonitorGlow => .ObraDinnIBM8503,
            .ObraDinnIBM8503 => .MacPaint,
            .MacPaint => .Note2C,
            .Note2C => .IBM51,
            .IBM51 => .OneBitMonitorGlow,
        };
    }
};
