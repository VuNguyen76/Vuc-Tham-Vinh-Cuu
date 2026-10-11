import os
import math
from PIL import Image, ImageDraw, ImageFilter
import numpy as np

base_dir = r"d:\QVVC"
ui_dir = os.path.join(base_dir, "assets", "ui")
icons_dir = os.path.join(base_dir, "assets", "icons")
os.makedirs(ui_dir, exist_ok=True)
os.makedirs(icons_dir, exist_ok=True)

def draw_radial_glow(draw, center, radius, color_inner, color_outer):
    cx, cy = center
    r_int = int(radius)
    for r in range(r_int, 0, -2):
        t = 1.0 - (r / float(radius))
        r_c = int(color_inner[0] * t + color_outer[0] * (1.0 - t))
        g_c = int(color_inner[1] * t + color_outer[1] * (1.0 - t))
        b_c = int(color_inner[2] * t + color_outer[2] * (1.0 - t))
        a_c = int(color_inner[3] * t + color_outer[3] * (1.0 - t))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_c, g_c, b_c, a_c))

# -------------------------------------------------------------------------
# 1. Authentic Hero Portrait from Master Art (1024x1024)
# -------------------------------------------------------------------------
def gen_hero_portrait():
    p = r"C:\Users\Admin\.gemini\antigravity\brain\d732af13-5821-4892-a1fc-832fb1bf5365\qvvc_player_sprite_1791680407418.jpg"
    if os.path.exists(p):
        im = Image.open(p)
        crop = im.crop((486 - 110, 280, 486 + 110, 500)).convert('RGBA')
        arr = np.array(crop)
        is_white = (arr[:, :, 0] > 240) & (arr[:, :, 1] > 240) & (arr[:, :, 2] > 240)
        arr[:, :, 3] = np.where(is_white, 0, 255)
        knight_alpha = Image.fromarray(arr)

        bg = Image.new('RGBA', (220, 220), (14, 16, 26, 255))
        bg_draw = ImageDraw.Draw(bg)
        draw_radial_glow(bg_draw, (110, 95), 100, (40, 80, 160, 220), (14, 16, 26, 0))
        bg.paste(knight_alpha, (0, 0), knight_alpha)

        final_64 = bg.resize((64, 64), Image.Resampling.LANCZOS)
        final_64.save(os.path.join(ui_dir, "portrait_hero.png"))
        print("Generated portrait_hero.png from master art")
    else:
        print("Master art not found, skipping portrait")

# -------------------------------------------------------------------------
# 2. Ornate Portrait Frame (72x72)
# -------------------------------------------------------------------------
def gen_frame_portrait():
    im = Image.new('RGBA', (72, 72), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Beveled gold rim
    draw.rectangle([0, 0, 71, 71], outline=(160, 120, 30, 255), width=1)
    draw.rectangle([1, 1, 70, 70], outline=(235, 190, 60, 255), width=2)
    draw.rectangle([3, 3, 68, 68], outline=(120, 85, 20, 255), width=1)
    draw.rectangle([4, 4, 67, 67], outline=(20, 22, 34, 255), width=2)
    # Corner rivets
    for x in [5, 66]:
        for y in [5, 66]:
            draw.ellipse([x - 2, y - 2, x + 2, y + 2], fill=(255, 225, 110, 255), outline=(130, 90, 20, 255))
    im.save(os.path.join(ui_dir, "frame_portrait.png"))
    print("Generated frame_portrait.png")

# -------------------------------------------------------------------------
# 3. Gothic Player HUD Panel Frame (320x100 NinePatch)
# -------------------------------------------------------------------------
def gen_frame_player():
    w, h = 320, 100
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Dark obsidian stone background
    draw.rounded_rectangle([2, 2, w - 3, h - 3], radius=6, fill=(16, 18, 28, 240))
    # Outer gold frame
    draw.rounded_rectangle([1, 1, w - 2, h - 2], radius=6, outline=(190, 150, 50, 255), width=2)
    draw.rounded_rectangle([4, 4, w - 5, h - 5], radius=4, outline=(40, 45, 65, 255), width=1)
    # Inner border line
    draw.rounded_rectangle([6, 6, w - 7, h - 7], radius=3, outline=(140, 110, 40, 180), width=1)
    # Corner golden brackets
    bracket_len = 16
    for cx, cy, dx, dy in [(6, 6, 1, 1), (w - 7, 6, -1, 1), (6, h - 7, 1, -1), (w - 7, h - 7, -1, -1)]:
        draw.line([cx, cy, cx + dx * bracket_len, cy], fill=(255, 215, 80, 255), width=2)
        draw.line([cx, cy, cx, cy + dy * bracket_len], fill=(255, 215, 80, 255), width=2)
        draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(255, 235, 140, 255))
    im.save(os.path.join(ui_dir, "frame_player.png"))
    print("Generated frame_player.png")

# -------------------------------------------------------------------------
# 4. Ornate Boss HP Frame & Crest (640x54)
# -------------------------------------------------------------------------
def gen_frame_boss_hp():
    w, h = 640, 54
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Dark stone backing
    draw.rectangle([16, 12, w - 17, h - 10], fill=(14, 15, 24, 245))
    # Beveled gold and steel borders
    draw.rectangle([14, 10, w - 15, h - 8], outline=(180, 140, 45, 255), width=2)
    draw.rectangle([17, 13, w - 18, h - 11], outline=(50, 45, 70, 255), width=1)
    # Left and right ornamental caps
    for cx, sign in [(14, 1), (w - 15, -1)]:
        draw.polygon([(cx, 8), (cx + sign * 14, 27), (cx, 46)], fill=(210, 165, 50, 255))
        draw.polygon([(cx + sign * 3, 14), (cx + sign * 11, 27), (cx + sign * 3, 40)], fill=(90, 20, 35, 255))
    # Center crest: demonic dragon horns / skull emblem
    cx = w // 2
    draw.polygon([(cx - 32, 0), (cx + 32, 0), (cx + 20, 22), (cx - 20, 22)], fill=(225, 175, 55, 255))
    draw.polygon([(cx - 16, 4), (cx + 16, 4), (cx + 10, 18), (cx - 10, 18)], fill=(120, 20, 40, 255))
    # Ruby eye at center
    draw.ellipse([cx - 4, 8, cx + 4, 16], fill=(255, 40, 70, 255), outline=(255, 220, 120, 255))
    im.save(os.path.join(ui_dir, "frame_boss_hp.png"))
    print("Generated frame_boss_hp.png")

# -------------------------------------------------------------------------
# 5. Boss HP Bar (Ruby Demonic Gradient) & Player HP Bar (Vitality Green)
# -------------------------------------------------------------------------
def gen_hp_bars():
    # Boss HP Bar - 580x18
    w_b, h_b = 580, 18
    im_b = Image.new('RGBA', (w_b, h_b), (0, 0, 0, 0))
    draw_b = ImageDraw.Draw(im_b)
    for y in range(h_b):
        t = y / float(h_b)
        # Fiery crimson-ruby gradient with highlight near top
        if t < 0.35:
            r = int(255 * (0.8 + 0.2 * (t / 0.35)))
            g = int(60 + 50 * (1.0 - t / 0.35))
            b = int(90 + 30 * (1.0 - t / 0.35))
        else:
            tt = (t - 0.35) / 0.65
            r = int(240 * (1.0 - 0.4 * tt))
            g = int(30 * (1.0 - 0.6 * tt))
            b = int(50 * (1.0 - 0.6 * tt))
        draw_b.line([0, y, w_b - 1, y], fill=(r, g, b, 255), width=1)
    # Gloss sheen line
    draw_b.line([0, 2, w_b - 1, 2], fill=(255, 220, 230, 180), width=1)
    im_b.save(os.path.join(ui_dir, "bar_boss_hp.png"))

    # Player HP Bar - 220x18 (Emerald Vitality Gradient)
    w_p, h_p = 220, 18
    im_p = Image.new('RGBA', (w_p, h_p), (0, 0, 0, 0))
    draw_p = ImageDraw.Draw(im_p)
    for y in range(h_p):
        t = y / float(h_p)
        if t < 0.35:
            r = int(50 + 60 * (1.0 - t / 0.35))
            g = int(245)
            b = int(120 + 60 * (1.0 - t / 0.35))
        else:
            tt = (t - 0.35) / 0.65
            r = int(20 * (1.0 - 0.5 * tt))
            g = int(200 * (1.0 - 0.45 * tt))
            b = int(50 * (1.0 - 0.5 * tt))
        draw_p.line([0, y, w_p - 1, y], fill=(r, g, b, 255), width=1)
    # Glass sheen line
    draw_p.line([0, 2, w_p - 1, 2], fill=(220, 255, 235, 200), width=1)
    im_p.save(os.path.join(ui_dir, "bar_player_hp.png"))

    # Bar Background - 580x18 (Dark Grooved Metal Slot)
    im_bg = Image.new('RGBA', (w_b, h_b), (10, 11, 16, 255))
    draw_bg = ImageDraw.Draw(im_bg)
    draw_bg.rectangle([0, 0, w_b - 1, h_b - 1], outline=(35, 38, 52, 255), width=1)
    # Subtle vertical notch grooves every 40px
    for x in range(40, w_b, 40):
        draw_bg.line([x, 2, x, h_b - 3], fill=(22, 24, 34, 255), width=1)
    im_bg.save(os.path.join(ui_dir, "bar_bg.png"))
    print("Generated bar_boss_hp.png, bar_player_hp.png, bar_bg.png")

# -------------------------------------------------------------------------
# 6. Ornate Skill Slot Frame (64x64 NinePatch)
# -------------------------------------------------------------------------
def gen_frame_skill_slot():
    w, h = 64, 64
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Inset dark slot
    draw.rounded_rectangle([3, 3, w - 4, h - 4], radius=4, fill=(14, 16, 24, 240))
    # Golden beveled border
    draw.rounded_rectangle([1, 1, w - 2, h - 2], radius=5, outline=(190, 150, 45, 255), width=2)
    draw.rounded_rectangle([4, 4, w - 5, h - 5], radius=3, outline=(40, 45, 65, 255), width=1)
    # Corner rivets
    for x in [5, w - 6]:
        for y in [5, h - 6]:
            draw.ellipse([x - 2, y - 2, x + 2, y + 2], fill=(255, 225, 110, 255))
    im.save(os.path.join(ui_dir, "frame_skill_slot.png"))
    print("Generated frame_skill_slot.png")

# -------------------------------------------------------------------------
# 7. Real Skill Icons (48x48) in assets/icons/
# -------------------------------------------------------------------------
def gen_skill_icons():
    # --- Skill [Q] Whirlwind (Toàn Phong) ---
    im_q = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw_q = ImageDraw.Draw(im_q)
    draw_radial_glow(draw_q, (24, 24), 22, (20, 80, 160, 255), (8, 12, 22, 255))
    # Golden border ring
    draw_q.ellipse([1, 1, 46, 46], outline=(200, 160, 50, 255), width=1)
    # Two crossed silver blades
    # Blade 1: (-12, -12) to (12, 12)
    draw_q.line([10, 38, 38, 10], fill=(220, 235, 255, 255), width=3)
    draw_q.line([9, 39, 37, 11], fill=(120, 150, 190, 255), width=1)
    # Blade 2: (12, -12) to (-12, 12)
    draw_q.line([10, 10, 38, 38], fill=(220, 235, 255, 255), width=3)
    draw_q.line([11, 9, 39, 37], fill=(120, 150, 190, 255), width=1)
    # Golden hilts
    draw_q.ellipse([8, 36, 12, 40], fill=(255, 200, 50, 255))
    draw_q.ellipse([8, 8, 12, 12], fill=(255, 200, 50, 255))
    # Cyan whirlwind spiral arcs
    draw_q.arc([6, 6, 42, 42], start=30, end=150, fill=(0, 240, 255, 255), width=2)
    draw_q.arc([8, 8, 40, 40], start=210, end=330, fill=(100, 255, 240, 255), width=2)
    # Wind spark glints
    draw_q.ellipse([22, 12, 26, 16], fill=(255, 255, 255, 255))
    draw_q.ellipse([22, 32, 26, 36], fill=(255, 255, 255, 255))
    im_q.save(os.path.join(icons_dir, "skill_q.png"))

    # --- Skill [E] Void Piercer (Trảm Hồn) ---
    im_e = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw_e = ImageDraw.Draw(im_e)
    draw_radial_glow(draw_e, (24, 24), 22, (90, 25, 160, 255), (14, 8, 26, 255))
    draw_e.ellipse([1, 1, 46, 46], outline=(180, 80, 240, 255), width=1)
    # Piercing void lance: diagonal shaft thrusting from bottom-left to top-right
    draw_e.line([8, 40, 40, 8], fill=(230, 180, 255, 255), width=3)
    # Sharp spear tip
    draw_e.polygon([(40, 8), (44, 4), (36, 16)], fill=(255, 255, 255, 255))
    draw_e.polygon([(40, 8), (44, 4), (28, 12)], fill=(210, 120, 255, 255))
    # Void energy spiral around lance
    for i in range(4):
        offset = i * 8
        draw_e.arc([10 + offset, 26 - offset, 22 + offset, 38 - offset], start=45, end=225, fill=(160, 50, 255, 230), width=2)
    # Starlight piercing glints at spear tip
    draw_e.line([42, 2, 46, 6], fill=(255, 255, 255, 255), width=2)
    draw_e.line([46, 2, 42, 6], fill=(255, 255, 255, 255), width=2)
    im_e.save(os.path.join(icons_dir, "skill_e.png"))

    # --- Skill [R] Celestial Starfall (Thần Kiếm) ---
    im_r = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw_r = ImageDraw.Draw(im_r)
    draw_radial_glow(draw_r, (24, 24), 22, (180, 130, 30, 255), (18, 14, 10, 255))
    draw_r.ellipse([1, 1, 46, 46], outline=(255, 215, 60, 255), width=1)
    # Divine sunburst rays behind sword
    for deg in range(0, 360, 30):
        rad = math.radians(deg)
        x1 = 24 + math.cos(rad) * 14
        y1 = 24 + math.sin(rad) * 14
        x2 = 24 + math.cos(rad) * 22
        y2 = 24 + math.sin(rad) * 22
        draw_r.line([x1, y1, x2, y2], fill=(255, 235, 120, 180), width=1)
    # Giant holy sword pointing down
    # Blade
    draw_r.polygon([(24, 42), (21, 14), (27, 14)], fill=(255, 255, 255, 255))
    draw_r.line([24, 14, 24, 40], fill=(255, 220, 80, 255), width=1)
    # Crossguard
    draw_r.line([16, 14, 32, 14], fill=(255, 200, 40, 255), width=3)
    # Pommel & Grip
    draw_r.line([24, 14, 24, 6], fill=(160, 110, 20, 255), width=2)
    draw_r.ellipse([22, 4, 26, 8], fill=(255, 220, 60, 255))
    # Holy burst at tip
    draw_r.ellipse([22, 38, 26, 42], fill=(255, 255, 255, 255))
    im_r.save(os.path.join(icons_dir, "skill_r.png"))

    # --- Skill [Shift] Phantom Dash (Lướt) ---
    im_dash = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw_dash = ImageDraw.Draw(im_dash)
    draw_radial_glow(draw_dash, (24, 24), 22, (20, 140, 120, 255), (8, 20, 22, 255))
    draw_dash.ellipse([1, 1, 46, 46], outline=(40, 230, 180, 255), width=1)
    # Winged speed boot / motion trails
    # Speed streaks behind boot
    draw_dash.line([6, 16, 20, 16], fill=(100, 255, 220, 180), width=2)
    draw_dash.line([4, 24, 24, 24], fill=(100, 255, 220, 220), width=2)
    draw_dash.line([8, 32, 22, 32], fill=(100, 255, 220, 180), width=2)
    # Boot silhouette
    boot_pts = [(24, 12), (32, 12), (32, 26), (42, 28), (42, 36), (22, 36), (22, 26)]
    draw_dash.polygon(boot_pts, fill=(240, 250, 255, 255))
    draw_dash.polygon([(26, 14), (30, 14), (30, 24), (38, 26), (38, 34), (24, 34)], fill=(40, 180, 220, 255))
    # Wing feather at heel
    wing_pts = [(24, 20), (14, 12), (18, 22), (12, 18), (16, 26)]
    draw_dash.polygon(wing_pts, fill=(255, 240, 140, 255))
    im_dash.save(os.path.join(icons_dir, "skill_dash.png"))

    # --- Backpack Button Icon [B] ---
    im_bag = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw_bag = ImageDraw.Draw(im_bag)
    draw_radial_glow(draw_bag, (24, 24), 22, (120, 70, 25, 255), (20, 12, 8, 255))
    draw_bag.ellipse([1, 1, 46, 46], outline=(210, 150, 40, 255), width=1)
    # Leather backpack body
    draw_bag.rounded_rectangle([12, 14, 36, 40], radius=4, fill=(140, 80, 30, 255), outline=(75, 40, 15, 255), width=1)
    # Top flap
    draw_bag.rounded_rectangle([10, 12, 38, 24], radius=3, fill=(175, 105, 45, 255), outline=(90, 50, 20, 255), width=1)
    # Golden straps and center buckle
    draw_bag.line([18, 12, 18, 38], fill=(60, 35, 15, 255), width=2)
    draw_bag.line([30, 12, 30, 38], fill=(60, 35, 15, 255), width=2)
    draw_bag.rectangle([21, 22, 27, 28], fill=(255, 215, 60, 255), outline=(130, 95, 20, 255), width=1)
    im_bag.save(os.path.join(icons_dir, "icon_bag_btn.png"))
    print("Generated all skill icons in assets/icons/")

# -------------------------------------------------------------------------
# 8. Boss Skill Warning Banner (480x40)
# -------------------------------------------------------------------------
def gen_warning_banner():
    w, h = 480, 40
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Ribbon body
    draw.rectangle([24, 4, w - 25, h - 5], fill=(24, 8, 14, 235))
    draw.rectangle([22, 2, w - 23, h - 3], outline=(220, 40, 60, 255), width=2)
    draw.rectangle([25, 5, w - 26, h - 6], outline=(255, 180, 80, 180), width=1)
    # Left and right swallowtails
    draw.polygon([(24, 4), (0, 20), (24, 36)], fill=(180, 25, 45, 255))
    draw.polygon([(w - 25, 4), (w - 1, 20), (w - 25, 36)], fill=(180, 25, 45, 255))
    im.save(os.path.join(ui_dir, "banner_warning.png"))
    print("Generated banner_warning.png")

# -------------------------------------------------------------------------
# 9. Battle DPS & Stats Plaque (220x36)
# -------------------------------------------------------------------------
def gen_dps_plaque():
    w, h = 220, 36
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle([2, 2, w - 3, h - 3], radius=4, fill=(16, 18, 28, 230))
    draw.rounded_rectangle([1, 1, w - 2, h - 2], radius=4, outline=(70, 140, 210, 255), width=1)
    draw.rounded_rectangle([3, 3, w - 4, h - 4], radius=3, outline=(30, 50, 75, 200), width=1)
    im.save(os.path.join(ui_dir, "frame_dps.png"))
    print("Generated frame_dps.png")

if __name__ == "__main__":
    gen_hero_portrait()
    gen_frame_portrait()
    gen_frame_player()
    gen_frame_boss_hp()
    gen_hp_bars()
    gen_frame_skill_slot()
    gen_skill_icons()
    gen_warning_banner()
    gen_dps_plaque()
    print("=== All UI master assets successfully generated! ===")
