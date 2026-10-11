import os, math
from PIL import Image, ImageDraw, ImageEnhance, ImageOps

KNIGHT_PATH = r"d:\QVVC\assets\player.png"
OUTPUT_SHEET = r"d:\QVVC\assets\player_skills_spritesheet.png"
ANIM_DIR = r"d:\QVVC\assets\player_anim"
os.makedirs(ANIM_DIR, exist_ok=True)

# 1. Load authentic silver knight warrior
base_knight = Image.open(KNIGHT_PATH).convert("RGBA")
# Target cell size 170x192
CW, CH = 170, 192

# Load FX textures
fx_slash1 = Image.open(r"d:\QVVC\assets\fx\slash_arc_1.png").convert("RGBA")
fx_slash2 = Image.open(r"d:\QVVC\assets\fx\slash_arc_2.png").convert("RGBA")
fx_slash_heavy = Image.open(r"d:\QVVC\assets\fx\slash_heavy.png").convert("RGBA")
fx_whirl = Image.open(r"d:\QVVC\assets\fx\fx_whirlwind.png").convert("RGBA")
fx_lance = Image.open(r"d:\QVVC\assets\fx\fx_void_lance.png").convert("RGBA")
fx_celestial = Image.open(r"d:\QVVC\assets\fx\fx_celestial_sword.png").convert("RGBA")
fx_sigil = Image.open(r"d:\QVVC\assets\fx\fx_magic_sigil.png").convert("RGBA")
fx_spark = Image.open(r"d:\QVVC\assets\fx\fx_hit_spark.png").convert("RGBA")
fx_crater = Image.open(r"d:\QVVC\assets\fx\fx_crater.png").convert("RGBA")

# Helper to scale knight cleanly while preserving crisp pixel art
def get_knight_scaled(scale_factor=2.0, flip_h=False, angle=0.0):
    k = base_knight.copy()
    if flip_h:
        k = ImageOps.mirror(k)
    if angle != 0.0:
        k = k.rotate(angle, resample=Image.NEAREST, expand=True)
    new_w = int(k.width * scale_factor)
    new_h = int(k.height * scale_factor)
    return k.resize((new_w, new_h), Image.NEAREST)

def draw_shadow(canvas, cx, cy, width=70, height=26):
    shadow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    d.ellipse([2, 2, width - 4, height - 4], fill=(40, 40, 50, 140))
    canvas.alpha_composite(shadow, (cx - width // 2, cy - height // 2))

# Master sheet: 1024x768 on pure white background
sheet = Image.new("RGBA", (1024, 768), (255, 255, 255, 255))

frames_dict = {
    "attack_combo": [],
    "skill_q_whirlwind": [],
    "skill_e_lance": [],
    "skill_r_celestial": []
}

# =========================================================================
# ROW 0: 3-Hit Sword Attack Combo (Knight dynamic poses)
# =========================================================================
print("Rendering Row 0: Knight Attack Combo...")
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 30
    draw_shadow(cell, cx, cy)

    if c == 0:
        # Windup: Knight pulls broadsword back in anticipation
        k = get_knight_scaled(2.0, flip_h=False, angle=-12)
        cell.alpha_composite(k, (cx - k.width // 2 - 10, cy - k.height + 15))
        spk = fx_spark.resize((35, 35), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 35, cy - 90))
    elif c == 1:
        # Slash 1: Powerful forward cleave with cyan crescent trail
        k = get_knight_scaled(2.05, flip_h=False, angle=14)
        cell.alpha_composite(k, (cx - k.width // 2 + 10, cy - k.height + 15))
        s1 = fx_slash1.resize((120, 120), Image.BILINEAR)
        cell.alpha_composite(s1, (cx - 10, cy - 100))
    elif c == 2:
        # Re-chamber: Recovery step into reverse backhand grip
        k = get_knight_scaled(1.95, flip_h=False, angle=-8)
        cell.alpha_composite(k, (cx - k.width // 2 - 5, cy - k.height + 15))
    elif c == 3:
        # Slash 2: Rising diagonal slash with purple arc + spark
        k = get_knight_scaled(2.1, flip_h=False, angle=-18)
        cell.alpha_composite(k, (cx - k.width // 2 + 15, cy - k.height + 10))
        s2 = fx_slash2.resize((130, 130), Image.BILINEAR)
        cell.alpha_composite(s2, (cx - 20, cy - 115))
        spk = fx_spark.resize((55, 55), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 40, cy - 80))
    elif c == 4:
        # Leap Windup: Knight leaps upward raising greatsword high overhead
        k = get_knight_scaled(2.15, flip_h=False, angle=-5)
        # Higher in the air (reduced shadow)
        cell.alpha_composite(k, (cx - k.width // 2, cy - k.height - 18))
        spk = fx_spark.resize((45, 45), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 15, cy - 135))
    elif c == 5:
        # Heavy Cleave Finisher: Ground-slam cleave with golden flaming wave
        k = get_knight_scaled(2.2, flip_h=False, angle=25)
        cell.alpha_composite(k, (cx - k.width // 2 + 5, cy - k.height + 18))
        sh = fx_slash_heavy.resize((140, 140), Image.BILINEAR)
        cell.alpha_composite(sh, (cx - 70, cy - 110))
        spk = fx_spark.resize((70, 70), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 10, cy - 50))

    sheet.alpha_composite(cell, (c * CW, 0))
    frames_dict["attack_combo"].append(cell)

# =========================================================================
# ROW 1: Skill [Q] - Whirlwind 360 Spin Attack
# =========================================================================
print("Rendering Row 1: Knight Whirlwind Skill...")
spin_angles = [0, 45, 90, 180, 240, 315]
spin_flips = [False, False, True, True, False, False]
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 30
    draw_shadow(cell, cx, cy, width=80)

    # Knight in rapid rotational motion
    k = get_knight_scaled(2.0, flip_h=spin_flips[c], angle=math.sin(c) * 15)
    cell.alpha_composite(k, (cx - k.width // 2, cy - k.height + 15))

    # Dual whirlwind blade cyclone
    wh = fx_whirl.rotate(-c * 60, resample=Image.BILINEAR).resize((150, 150))
    cell.alpha_composite(wh, (cx - 75, cy - 90))

    sheet.alpha_composite(cell, (c * CW, CH))
    frames_dict["skill_q_whirlwind"].append(cell)

# =========================================================================
# ROW 2: Skill [E] - Void Lance Piercing Thrust
# =========================================================================
print("Rendering Row 2: Knight Void Lance Skill...")
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 30
    draw_shadow(cell, cx, cy, width=75)

    if c == 0:
        # Low crouch dash prep
        k = get_knight_scaled(1.9, flip_h=False, angle=-20)
        cell.alpha_composite(k, (cx - k.width // 2 - 25, cy - k.height + 22))
        ln = fx_lance.resize((65, 22), Image.BILINEAR).rotate(10)
        cell.alpha_composite(ln, (cx - 10, cy - 65))
    elif c == 1:
        # Fast blur dash forward
        k = get_knight_scaled(2.0, flip_h=False, angle=15)
        cell.alpha_composite(k, (cx - k.width // 2 - 10, cy - k.height + 18))
        ln = fx_lance.resize((95, 26), Image.BILINEAR)
        cell.alpha_composite(ln, (cx + 5, cy - 62))
    elif c == 2:
        # Full deep piercing lunge with glowing void laser beam
        k = get_knight_scaled(2.1, flip_h=False, angle=25)
        cell.alpha_composite(k, (cx - k.width // 2, cy - k.height + 15))
        ln = fx_lance.resize((135, 36), Image.BILINEAR)
        cell.alpha_composite(ln, (cx + 10, cy - 66))
    elif c == 3:
        # Critical piercing impact with radiant burst
        k = get_knight_scaled(2.1, flip_h=False, angle=20)
        cell.alpha_composite(k, (cx - k.width // 2 + 10, cy - k.height + 15))
        ln = fx_lance.resize((125, 32), Image.BILINEAR)
        cell.alpha_composite(ln, (cx + 5, cy - 64))
        spk = fx_spark.resize((70, 70), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 55, cy - 78))
    elif c == 4:
        # Shockwave burst dissipation
        k = get_knight_scaled(2.0, flip_h=False, angle=10)
        cell.alpha_composite(k, (cx - k.width // 2 + 15, cy - k.height + 15))
        spk = fx_spark.resize((50, 50), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 65, cy - 70))
    elif c == 5:
        # Sliding recovery back into guard stance
        k = get_knight_scaled(2.0, flip_h=False, angle=0)
        cell.alpha_composite(k, (cx - k.width // 2 + 5, cy - k.height + 15))

    sheet.alpha_composite(cell, (c * CW, 2 * CH))
    frames_dict["skill_e_lance"].append(cell)

# =========================================================================
# ROW 3: Skill [R] - Celestial Sword Divine Ultimate
# =========================================================================
print("Rendering Row 3: Knight Celestial Ultimate...")
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 30
    draw_shadow(cell, cx, cy, width=70)

    if c == 0:
        # Invocation: Knight plants sword into ground, invoking light
        k = get_knight_scaled(2.0, flip_h=False, angle=-5)
        cell.alpha_composite(k, (cx - k.width // 2, cy - k.height + 15))
        sg = fx_sigil.resize((95, 45), Image.BILINEAR)
        cell.alpha_composite(sg, (cx - 48, cy - 25))
    elif c == 1:
        # Holy light ascension: Runic circle glows brightly under feet
        k = get_knight_scaled(2.05, flip_h=False, angle=0)
        cell.alpha_composite(k, (cx - k.width // 2, cy - k.height + 12))
        sg = fx_sigil.resize((120, 55), Image.BILINEAR)
        cell.alpha_composite(sg, (cx - 60, cy - 30))
        spk = fx_spark.resize((45, 45), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 20, cy - 110))
    elif c == 2:
        # Giant Divine Greatsword descends from heavens
        k = get_knight_scaled(2.0, flip_h=False, angle=5)
        cell.alpha_composite(k, (cx - k.width // 2 - 15, cy - k.height + 15))
        sw = fx_celestial.resize((110, 110), Image.BILINEAR).rotate(180)
        cell.alpha_composite(sw, (cx - 20, cy - 145))
    elif c == 3:
        # Celestial Greatsword strikes earth
        k = get_knight_scaled(2.05, flip_h=False, angle=10)
        cell.alpha_composite(k, (cx - k.width // 2 - 25, cy - k.height + 15))
        sw = fx_celestial.resize((130, 130), Image.BILINEAR).rotate(180)
        cell.alpha_composite(sw, (cx + 5, cy - 105))
        spk = fx_spark.resize((65, 65), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 5, cy - 40))
    elif c == 4:
        # Tremendous crater explosion and golden shockwave burst
        k = get_knight_scaled(2.1, flip_h=False, angle=15)
        cell.alpha_composite(k, (cx - k.width // 2 - 30, cy - k.height + 15))
        crt = fx_crater.resize((130, 55), Image.BILINEAR)
        cell.alpha_composite(crt, (cx - 30, cy - 25))
        spk = fx_spark.resize((90, 90), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 15, cy - 65))
    elif c == 5:
        # Victorious post-cast stance with fluttering crimson cape
        k = get_knight_scaled(2.0, flip_h=False, angle=0)
        cell.alpha_composite(k, (cx - k.width // 2, cy - k.height + 15))
        spk = fx_spark.resize((40, 40), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 30, cy - 80))

    sheet.alpha_composite(cell, (c * CW, 3 * CH))
    frames_dict["skill_r_celestial"].append(cell)

# Save master spritesheet
sheet.save(OUTPUT_SHEET)
print(f"Master Knight skill spritesheet saved to {OUTPUT_SHEET}")

# Save individual transparent animation frames
for anim_name, frames in frames_dict.items():
    for idx, f in enumerate(frames):
        fn = os.path.join(ANIM_DIR, f"{anim_name}_{idx}.png")
        f.save(fn)

print(f"Saved 24 transparent animation frames into {ANIM_DIR}")
