import os
from PIL import Image, ImageDraw

ICONS_DIR = r"d:\QVVC\assets\icons"
UI_DIR = r"d:\QVVC\assets\ui"

os.makedirs(ICONS_DIR, exist_ok=True)
os.makedirs(UI_DIR, exist_ok=True)

# 1. Generate bar_player_mp.png (220 x 18)
def create_mp_bar():
    w, h = 220, 18
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Blue / Cyan gradient with highlights
    for y in range(h):
        ratio = y / float(h - 1)
        if y == 0:
            r, g, b = 160, 230, 255 # Top edge highlight
        elif y == 1:
            r, g, b = 100, 200, 255
        elif y == 2:
            r, g, b = 230, 250, 255 # Gloss line
        elif y < 8:
            r = int(40 + (1.0 - ratio) * 40)
            g = int(140 + (1.0 - ratio) * 50)
            b = 255
        else:
            r = int(15 + (1.0 - ratio) * 25)
            g = int(80 + (1.0 - ratio) * 50)
            b = int(180 + (1.0 - ratio) * 60)
        draw.line([(0, y), (w - 1, y)], fill=(r, g, b, 255))

    out_path = os.path.join(UI_DIR, "bar_player_mp.png")
    im.save(out_path)
    print(f"Created {out_path}")

# Helper for 48x48 icon base
def new_icon():
    return Image.new("RGBA", (48, 48), (0, 0, 0, 0))

# 2. Armors
def create_armors():
    # 2a. arm_leather_1 (Tier Common)
    im = new_icon()
    d = ImageDraw.Draw(im)
    # Brown leather vest with collar
    d.polygon([(16, 8), (31, 8), (38, 14), (36, 40), (11, 40), (9, 14)], fill=(120, 75, 45, 255), outline=(60, 35, 20, 255))
    d.polygon([(18, 12), (29, 12), (34, 16), (33, 38), (14, 38), (13, 16)], fill=(155, 100, 60, 255))
    # Straps and buckle
    d.line([(12, 26), (35, 26)], fill=(50, 30, 15, 255), width=2)
    d.rectangle([21, 24, 26, 28], fill=(210, 180, 80, 255), outline=(130, 100, 40, 255))
    im.save(os.path.join(ICONS_DIR, "arm_leather_1.png"))

    # 2b. arm_plate_2 (Tier Uncommon - Iron/Steel)
    im = new_icon()
    d = ImageDraw.Draw(im)
    # Heavy steel breastplate
    d.polygon([(15, 6), (32, 6), (42, 14), (38, 42), (9, 42), (5, 14)], fill=(140, 150, 165, 255), outline=(50, 60, 75, 255))
    d.polygon([(18, 10), (29, 10), (37, 16), (34, 39), (13, 39), (10, 16)], fill=(195, 205, 220, 255))
    # Central ridge and gold crest
    d.line([(23, 12), (23, 38)], fill=(110, 120, 135, 255), width=2)
    d.polygon([(20, 16), (26, 16), (23, 23)], fill=(70, 150, 230, 255), outline=(40, 90, 160, 255))
    im.save(os.path.join(ICONS_DIR, "arm_plate_2.png"))

    # 2c. arm_dragon_3 (Tier Epic - Crimson Dragonscale)
    im = new_icon()
    d = ImageDraw.Draw(im)
    # Dragon scale plates
    d.polygon([(14, 5), (33, 5), (43, 13), (39, 43), (8, 43), (4, 13)], fill=(175, 30, 40, 255), outline=(75, 10, 15, 255))
    d.polygon([(17, 9), (30, 9), (38, 15), (35, 40), (12, 40), (9, 15)], fill=(225, 55, 65, 255))
    # Golden wing pauldrons and central core
    d.polygon([(4, 13), (12, 7), (14, 20)], fill=(240, 190, 50, 255), outline=(140, 100, 20, 255))
    d.polygon([(43, 13), (35, 7), (33, 20)], fill=(240, 190, 50, 255), outline=(140, 100, 20, 255))
    d.ellipse([19, 20, 28, 29], fill=(255, 220, 100, 255), outline=(180, 120, 20, 255))
    im.save(os.path.join(ICONS_DIR, "arm_dragon_3.png"))

    # 2d. arm_void_4 (Tier Mythic - Obsidian Void)
    im = new_icon()
    d = ImageDraw.Draw(im)
    # Dark void armor with glowing purple runes
    d.polygon([(13, 4), (34, 4), (45, 12), (40, 44), (7, 44), (2, 12)], fill=(35, 25, 50, 255), outline=(15, 10, 25, 255))
    d.polygon([(16, 8), (31, 8), (39, 14), (36, 41), (11, 41), (8, 14)], fill=(65, 45, 95, 255))
    # Glowing violet rune crest
    d.polygon([(23, 12), (29, 24), (23, 36), (17, 24)], fill=(200, 70, 255, 255), outline=(240, 160, 255, 255))
    d.ellipse([21, 22, 25, 26], fill=(255, 220, 255, 255))
    im.save(os.path.join(ICONS_DIR, "arm_void_4.png"))
    print("Created armors.")

# 3. Rings / Accessories
def create_rings():
    # 3a. ring_copper_1
    im = new_icon()
    d = ImageDraw.Draw(im)
    d.ellipse([10, 10, 37, 37], fill=None, outline=(175, 100, 50, 255), width=5)
    d.ellipse([12, 12, 35, 35], fill=None, outline=(220, 140, 75, 255), width=2)
    d.ellipse([20, 7, 27, 14], fill=(235, 175, 90, 255), outline=(120, 60, 25, 255))
    im.save(os.path.join(ICONS_DIR, "ring_copper_1.png"))

    # 3b. ring_silver_2
    im = new_icon()
    d = ImageDraw.Draw(im)
    d.ellipse([10, 10, 37, 37], fill=None, outline=(120, 135, 155, 255), width=5)
    d.ellipse([12, 12, 35, 35], fill=None, outline=(200, 215, 235, 255), width=2)
    # Sapphire gem
    d.polygon([(23, 5), (30, 12), (23, 19), (16, 12)], fill=(40, 160, 255, 255), outline=(15, 80, 160, 255))
    d.ellipse([21, 10, 25, 14], fill=(180, 230, 255, 255))
    im.save(os.path.join(ICONS_DIR, "ring_silver_2.png"))

    # 3c. ring_ruby_3
    im = new_icon()
    d = ImageDraw.Draw(im)
    d.ellipse([10, 10, 37, 37], fill=None, outline=(180, 130, 30, 255), width=5)
    d.ellipse([12, 12, 35, 35], fill=None, outline=(255, 205, 60, 255), width=2)
    # Radiant Ruby gem
    d.polygon([(23, 4), (32, 13), (23, 22), (14, 13)], fill=(235, 25, 65, 255), outline=(120, 10, 30, 255))
    d.polygon([(23, 7), (29, 13), (23, 19), (17, 13)], fill=(255, 80, 120, 255))
    im.save(os.path.join(ICONS_DIR, "ring_ruby_3.png"))

    # 3d. ring_void_4
    im = new_icon()
    d = ImageDraw.Draw(im)
    # Obsidian ring with cosmic violet orb
    d.ellipse([9, 9, 38, 38], fill=None, outline=(40, 25, 60, 255), width=5)
    d.ellipse([11, 11, 36, 36], fill=None, outline=(110, 60, 160, 255), width=2)
    d.ellipse([15, 5, 32, 22], fill=(180, 50, 255, 255), outline=(240, 150, 255, 255))
    d.ellipse([20, 9, 27, 16], fill=(255, 220, 255, 255))
    im.save(os.path.join(ICONS_DIR, "ring_void_4.png"))
    print("Created rings.")

if __name__ == "__main__":
    create_mp_bar()
    create_armors()
    create_rings()
    print("Done generating gear & MP assets!")
