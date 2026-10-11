import os
from PIL import Image, ImageDraw

ICONS_DIR = r"d:\QVVC\assets\icons"
os.makedirs(ICONS_DIR, exist_ok=True)
SIZE = 48

def create_base():
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

# 1. mat_dust (Void Dust)
def draw_mat_dust():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Swirling nebula dust clouds
    clouds = [
        (24, 24, 14, (120, 40, 180, 220)),
        (22, 20, 10, (180, 70, 240, 240)),
        (27, 26, 9, (90, 20, 140, 200)),
        (18, 28, 7, (150, 50, 210, 190)),
        (30, 18, 6, (210, 120, 255, 230)),
    ]
    for cx, cy, r, col in clouds:
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
    # Sparkles
    sparkles = [(24, 22), (20, 16), (28, 28), (16, 24), (32, 22), (22, 30)]
    for sx, sy in sparkles:
        draw.point((sx, sy), fill=(255, 255, 255, 255))
        draw.point((sx+1, sy), fill=(220, 200, 255, 200))
        draw.point((sx, sy+1), fill=(220, 200, 255, 200))
    im.save(os.path.join(ICONS_DIR, "mat_dust.png"))

# 2. mat_gem (Spirit Gem)
def draw_mat_gem():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Faceted cyan gem
    poly_outer = [(24, 8), (38, 20), (32, 38), (16, 38), (10, 20)]
    draw.polygon(poly_outer, fill=(20, 120, 180, 255), outline=(10, 60, 100, 255))
    poly_inner = [(24, 12), (34, 21), (29, 34), (19, 34), (14, 21)]
    draw.polygon(poly_inner, fill=(50, 200, 240, 255))
    # Top highlight facet
    draw.polygon([(24, 12), (24, 24), (14, 21)], fill=(120, 235, 255, 255))
    draw.polygon([(24, 12), (34, 21), (24, 24)], fill=(180, 250, 255, 255))
    # Center gleam
    draw.line([(24, 12), (24, 34)], fill=(220, 255, 255, 200), width=1)
    im.save(os.path.join(ICONS_DIR, "mat_gem.png"))

# 3. mat_stone (Enhance Stone)
def draw_mat_stone():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Runic bloodstone
    poly = [(14, 10), (34, 10), (40, 24), (32, 40), (16, 40), (8, 24)]
    draw.polygon(poly, fill=(160, 30, 45, 255), outline=(70, 10, 20, 255))
    poly_in = [(17, 13), (31, 13), (36, 24), (29, 37), (19, 37), (12, 24)]
    draw.polygon(poly_in, fill=(220, 50, 70, 255))
    # Glowing rune mark in center
    draw.line([(24, 17), (24, 33)], fill=(255, 230, 180, 255), width=2)
    draw.line([(19, 21), (29, 29)], fill=(255, 230, 180, 255), width=2)
    draw.line([(29, 21), (19, 29)], fill=(255, 230, 180, 255), width=2)
    im.save(os.path.join(ICONS_DIR, "mat_stone.png"))

# 4. mat_shard (Eternal Shard)
def draw_mat_shard():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Prismatic radiant shard
    poly1 = [(24, 6), (32, 22), (24, 42), (18, 24)]
    draw.polygon(poly1, fill=(255, 215, 60, 255), outline=(120, 90, 20, 255))
    poly2 = [(24, 6), (24, 42), (18, 24)]
    draw.polygon(poly2, fill=(255, 245, 160, 255))
    poly3 = [(24, 6), (36, 16), (30, 28)]
    draw.polygon(poly3, fill=(255, 170, 20, 255))
    # Glowing stars
    draw.point((14, 14), fill=(255, 255, 220, 255))
    draw.point((34, 34), fill=(255, 255, 220, 255))
    im.save(os.path.join(ICONS_DIR, "mat_shard.png"))

# 5. wpn_sword_1 (Steel Dagger)
def draw_wpn_1():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Blade diagonally
    draw.line([(38, 10), (22, 26)], fill=(210, 220, 230, 255), width=4)
    draw.line([(38, 10), (23, 25)], fill=(255, 255, 255, 255), width=2)
    # Tip
    draw.polygon([(40, 8), (36, 8), (40, 12)], fill=(255, 255, 255, 255))
    # Crossguard
    draw.line([(18, 22), (26, 30)], fill=(180, 140, 60, 255), width=3)
    # Hilt & Pommel
    draw.line([(20, 28), (14, 34)], fill=(90, 50, 30, 255), width=3)
    draw.ellipse([10, 34, 14, 38], fill=(200, 160, 70, 255))
    im.save(os.path.join(ICONS_DIR, "wpn_sword_1.png"))

# 6. wpn_sword_2 (Blood Crescent)
def draw_wpn_2():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Curved crimson blade
    draw.arc([14, 6, 42, 34], start=220, end=380, fill=(220, 30, 60, 255), width=5)
    draw.arc([16, 8, 40, 32], start=230, end=370, fill=(255, 120, 140, 255), width=2)
    # Handle
    draw.line([(16, 26), (10, 36)], fill=(40, 15, 20, 255), width=3)
    draw.ellipse([8, 36, 12, 40], fill=(160, 20, 40, 255))
    im.save(os.path.join(ICONS_DIR, "wpn_sword_2.png"))

# 7. wpn_sword_3 (Thunder Blade)
def draw_wpn_3():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Jagged lightning blade
    pts = [(38, 8), (32, 14), (35, 17), (27, 23), (30, 25), (20, 31)]
    for i in range(len(pts) - 1):
        draw.line([pts[i], pts[i+1]], fill=(255, 235, 80, 255), width=4)
        draw.line([pts[i], pts[i+1]], fill=(255, 255, 220, 255), width=2)
    # Guard & Hilt
    draw.line([(16, 27), (24, 35)], fill=(60, 140, 220, 255), width=3)
    draw.line([(18, 33), (12, 39)], fill=(20, 50, 100, 255), width=3)
    draw.ellipse([9, 39, 13, 43], fill=(255, 230, 70, 255))
    im.save(os.path.join(ICONS_DIR, "wpn_sword_3.png"))

# 8. wpn_sword_4 (Void Cleaver)
def draw_wpn_4():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Heavy greatsword
    draw.polygon([(36, 6), (42, 12), (24, 30), (18, 24)], fill=(40, 20, 60, 255), outline=(160, 50, 220, 255))
    draw.line([(34, 10), (22, 22)], fill=(190, 80, 255, 255), width=2)
    draw.line([(15, 22), (25, 32)], fill=(120, 30, 170, 255), width=4)
    draw.line([(18, 29), (12, 37)], fill=(30, 10, 40, 255), width=3)
    draw.ellipse([9, 37, 13, 41], fill=(180, 60, 240, 255))
    im.save(os.path.join(ICONS_DIR, "wpn_sword_4.png"))

# 9. wpn_sword_5 (Star Destroyer)
def draw_wpn_5():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Cosmic double-edged blade glowing white-gold
    draw.line([(40, 8), (22, 26)], fill=(255, 245, 190, 255), width=5)
    draw.line([(40, 8), (22, 26)], fill=(255, 255, 255, 255), width=2)
    # Radiant aura
    draw.arc([30, 2, 46, 18], 0, 360, fill=(255, 215, 50, 200), width=1)
    # Winged guard
    draw.polygon([(16, 21), (25, 30), (21, 33), (12, 24)], fill=(255, 200, 60, 255))
    draw.line([(17, 30), (11, 38)], fill=(80, 40, 110, 255), width=3)
    draw.ellipse([8, 38, 12, 42], fill=(255, 230, 100, 255))
    im.save(os.path.join(ICONS_DIR, "wpn_sword_5.png"))

# 10. Chests (Wood, Silver, Gold, Mythic)
def draw_chest(name, body_col, border_col, lock_col):
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Chest base
    draw.rectangle([10, 20, 38, 38], fill=body_col, outline=border_col, width=2)
    # Lid
    draw.polygon([(8, 20), (14, 12), (34, 12), (40, 20)], fill=body_col, outline=border_col)
    # Metal bands
    draw.line([(18, 13), (18, 38)], fill=border_col, width=2)
    draw.line([(30, 13), (30, 38)], fill=border_col, width=2)
    # Center lock / gem
    draw.ellipse([21, 23, 27, 29], fill=lock_col)
    im.save(os.path.join(ICONS_DIR, f"{name}.png"))

# 11. Anvil and Bag Icons
def draw_anvil():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Horn and top plate
    draw.polygon([(6, 16), (42, 16), (36, 24), (20, 24), (10, 20)], fill=(120, 130, 145, 255), outline=(50, 55, 65, 255))
    # Waist
    draw.rectangle([18, 24, 30, 30], fill=(80, 90, 105, 255))
    # Base feet
    draw.polygon([(12, 38), (36, 38), (32, 30), (16, 30)], fill=(100, 110, 125, 255), outline=(50, 55, 65, 255))
    # Glowing hammer spark
    draw.line([(28, 10), (34, 14)], fill=(255, 220, 80, 255), width=2)
    draw.point((30, 15), fill=(255, 255, 255, 255))
    im.save(os.path.join(ICONS_DIR, "icon_forge.png"))

def draw_bag():
    im = create_base()
    draw = ImageDraw.Draw(im)
    # Satchel pouch
    draw.polygon([(12, 16), (36, 16), (38, 38), (10, 38)], fill=(140, 85, 45, 255), outline=(65, 35, 15, 255), width=2)
    # Flap
    draw.polygon([(10, 16), (38, 16), (34, 28), (14, 28)], fill=(175, 110, 60, 255), outline=(65, 35, 15, 255))
    # Buckle
    draw.rectangle([21, 25, 27, 31], fill=(220, 180, 60, 255), outline=(100, 75, 20, 255))
    im.save(os.path.join(ICONS_DIR, "icon_bag.png"))

if __name__ == "__main__":
    draw_mat_dust()
    draw_mat_gem()
    draw_mat_stone()
    draw_mat_shard()
    draw_wpn_1()
    draw_wpn_2()
    draw_wpn_3()
    draw_wpn_4()
    draw_wpn_5()
    draw_chest("chest_wood", (135, 80, 40, 255), (70, 40, 15, 255), (180, 150, 60, 255))
    draw_chest("chest_silver", (180, 195, 210, 255), (90, 105, 120, 255), (50, 160, 240, 255))
    draw_chest("chest_gold", (230, 180, 40, 255), (140, 100, 15, 255), (220, 40, 50, 255))
    draw_chest("chest_mythic", (120, 40, 180, 255), (240, 190, 60, 255), (255, 230, 120, 255))
    draw_anvil()
    draw_bag()
    print("All pixel icons generated successfully!")
