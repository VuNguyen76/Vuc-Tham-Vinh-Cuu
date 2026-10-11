import os
import math
from PIL import Image, ImageDraw, ImageFilter
import numpy as np

base_dir = r"d:\QVVC"
icons_dir = os.path.join(base_dir, "assets", "icons")
fx_dir = os.path.join(base_dir, "assets", "fx")
os.makedirs(icons_dir, exist_ok=True)
os.makedirs(fx_dir, exist_ok=True)

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
# 1. Skill Icon: [F] Divine Aegis / Thánh Khiên (48x48)
# -------------------------------------------------------------------------
def gen_skill_aegis():
    im = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw_radial_glow(draw, (24, 24), 22, (200, 160, 40, 255), (20, 16, 8, 255))
    # Golden border ring
    draw.ellipse([1, 1, 46, 46], outline=(255, 215, 60, 255), width=1)
    
    # Shield shape points
    shield_pts = [
        (12, 10), (36, 10), (38, 26), (24, 42), (10, 26)
    ]
    draw.polygon(shield_pts, fill=(240, 245, 255, 255), outline=(218, 165, 32, 255))
    
    # Inner shield plate
    inner_pts = [
        (15, 13), (33, 13), (35, 25), (24, 38), (13, 25)
    ]
    draw.polygon(inner_pts, fill=(40, 90, 180, 255), outline=(255, 235, 120, 255))
    
    # Holy Golden Cross
    draw.rectangle([21, 16, 27, 34], fill=(255, 215, 60, 255))
    draw.rectangle([16, 21, 32, 27], fill=(255, 215, 60, 255))
    draw.rectangle([22, 17, 26, 33], fill=(255, 255, 220, 255))
    draw.rectangle([17, 22, 31, 26], fill=(255, 255, 220, 255))
    
    # Holy radiance star at cross center
    draw.ellipse([22, 22, 26, 26], fill=(255, 255, 255, 255))
    
    im.save(os.path.join(icons_dir, "skill_f.png"))
    print("Generated skill_f.png")

# -------------------------------------------------------------------------
# 2. Skill Icon: [Space] Thunder Tempest / Lôi Phạt (48x48)
# -------------------------------------------------------------------------
def gen_skill_lightning():
    im = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw_radial_glow(draw, (24, 24), 22, (50, 140, 240, 255), (10, 15, 30, 255))
    # Electric border ring
    draw.ellipse([1, 1, 46, 46], outline=(100, 210, 255, 255), width=1)
    
    # Dark storm cloud top
    draw.ellipse([10, 8, 26, 20], fill=(50, 60, 80, 230))
    draw.ellipse([22, 6, 38, 18], fill=(60, 70, 95, 230))
    draw.ellipse([16, 12, 34, 22], fill=(40, 50, 70, 230))
    
    # Zigzag lightning bolts
    bolt1 = [(26, 12), (18, 24), (25, 24), (16, 42), (23, 27), (18, 27), (26, 12)]
    draw.polygon(bolt1, fill=(255, 255, 255, 255))
    
    # Glowing blue aura around bolt
    bolt2 = [(32, 16), (26, 26), (31, 26), (24, 39), (29, 28), (25, 28), (32, 16)]
    draw.polygon(bolt2, fill=(80, 220, 255, 255))
    
    # Electric sparks
    draw.line([12, 30, 15, 28], fill=(255, 240, 100, 255), width=2)
    draw.line([34, 32, 38, 35], fill=(255, 240, 100, 255), width=2)
    draw.line([28, 40, 31, 44], fill=(255, 255, 255, 255), width=2)
    
    im.save(os.path.join(icons_dir, "skill_space.png"))
    print("Generated skill_space.png")

# -------------------------------------------------------------------------
# 3. Visual FX: Holy Shield Dome (128x128)
# -------------------------------------------------------------------------
def gen_fx_holy_shield():
    im = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 64, 64
    # Radial holy gold translucent barrier
    for r in range(58, 42, -1):
        alpha = int(180 * ((r - 42) / 16.0))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 215, 60, alpha), width=1)
    
    # Core shield ring
    draw.ellipse([cx - 52, cy - 52, cx + 52, cy + 52], outline=(255, 250, 200, 240), width=3)
    draw.ellipse([cx - 48, cy - 48, cx + 48, cy + 48], outline=(255, 190, 40, 180), width=2)
    
    # 8 Runic nodes along perimeter
    for deg in range(0, 360, 45):
        rad = math.radians(deg)
        nx = cx + int(math.cos(rad) * 52)
        ny = cy + int(math.sin(rad) * 52)
        draw.ellipse([nx - 4, ny - 4, nx + 4, ny + 4], fill=(255, 255, 255, 255), outline=(255, 180, 30, 255))
        
    im.save(os.path.join(fx_dir, "fx_holy_shield.png"))
    print("Generated fx_holy_shield.png")

# -------------------------------------------------------------------------
# 4. Visual FX: Lightning Bolt (64x320)
# -------------------------------------------------------------------------
def gen_fx_lightning_bolt():
    w, h = 64, 320
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx = 32
    
    # Main jagged path
    pts = [
        (cx, 0),
        (cx - 8, 40),
        (cx + 10, 85),
        (cx - 12, 130),
        (cx + 8, 175),
        (cx - 6, 220),
        (cx + 12, 265),
        (cx, 320)
    ]
    
    # Outer glow
    for off in range(6, 0, -1):
        a = int(140 * (1.0 - off / 6.0))
        draw.line(pts, fill=(80, 180, 255, a), width=off * 2 + 2)
    
    # Core white strike
    draw.line(pts, fill=(255, 255, 255, 255), width=3)
    
    # Secondary branches
    branch1 = [(cx - 8, 40), (cx - 24, 80), (cx - 20, 110)]
    draw.line(branch1, fill=(120, 220, 255, 200), width=2)
    
    branch2 = [(cx + 8, 175), (cx + 26, 210), (cx + 20, 240)]
    draw.line(branch2, fill=(120, 220, 255, 200), width=2)
    
    # Ground impact burst
    draw.ellipse([cx - 22, h - 25, cx + 22, h], fill=(200, 240, 255, 220))
    draw.ellipse([cx - 14, h - 18, cx + 14, h], fill=(255, 255, 255, 255))
    
    im.save(os.path.join(fx_dir, "fx_lightning_bolt.png"))
    print("Generated fx_lightning_bolt.png")

# -------------------------------------------------------------------------
# 5. Visual FX: Summon Portal (96x96)
# -------------------------------------------------------------------------
def gen_fx_portal():
    w, h = 96, 96
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = 48, 48
    
    # Void purple swirl
    draw_radial_glow(draw, (cx, cy), 44, (160, 40, 230, 230), (20, 5, 40, 0))
    
    # Spiral arms
    for arm in range(3):
        base_a = arm * (2.0 * math.pi / 3.0)
        pts = []
        for r in range(8, 42, 3):
            theta = base_a + (r * 0.12)
            px = cx + math.cos(theta) * r
            py = cy + math.sin(theta) * (r * 0.55) # Elliptical for floor perspective
            pts.append((px, py))
        draw.line(pts, fill=(230, 120, 255, 220), width=2)
        
    # Dark singularity center
    draw.ellipse([cx - 16, cy - 8, cx + 16, cy + 8], fill=(10, 4, 18, 255), outline=(200, 90, 255, 240), width=2)
    
    im.save(os.path.join(fx_dir, "fx_portal.png"))
    print("Generated fx_portal.png")

if __name__ == "__main__":
    gen_skill_aegis()
    gen_skill_lightning()
    gen_fx_holy_shield()
    gen_fx_lightning_bolt()
    gen_fx_portal()
    print("All new skills and FX assets generated successfully!")
