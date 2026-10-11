import os, sys
from PIL import Image

def process_spritesheet(input_path, output_dir=r"d:\QVVC\assets\player_anim"):
    os.makedirs(output_dir, exist_ok=True)
    im = Image.open(input_path).convert("RGBA")
    w, h = im.size
    cols = 6
    rows = 4
    fw = w // cols
    fh = h // rows

    print(f"Sprite sheet size: {w}x{h}, Frame size: {fw}x{fh}")

    anim_names = ["attack_combo", "skill_q_whirlwind", "skill_e_lance", "skill_r_celestial"]
    created_files = {}

    for row in range(rows):
        anim_name = anim_names[row]
        created_files[anim_name] = []
        for col in range(cols):
            box = (col * fw, row * fh, (col + 1) * fw, (row + 1) * fh)
            frame = im.crop(box)

            # Auto remove pure white background if needed
            datas = frame.getdata()
            new_data = []
            for item in datas:
                # If pixel is near white, make it transparent
                if item[0] > 240 and item[1] > 240 and item[2] > 240:
                    new_data.append((255, 255, 255, 0))
                else:
                    new_data.append(item)
            frame.putdata(new_data)

            frame_file = os.path.join(output_dir, f"{anim_name}_{col}.png")
            frame.save(frame_file)
            created_files[anim_name].append(frame_file)

    print(f"Da cat thanh cong 24 frames vao {output_dir}")
    return created_files

if __name__ == "__main__":
    target = r"d:\QVVC\assets\player_skills_spritesheet.png"
    if len(sys.argv) > 1:
        target = sys.argv[1]
    if os.path.exists(target):
        process_spritesheet(target)
    else:
        print(f"Chua tim thay file {target}")
