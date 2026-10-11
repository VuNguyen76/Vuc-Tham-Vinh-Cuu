import os, math
from PIL import Image, ImageDraw, ImageEnhance

REF_PATH = r"C:\Users\Admin\.gemini\antigravity\brain\d732af13-5821-4892-a1fc-832fb1bf5365\.user_uploaded\media_1791686131799_09b65659.png"
OUTPUT_SHEET = r"d:\QVVC\assets\player_skills_spritesheet.png"
ANIM_DIR = r"d:\QVVC\assets\player_anim"
os.makedirs(ANIM_DIR, exist_ok=True)

# 1. Load reference sheet and extract characters
ref_img = Image.open(REF_PATH).convert("RGBA")

# Bounding boxes detected earlier
row_bboxes = [
    (66, 235, [(43, 140), (211, 308), (379, 476), (547, 645), (715, 813), (884, 981)]), # front
    (254, 420, [(43, 140), (211, 308), (379, 477), (547, 645), (716, 813), (884, 981)]), # back
    (438, 588, [(55, 136), (231, 313), (396, 477), (543, 625), (711, 793), (891, 973)]), # side
    (606, 752, [(55, 137), (231, 313), (399, 485), (543, 625), (712, 793), (896, 977)])  # diagonal
]

def extract_char(r_idx, c_idx):
    y1, y2, cols = row_bboxes[r_idx]
    x1, x2 = cols[c_idx]
    cropped = ref_img.crop((x1, y1, x2, y2))
    # Make white background transparent
    data = cropped.getdata()
    new_data = []
    for p in data:
        if p[0] > 235 and p[1] > 235 and p[2] > 235:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(p)
    cropped.putdata(new_data)
    return cropped

# Load FX textures
fx_sword = Image.open(r"d:\QVVC\assets\icons\wpn_sword_1.png").convert("RGBA").resize((64, 64), Image.NEAREST)
fx_slash1 = Image.open(r"d:\QVVC\assets\fx\slash_arc_1.png").convert("RGBA")
fx_slash2 = Image.open(r"d:\QVVC\assets\fx\slash_arc_2.png").convert("RGBA")
fx_slash_heavy = Image.open(r"d:\QVVC\assets\fx\slash_heavy.png").convert("RGBA")
fx_whirl = Image.open(r"d:\QVVC\assets\fx\fx_whirlwind.png").convert("RGBA")
fx_lance = Image.open(r"d:\QVVC\assets\fx\fx_void_lance.png").convert("RGBA")
fx_celestial = Image.open(r"d:\QVVC\assets\fx\fx_celestial_sword.png").convert("RGBA")
fx_sigil = Image.open(r"d:\QVVC\assets\fx\fx_magic_sigil.png").convert("RGBA")
fx_spark = Image.open(r"d:\QVVC\assets\fx\fx_hit_spark.png").convert("RGBA")
fx_crater = Image.open(r"d:\QVVC\assets\fx\fx_crater.png").convert("RGBA")

# Build target 1024x768 sheet (4 rows x 6 cols, cell 170x192)
CW, CH = 170, 192
sheet = Image.new("RGBA", (1024, 768), (255, 255, 255, 255)) # clean white canvas

def draw_shadow(canvas, cx, cy):
    # draw soft dark ellipse shadow
    shadow = Image.new("RGBA", (60, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    d.ellipse([4, 4, 56, 20], fill=(80, 80, 80, 120))
    canvas.alpha_composite(shadow, (cx - 30, cy - 10))

# Store individual frames for Godot
frames_dict = {
    "attack_combo": [],
    "skill_q_whirlwind": [],
    "skill_e_lance": [],
    "skill_r_celestial": []
}

# =========================================================================
# ROW 0: 3-Hit Sword Attack Combo (Slash 1, Slash 2, Heavy Slash)
# =========================================================================
print("Rendering Row 0: Attack Combo...")
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 25
    draw_shadow(cell, cx, cy)

    if c == 0:
        # Windup: Character prepares sword back
        ch = extract_char(2, 0)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))
        sw = fx_sword.rotate(-45, expand=True)
        cell.alpha_composite(sw, (cx - 45, cy - 80))
    elif c == 1:
        # Slash 1: Quick swing forward with cyan arc
        ch = extract_char(2, 3)
        cell.alpha_composite(ch, (cx - ch.width//2 + 5, cy - ch.height + 10))
        s1 = fx_slash1.resize((110, 110), Image.BILINEAR)
        cell.alpha_composite(s1, (cx - 10, cy - 90))
    elif c == 2:
        # Transition: Recovery into backswing
        ch = extract_char(3, 1)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))
        sw = fx_sword.rotate(30, expand=True)
        cell.alpha_composite(sw, (cx - 20, cy - 95))
    elif c == 3:
        # Slash 2: Reverse upward slash with amethyst violet arc
        ch = extract_char(2, 4)
        cell.alpha_composite(ch, (cx - ch.width//2 + 10, cy - ch.height + 10))
        s2 = fx_slash2.resize((120, 120), Image.BILINEAR)
        cell.alpha_composite(s2, (cx - 15, cy - 110))
        spk = fx_spark.resize((50, 50), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 35, cy - 70))
    elif c == 4:
        # Leap / Windup for heavy attack
        ch = extract_char(0, 4)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height - 15))
        sw = fx_sword.rotate(-110, expand=True).resize((80, 80))
        cell.alpha_composite(sw, (cx - 40, cy - 140))
    elif c == 5:
        # Heavy Cleave: Downward slam with golden flame arc and sparks
        ch = extract_char(0, 5)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))
        sh = fx_slash_heavy.resize((130, 130), Image.BILINEAR)
        cell.alpha_composite(sh, (cx - 65, cy - 100))
        spk = fx_spark.resize((65, 65), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 10, cy - 35))

    sheet.alpha_composite(cell, (c * CW, 0))
    frames_dict["attack_combo"].append(cell)

# =========================================================================
# ROW 1: Skill [Q] - Whirlwind Blade Spin (6 frames of 360 rotation)
# =========================================================================
print("Rendering Row 1: Whirlwind Skill...")
rot_chars = [
    (0, 0),  # 0 deg (front)
    (3, 2),  # 60 deg (diagonal front)
    (2, 2),  # 120 deg (side)
    (1, 0),  # 180 deg (back)
    (2, 3),  # 240 deg (side reverse)
    (3, 4)   # 300 deg (diagonal reverse)
]
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 25
    draw_shadow(cell, cx, cy)

    r_idx, c_idx = rot_chars[c]
    ch = extract_char(r_idx, c_idx)
    cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))

    # Cyclone whirlwind blade trail
    wh = fx_whirl.rotate(-c * 60, expand=False).resize((140, 140), Image.BILINEAR)
    cell.alpha_composite(wh, (cx - 70, cy - 85))

    sheet.alpha_composite(cell, (c * CW, CH))
    frames_dict["skill_q_whirlwind"].append(cell)

# =========================================================================
# ROW 2: Skill [E] - Void Lance Piercing Thrust
# =========================================================================
print("Rendering Row 2: Void Lance Skill...")
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 25
    draw_shadow(cell, cx, cy)

    if c == 0:
        # Crouch ready stance
        ch = extract_char(2, 0)
        cell.alpha_composite(ch, (cx - ch.width//2 - 20, cy - ch.height + 15))
        ln = fx_lance.resize((60, 20), Image.BILINEAR).rotate(10)
        cell.alpha_composite(ln, (cx - 10, cy - 65))
    elif c == 1:
        # Rapid dash forward
        ch = extract_char(2, 3)
        cell.alpha_composite(ch, (cx - ch.width//2 - 10, cy - ch.height + 10))
        ln = fx_lance.resize((90, 25), Image.BILINEAR)
        cell.alpha_composite(ln, (cx + 5, cy - 60))
    elif c == 2:
        # Full thrust extension with piercing lance beam
        ch = extract_char(2, 4)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))
        ln = fx_lance.resize((130, 35), Image.BILINEAR)
        cell.alpha_composite(ln, (cx + 10, cy - 65))
    elif c == 3:
        # Critical piercing impact with radiant burst
        ch = extract_char(2, 5)
        cell.alpha_composite(ch, (cx - ch.width//2 + 5, cy - ch.height + 10))
        ln = fx_lance.resize((120, 30), Image.BILINEAR)
        cell.alpha_composite(ln, (cx + 5, cy - 63))
        spk = fx_spark.resize((65, 65), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 50, cy - 75))
    elif c == 4:
        # Piercing shockwave dissipation
        ch = extract_char(2, 5)
        cell.alpha_composite(ch, (cx - ch.width//2 + 10, cy - ch.height + 10))
        spk = fx_spark.resize((45, 45), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 60, cy - 65))
    elif c == 5:
        # Slide back to combat ready
        ch = extract_char(2, 1)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))

    sheet.alpha_composite(cell, (c * CW, 2 * CH))
    frames_dict["skill_e_lance"].append(cell)

# =========================================================================
# ROW 3: Skill [R] - Celestial Sword Divine Ultimate
# =========================================================================
print("Rendering Row 3: Celestial Sword Ultimate...")
for c in range(6):
    cell = Image.new("RGBA", (CW, CH), (255, 255, 255, 0))
    cx, cy = CW // 2, CH - 25
    draw_shadow(cell, cx, cy)

    if c == 0:
        # Invoke: Character raises hands
        ch = extract_char(0, 0)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))
        sg = fx_sigil.resize((90, 45), Image.BILINEAR)
        cell.alpha_composite(sg, (cx - 45, cy - 25))
    elif c == 1:
        # Holy light ascension
        ch = extract_char(0, 1)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 5))
        sg = fx_sigil.resize((110, 55), Image.BILINEAR)
        cell.alpha_composite(sg, (cx - 55, cy - 30))
        spk = fx_spark.resize((40, 40), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 20, cy - 110))
    elif c == 2:
        # Giant Divine Celestial Greatsword descends from heavens
        ch = extract_char(0, 2)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))
        sw = fx_celestial.resize((100, 100), Image.BILINEAR).rotate(180)
        cell.alpha_composite(sw, (cx - 50, cy - 140))
    elif c == 3:
        # Sword plunges into earth
        ch = extract_char(0, 3)
        cell.alpha_composite(ch, (cx - ch.width//2 - 20, cy - ch.height + 10))
        sw = fx_celestial.resize((120, 120), Image.BILINEAR).rotate(180)
        cell.alpha_composite(sw, (cx - 10, cy - 100))
        spk = fx_spark.resize((60, 60), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 15, cy - 40))
    elif c == 4:
        # Tremendous crater explosion and golden shockwave
        ch = extract_char(0, 4)
        cell.alpha_composite(ch, (cx - ch.width//2 - 25, cy - ch.height + 10))
        crt = fx_crater.resize((120, 50), Image.BILINEAR)
        cell.alpha_composite(crt, (cx - 40, cy - 25))
        spk = fx_spark.resize((80, 80), Image.BILINEAR)
        cell.alpha_composite(spk, (cx + 5, cy - 65))
    elif c == 5:
        # Post-cast stance amid holy embers
        ch = extract_char(0, 0)
        cell.alpha_composite(ch, (cx - ch.width//2, cy - ch.height + 10))
        spk = fx_spark.resize((35, 35), Image.BILINEAR)
        cell.alpha_composite(spk, (cx - 35, cy - 70))

    sheet.alpha_composite(cell, (c * CW, 3 * CH))
    frames_dict["skill_r_celestial"].append(cell)

# Save master spritesheet
sheet.save(OUTPUT_SHEET)
print(f"Master skill spritesheet saved to {OUTPUT_SHEET}")

# Save individual transparent animation frames
for anim_name, frames in frames_dict.items():
    for idx, f in enumerate(frames):
        fn = os.path.join(ANIM_DIR, f"{anim_name}_{idx}.png")
        f.save(fn)

print(f"Saved 24 transparent animation frames into {ANIM_DIR}")
