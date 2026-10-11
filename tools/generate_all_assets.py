import os
import math
from PIL import Image, ImageDraw, ImageFilter

fx_dir = 'd:/QVVC/assets/fx'
ui_dir = 'd:/QVVC/assets/ui'
os.makedirs(fx_dir, exist_ok=True)
os.makedirs(ui_dir, exist_ok=True)

# Helper: Radial gradient circle
def draw_radial_glow(draw, center, radius, color_inner, color_outer):
    cx, cy = center
    for r in range(radius, 0, -1):
        ratio = r / float(radius)
        cr = int(color_inner[0] * (1.0 - ratio) + color_outer[0] * ratio)
        cg = int(color_inner[1] * (1.0 - ratio) + color_outer[1] * ratio)
        cb = int(color_inner[2] * (1.0 - ratio) + color_outer[2] * ratio)
        ca = int(color_inner[3] * (1.0 - ratio) + color_outer[3] * ratio)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(cr, cg, cb, ca))

# ==========================================
# 1. FX ASSETS
# ==========================================

# 1.1 Slash Arc 1 (Cyan Crescent) - 128x128
def gen_slash_arc_1():
    im = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 64, 64
    for r in range(48, 20, -1):
        t = (r - 20) / 28.0
        alpha = int(255 * math.sin(t * math.pi))
        col = (int(80 + 175 * t), int(200 + 55 * t), 255, alpha)
        # Arc from -60 deg to +80 deg
        bbox = [cx - r, cy - r, cx + r, cy + r]
        draw.arc(bbox, start=-60, end=75, fill=col, width=3)
    # Bright core
    draw.arc([cx - 40, cy - 40, cx + 40, cy + 40], start=-50, end=65, fill=(255, 255, 255, 240), width=2)
    im.save(os.path.join(fx_dir, 'slash_arc_1.png'))

# 1.2 Slash Arc 2 (Violet Crescent) - 128x128
def gen_slash_arc_2():
    im = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 64, 64
    for r in range(50, 22, -1):
        t = (r - 22) / 28.0
        alpha = int(255 * math.sin(t * math.pi))
        col = (int(190 + 65 * t), int(90 + 120 * t), 255, alpha)
        bbox = [cx - r, cy - r, cx + r, cy + r]
        draw.arc(bbox, start=-140, end=-10, fill=col, width=3)
    draw.arc([cx - 42, cy - 42, cx + 42, cy + 42], start=-130, end=-20, fill=(255, 230, 255, 240), width=2)
    im.save(os.path.join(fx_dir, 'slash_arc_2.png'))

# 1.3 Slash Heavy Cleave (Golden Fiery Arc) - 144x144
def gen_slash_heavy():
    im = Image.new('RGBA', (144, 144), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 72, 72
    for r in range(58, 24, -1):
        t = (r - 24) / 34.0
        alpha = int(255 * math.sin(t * math.pi))
        col = (255, int(160 + 95 * t), int(30 + 150 * t), alpha)
        draw.arc([cx - r, cy - r, cx + r, cy + r], start=-85, end=85, fill=col, width=4)
    draw.arc([cx - 46, cy - 46, cx + 46, cy + 46], start=-70, end=70, fill=(255, 255, 220, 255), width=3)
    # Radiating sparks
    for deg in range(-70, 75, 12):
        rad = math.radians(deg)
        x1 = cx + math.cos(rad) * 48
        y1 = cy + math.sin(rad) * 48
        x2 = cx + math.cos(rad) * 62
        y2 = cy + math.sin(rad) * 62
        draw.line([x1, y1, x2, y2], fill=(255, 230, 100, 200), width=2)
    im.save(os.path.join(fx_dir, 'slash_heavy.png'))

# 1.4 Whirlwind Dual Cyclone Ring - 240x240
def gen_whirlwind():
    im = Image.new('RGBA', (240, 240), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 120, 120
    # Outer ring
    for r in range(105, 85, -1):
        t = (r - 85) / 20.0
        alpha = int(180 * math.sin(t * math.pi))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(70, 200, 255, alpha), width=2)
    # Inner ring
    for r in range(75, 55, -1):
        t = (r - 55) / 20.0
        alpha = int(220 * math.sin(t * math.pi))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(200, 240, 255, alpha), width=2)
    # Swirling blade streaks
    for a in range(0, 360, 45):
        rad = math.radians(a)
        draw.arc([cx - 95, cy - 95, cx + 95, cy + 95], start=a, end=a + 30, fill=(255, 255, 255, 230), width=3)
    im.save(os.path.join(fx_dir, 'fx_whirlwind.png'))

# 1.5 Void Lance Beam - 220x64
def gen_void_lance():
    im = Image.new('RGBA', (220, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cy = 32
    # Outer purple sheath
    for y in range(4, 28):
        alpha = int(220 * (1.0 - y / 28.0))
        draw.line([10, cy - y, 200, cy - y], fill=(160, 40, 240, alpha), width=1)
        draw.line([10, cy + y, 200, cy + y], fill=(160, 40, 240, alpha), width=1)
    # Sharp spear tip
    draw.polygon([(190, 8), (218, 32), (190, 56)], fill=(200, 80, 255, 220))
    # Intense central core
    draw.line([10, cy, 210, cy], fill=(255, 255, 255, 255), width=6)
    draw.line([10, cy - 3, 200, cy - 3], fill=(220, 150, 255, 200), width=2)
    draw.line([10, cy + 3, 200, cy + 3], fill=(220, 150, 255, 200), width=2)
    im.save(os.path.join(fx_dir, 'fx_void_lance.png'))

# 1.6 Celestial Sword - 96x200
def gen_celestial_sword():
    im = Image.new('RGBA', (96, 200), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx = 48
    # Golden Aura glow
    for x in range(1, 16):
        a = int(120 * (1.0 - x / 16.0))
        draw.line([cx - 10 - x, 40, cx - 10 - x, 175], fill=(255, 200, 50, a), width=1)
        draw.line([cx + 10 + x, 40, cx + 10 + x, 175], fill=(255, 200, 50, a), width=1)
    # Golden blade
    draw.polygon([(cx - 10, 45), (cx + 10, 45), (cx + 10, 170), (cx, 195), (cx - 10, 170)], fill=(255, 225, 80, 255))
    # Blade fuller & highlight
    draw.line([cx, 50, cx, 180], fill=(255, 255, 255, 240), width=4)
    # Crossguard
    draw.rectangle([cx - 28, 36, cx + 28, 45], fill=(210, 160, 40, 255))
    draw.rectangle([cx - 26, 38, cx + 26, 43], fill=(255, 240, 120, 255))
    # Ruby gem at crossguard center
    draw.ellipse([cx - 6, 35, cx + 6, 46], fill=(220, 20, 60, 255))
    draw.ellipse([cx - 3, 37, cx + 3, 43], fill=(255, 120, 150, 255))
    # Hilt & Pommel
    draw.line([cx, 12, cx, 36], fill=(80, 50, 20, 255), width=6)
    draw.ellipse([cx - 8, 4, cx + 8, 14], fill=(210, 160, 40, 255))
    im.save(os.path.join(fx_dir, 'fx_celestial_sword.png'))

# 1.7 Meteor - 96x96
def gen_meteor():
    im = Image.new('RGBA', (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 48, 48
    draw_radial_glow(draw, (cx, cy), 44, (255, 100, 20, 180), (255, 40, 0, 0))
    draw_radial_glow(draw, (cx, cy), 32, (255, 200, 40, 240), (255, 80, 0, 80))
    # Molten asteroid core
    draw.ellipse([cx - 18, cy - 18, cx + 18, cy + 18], fill=(60, 25, 15, 255))
    draw.ellipse([cx - 14, cy - 14, cx + 14, cy + 14], fill=(180, 60, 20, 255))
    draw.ellipse([cx - 8, cy - 8, cx + 8, cy + 8], fill=(255, 220, 100, 255))
    im.save(os.path.join(fx_dir, 'fx_meteor.png'))

# 1.8 Crater / Runic Telegraph - 160x160
def gen_crater():
    im = Image.new('RGBA', (160, 160), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 80, 80
    # Outer red warning ring
    draw.ellipse([cx - 72, cy - 72, cx + 72, cy + 72], outline=(255, 40, 40, 220), width=3)
    draw.ellipse([cx - 68, cy - 68, cx + 68, cy + 68], outline=(255, 100, 100, 140), width=1)
    # Inner pulsing zone
    draw.ellipse([cx - 64, cy - 64, cx + 64, cy + 64], fill=(220, 20, 20, 45))
    # Runic cross spokes
    for a in range(0, 360, 45):
        rad = math.radians(a)
        x1 = cx + math.cos(rad) * 45
        y1 = cy + math.sin(rad) * 45
        x2 = cx + math.cos(rad) * 68
        y2 = cy + math.sin(rad) * 68
        draw.line([x1, y1, x2, y2], fill=(255, 80, 80, 180), width=2)
    im.save(os.path.join(fx_dir, 'fx_crater.png'))

# 1.9 Arcane Magic Sigil - 240x240
def gen_magic_sigil():
    im = Image.new('RGBA', (240, 240), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 120, 120
    # Three concentric glowing rings
    draw.ellipse([cx - 110, cy - 110, cx + 110, cy + 110], outline=(180, 70, 255, 220), width=3)
    draw.ellipse([cx - 96, cy - 96, cx + 96, cy + 96], outline=(150, 40, 230, 180), width=2)
    draw.ellipse([cx - 60, cy - 60, cx + 60, cy + 60], outline=(220, 120, 255, 200), width=2)
    # 8-point geometric star
    points = []
    for i in range(8):
        rad = math.radians(i * 45)
        r = 96
        points.append((cx + math.cos(rad) * r, cy + math.sin(rad) * r))
    for i in range(8):
        draw.line([points[i], points[(i + 3) % 8]], fill=(200, 90, 255, 170), width=2)
    im.save(os.path.join(fx_dir, 'fx_magic_sigil.png'))

# 1.10 Void Death Beam - 800x48
def gen_void_beam():
    im = Image.new('RGBA', (800, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cy = 24
    for y in range(1, 24):
        a = int(220 * (1.0 - y / 24.0))
        draw.line([0, cy - y, 800, cy - y], fill=(160, 30, 230, a), width=1)
        draw.line([0, cy + y, 800, cy + y], fill=(160, 30, 230, a), width=1)
    # Magenta inner halo
    for y in range(1, 10):
        a = int(240 * (1.0 - y / 10.0))
        draw.line([0, cy - y, 800, cy - y], fill=(230, 80, 255, a), width=1)
        draw.line([0, cy + y, 800, cy + y], fill=(230, 80, 255, a), width=1)
    # Core
    draw.line([0, cy, 800, cy], fill=(255, 255, 255, 255), width=8)
    im.save(os.path.join(fx_dir, 'fx_void_beam.png'))

# 1.11 Shockwave Ring - 240x240
def gen_shockwave():
    im = Image.new('RGBA', (240, 240), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 120, 120
    for r in range(112, 92, -1):
        t = (r - 92) / 20.0
        alpha = int(230 * math.sin(t * math.pi))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(190, 90, 255, alpha), width=2)
    draw.ellipse([cx - 102, cy - 102, cx + 102, cy + 102], outline=(255, 255, 255, 240), width=3)
    im.save(os.path.join(fx_dir, 'fx_shockwave.png'))

# 1.12 Gravitational Vortex Singularity - 180x180
def gen_vortex():
    im = Image.new('RGBA', (180, 180), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 90, 90
    draw_radial_glow(draw, (cx, cy), 85, (120, 40, 200, 180), (40, 10, 80, 0))
    # Accretion spiral lines
    for arm in range(4):
        base_angle = arm * (math.pi / 2.0)
        pts = []
        for step in range(20, 80, 3):
            theta = base_angle + (step * 0.08)
            x = cx + math.cos(theta) * step
            y = cy + math.sin(theta) * step
            pts.append((x, y))
        draw.line(pts, fill=(200, 100, 255, 220), width=3)
    # Event Horizon
    draw.ellipse([cx - 24, cy - 24, cx + 24, cy + 24], fill=(10, 4, 18, 255), outline=(220, 140, 255, 240), width=3)
    im.save(os.path.join(fx_dir, 'fx_vortex.png'))

# 1.13 Dimensional Cleave Tear - 800x48
def gen_cleave_line():
    im = Image.new('RGBA', (800, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cy = 24
    for y in range(1, 20):
        a = int(220 * (1.0 - y / 20.0))
        draw.line([0, cy - y, 800, cy - y], fill=(240, 30, 80, a), width=1)
        draw.line([0, cy + y, 800, cy + y], fill=(240, 30, 80, a), width=1)
    draw.line([0, cy, 800, cy], fill=(255, 255, 255, 255), width=6)
    draw.line([0, cy - 2, 800, cy - 2], fill=(255, 120, 180, 220), width=2)
    draw.line([0, cy + 2, 800, cy + 2], fill=(255, 120, 180, 220), width=2)
    im.save(os.path.join(fx_dir, 'fx_cleave_line.png'))

# 1.14 Hit Spark - 48x48
def gen_hit_spark():
    im = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 24, 24
    draw_radial_glow(draw, (cx, cy), 22, (255, 220, 60, 240), (255, 120, 20, 0))
    # 4 long cardinal spikes
    draw.line([cx - 20, cy, cx + 20, cy], fill=(255, 255, 255, 255), width=2)
    draw.line([cx, cy - 20, cx, cy + 20], fill=(255, 255, 255, 255), width=2)
    # 4 diagonal spikes
    draw.line([cx - 12, cy - 12, cx + 12, cy + 12], fill=(255, 230, 120, 220), width=2)
    draw.line([cx - 12, cy + 12, cx + 12, cy - 12], fill=(255, 230, 120, 220), width=2)
    im.save(os.path.join(fx_dir, 'fx_hit_spark.png'))

# 1.15 Soul Ember - 24x24
def gen_ember():
    im = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 12, 12
    draw_radial_glow(draw, (cx, cy), 11, (220, 120, 255, 240), (120, 30, 220, 0))
    draw.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=(255, 255, 255, 255))
    im.save(os.path.join(fx_dir, 'fx_ember.png'))


# ==========================================
# 2. UI FRAME ASSETS
# ==========================================

# 2.1 Hero Portrait - 64x64
def gen_hero_portrait():
    im = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Dark obsidian backdrop
    draw.rectangle([0, 0, 63, 63], fill=(20, 22, 34, 255))
    # Cape shoulders
    draw.polygon([(4, 63), (18, 42), (46, 42), (60, 63)], fill=(45, 30, 65, 255))
    # Armor chestplate
    draw.polygon([(18, 44), (46, 44), (40, 63), (24, 63)], fill=(75, 85, 105, 255))
    draw.line([32, 45, 32, 63], fill=(130, 145, 175, 255), width=2)
    # Head & Neck
    draw.rectangle([26, 34, 38, 44], fill=(180, 140, 110, 255))
    draw.rectangle([20, 16, 44, 36], fill=(210, 165, 130, 255)) # Face
    # Silver knight helmet visor
    draw.polygon([(16, 12), (48, 12), (44, 26), (20, 26)], fill=(120, 135, 155, 255))
    draw.line([16, 12, 48, 12], fill=(200, 215, 235, 255), width=2)
    # Glowing mystic cyan eyes
    draw.rectangle([24, 27, 28, 29], fill=(0, 245, 212, 255))
    draw.rectangle([36, 27, 40, 29], fill=(0, 245, 212, 255))
    # Shadow and chin
    draw.rectangle([28, 33, 36, 35], fill=(140, 100, 75, 255))
    im.save(os.path.join(ui_dir, 'portrait_hero.png'))

# 2.2 Portrait Frame - 72x72
def gen_frame_portrait():
    im = Image.new('RGBA', (72, 72), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Outer gold rim
    draw.rectangle([0, 0, 71, 71], outline=(218, 165, 32, 255), width=3)
    # Inner steel bevel
    draw.rectangle([3, 3, 68, 68], outline=(70, 75, 95, 255), width=2)
    draw.rectangle([5, 5, 66, 66], outline=(255, 215, 0, 255), width=1)
    # Corner rivets
    for x in [4, 67]:
        for y in [4, 67]:
            draw.ellipse([x - 2, y - 2, x + 2, y + 2], fill=(255, 235, 130, 255))
    im.save(os.path.join(ui_dir, 'frame_portrait.png'))

# 2.3 Character HUD Panel Frame - 300x96
def gen_frame_player():
    im = Image.new('RGBA', (300, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Dark obsidian stone background
    draw.rounded_rectangle([0, 0, 299, 95], radius=6, fill=(18, 20, 30, 235))
    # Double golden border with filigree
    draw.rounded_rectangle([1, 1, 298, 94], radius=5, outline=(180, 140, 50, 255), width=2)
    draw.rounded_rectangle([4, 4, 295, 91], radius=4, outline=(70, 75, 95, 200), width=1)
    draw.rounded_rectangle([6, 6, 293, 89], radius=3, outline=(240, 200, 80, 160), width=1)
    # Corner gems (Sapphire)
    for cx in [6, 293]:
        for cy in [6, 89]:
            draw.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=(30, 120, 255, 255), outline=(200, 230, 255, 255), width=1)
    im.save(os.path.join(ui_dir, 'frame_player.png'))

# 2.4 Boss HP Frame - 640x50
def gen_frame_boss_hp():
    im = Image.new('RGBA', (640, 50), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    # Stone backing
    draw.rectangle([20, 8, 619, 41], fill=(16, 17, 26, 240))
    # Heavy gold and ruby framed border
    draw.rectangle([18, 6, 621, 43], outline=(190, 145, 40, 255), width=2)
    draw.rectangle([21, 9, 618, 40], outline=(100, 40, 120, 255), width=1)
    # Center Demonic Skull / Crest ornament
    cx = 320
    draw.polygon([(cx - 24, 0), (cx + 24, 0), (cx + 16, 16), (cx - 16, 16)], fill=(218, 165, 32, 255))
    draw.ellipse([cx - 8, 2, cx + 8, 14], fill=(220, 30, 40, 255)) # Central Dragon Eye
    # Left & Right Winged Crests
    draw.polygon([(10, 24), (24, 8), (24, 40)], fill=(218, 165, 32, 255))
    draw.polygon([(630, 24), (616, 8), (616, 40)], fill=(218, 165, 32, 255))
    im.save(os.path.join(ui_dir, 'frame_boss_hp.png'))

# 2.5 Progress Bar Fill Textures - 400x20
def gen_bar_textures():
    # Carved Bar Background Slot
    im_bg = Image.new('RGBA', (400, 20), (0, 0, 0, 0))
    d_bg = ImageDraw.Draw(im_bg)
    d_bg.rounded_rectangle([0, 0, 399, 19], radius=3, fill=(12, 13, 20, 255), outline=(50, 55, 75, 255), width=1)
    d_bg.line([2, 2, 397, 2], fill=(6, 7, 10, 255), width=1) # Inner shadow
    im_bg.save(os.path.join(ui_dir, 'bar_bg.png'))

    # Player HP Fill (Crimson to Emerald or Ruby Gradient)
    im_hp = Image.new('RGBA', (400, 20), (0, 0, 0, 0))
    d_hp = ImageDraw.Draw(im_hp)
    for x in range(400):
        t = x / 400.0
        r = int(220 * (1.0 - t * 0.2))
        g = int(35 + 40 * t)
        b = int(50 + 20 * t)
        d_hp.line([x, 1, x, 18], fill=(r, g, b, 255), width=1)
    d_hp.line([0, 1, 399, 1], fill=(255, 140, 160, 255), width=1) # Gloss highlight
    im_hp.save(os.path.join(ui_dir, 'bar_player_hp.png'))

    # Boss HP Fill (Void Purple to Crimson)
    im_boss = Image.new('RGBA', (400, 20), (0, 0, 0, 0))
    d_boss = ImageDraw.Draw(im_boss)
    for x in range(400):
        t = x / 400.0
        r = int(140 + 100 * t)
        g = int(30 * (1.0 - t))
        b = int(220 * (1.0 - t * 0.6))
        d_boss.line([x, 1, x, 18], fill=(r, g, b, 255), width=1)
    d_boss.line([0, 1, 399, 1], fill=(230, 150, 255, 255), width=1)
    im_boss.save(os.path.join(ui_dir, 'bar_boss_hp.png'))

# 2.6 Skill Slot Frame - 56x56
def gen_frame_skill_slot():
    im = Image.new('RGBA', (56, 56), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle([0, 0, 55, 55], radius=6, fill=(18, 20, 32, 240))
    draw.rounded_rectangle([1, 1, 54, 54], radius=5, outline=(180, 140, 50, 255), width=2)
    draw.rounded_rectangle([3, 3, 52, 52], radius=4, outline=(90, 80, 120, 180), width=1)
    # Corner rivets
    for x in [4, 51]:
        for y in [4, 51]:
            draw.rectangle([x, y, x + 1, y + 1], fill=(255, 230, 120, 255))
    im.save(os.path.join(ui_dir, 'frame_skill_slot.png'))

# 2.7 Modal Dialog Frame - 780x520
def gen_frame_modal():
    im = Image.new('RGBA', (780, 520), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle([0, 0, 779, 519], radius=10, fill=(17, 18, 28, 250))
    draw.rounded_rectangle([2, 2, 777, 517], radius=8, outline=(190, 145, 45, 255), width=3)
    draw.rounded_rectangle([6, 6, 773, 513], radius=6, outline=(85, 75, 115, 200), width=1)
    # Header bar background
    draw.rounded_rectangle([8, 8, 771, 58], radius=4, fill=(28, 30, 46, 255))
    draw.line([8, 59, 771, 59], fill=(180, 140, 40, 255), width=2)
    # Corner filigrees
    for cx in [12, 767]:
        for cy in [12, 507]:
            draw.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=(220, 175, 50, 255))
            draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(255, 40, 60, 255))
    im.save(os.path.join(ui_dir, 'frame_modal.png'))

# 2.8 Card / Slot Frame - 260x100
def gen_frame_card():
    im = Image.new('RGBA', (260, 100), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle([0, 0, 259, 99], radius=6, fill=(22, 24, 38, 235))
    draw.rounded_rectangle([1, 1, 258, 98], radius=5, outline=(160, 120, 40, 255), width=2)
    draw.rounded_rectangle([4, 4, 255, 95], radius=4, outline=(65, 70, 95, 180), width=1)
    im.save(os.path.join(ui_dir, 'frame_card.png'))

# Run all generators
print('Generating FX assets...')
gen_slash_arc_1()
gen_slash_arc_2()
gen_slash_heavy()
gen_whirlwind()
gen_void_lance()
gen_celestial_sword()
gen_meteor()
gen_crater()
gen_magic_sigil()
gen_void_beam()
gen_shockwave()
gen_vortex()
gen_cleave_line()
gen_hit_spark()
gen_ember()

print('Generating UI assets...')
gen_hero_portrait()
gen_frame_portrait()
gen_frame_player()
gen_frame_boss_hp()
gen_bar_textures()
gen_frame_skill_slot()
gen_frame_modal()
gen_frame_card()

print('All 24 FX & UI assets generated successfully!')
