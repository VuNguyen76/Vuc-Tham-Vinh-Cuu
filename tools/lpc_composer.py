import os
import sys
from PIL import Image

BASE_DIR = r"d:\QVVC"
LPC_ROOT = os.path.join(BASE_DIR, "tools", "lpc_generator", "spritesheets")
OUTPUT_BASE = os.path.join(BASE_DIR, "assets")

def resolve_path(rel_path):
    p = os.path.join(LPC_ROOT, rel_path.replace("/", os.sep))
    if os.path.exists(p):
        return p
    return None

def composite_layers(layer_paths, target_size=None):
    base_img = None
    for lp in layer_paths:
        full_p = resolve_path(lp)
        if not full_p:
            continue
        try:
            layer = Image.open(full_p).convert("RGBA")
            if base_img is None:
                base_img = layer.copy()
            else:
                if layer.size != base_img.size:
                    layer = layer.crop((0, 0, base_img.size[0], base_img.size[1]))
                base_img.alpha_composite(layer)
        except Exception as e:
            print(f"Error loading {full_p}: {e}")
    return base_img

# Character Presets Definitions
PRESETS = {
    "player_knight": {
        "output_dir": os.path.join(OUTPUT_BASE, "characters", "player_lpc"),
        "layers": {
            "walk": [
                "cape/solid/bg/walk.png",
                "body/bodies/male/walk.png",
                "legs/armour/plate/male/walk.png",
                "feet/armour/plate/male/walk.png",
                "torso/armour/plate/male/walk.png",
                "cape/solid/fg/walk.png",
                "hat/helmet/armet/adult/walk.png",
                "weapon/sword/arming/universal/fg/walk/steel.png",
            ],
            "slash": [
                "cape/solid/bg/slash.png",
                "body/bodies/male/slash.png",
                "legs/armour/plate/male/slash.png",
                "feet/armour/plate/male/slash.png",
                "torso/armour/plate/male/slash.png",
                "cape/solid/fg/slash.png",
                "hat/helmet/armet/adult/slash.png",
                "weapon/sword/arming/attack_slash/fg/steel.png",
            ],
            "thrust": [
                "cape/solid/bg/thrust.png",
                "body/bodies/male/thrust.png",
                "legs/armour/plate/male/thrust.png",
                "feet/armour/plate/male/thrust.png",
                "torso/armour/plate/male/thrust.png",
                "cape/solid/fg/thrust.png",
                "hat/helmet/armet/adult/thrust.png",
            ],
            "spellcast": [
                "cape/solid/bg/spellcast.png",
                "body/bodies/male/spellcast.png",
                "legs/armour/plate/male/spellcast.png",
                "feet/armour/plate/male/spellcast.png",
                "torso/armour/plate/male/spellcast.png",
                "cape/solid/fg/spellcast.png",
                "hat/helmet/armet/adult/spellcast.png",
            ],
            "hurt": [
                "body/bodies/male/hurt.png",
                "legs/armour/plate/male/hurt.png",
                "feet/armour/plate/male/hurt.png",
                "torso/armour/plate/male/hurt.png",
                "hat/helmet/armet/adult/hurt.png",
            ],
            "combat_idle": [
                "cape/solid/bg/combat_idle.png",
                "body/bodies/male/combat_idle.png",
                "legs/armour/plate/male/combat_idle.png",
                "feet/armour/plate/male/combat_idle.png",
                "torso/armour/plate/male/combat_idle.png",
                "cape/solid/fg/combat_idle.png",
                "hat/helmet/armet/adult/combat_idle.png",
                "weapon/sword/arming/universal/fg/combat_idle/steel.png",
            ],
        }
    },
    "monster_skeleton": {
        "output_dir": os.path.join(OUTPUT_BASE, "monsters", "skeleton"),
        "layers": {
            "walk": [
                "body/bodies/skeleton/walk.png",
                "head/heads/skeleton/adult/walk.png",
                "weapon/sword/arming/universal/fg/walk/iron.png",
            ],
            "slash": [
                "body/bodies/skeleton/slash.png",
                "head/heads/skeleton/adult/slash.png",
                "weapon/sword/arming/attack_slash/fg/iron.png",
            ],
            "thrust": [
                "body/bodies/skeleton/thrust.png",
                "head/heads/skeleton/adult/thrust.png",
            ],
            "hurt": [
                "body/bodies/skeleton/hurt.png",
                "head/heads/skeleton/adult/hurt.png",
            ],
            "combat_idle": [
                "body/bodies/skeleton/combat_idle.png",
                "head/heads/skeleton/adult/combat_idle.png",
                "weapon/sword/arming/universal/fg/combat_idle/iron.png",
            ],
        }
    },
    "monster_zombie": {
        "output_dir": os.path.join(OUTPUT_BASE, "monsters", "zombie"),
        "layers": {
            "walk": [
                "body/bodies/zombie/walk/zombie.png",
                "legs/pants/male/walk.png",
                "head/heads/zombie/adult/walk.png",
            ],
            "slash": [
                "body/bodies/zombie/slash/zombie.png",
                "legs/pants/male/slash.png",
                "head/heads/zombie/adult/slash.png",
            ],
            "thrust": [
                "body/bodies/zombie/thrust/zombie.png",
                "legs/pants/male/thrust.png",
                "head/heads/zombie/adult/thrust.png",
            ],
            "hurt": [
                "body/bodies/zombie/hurt/zombie.png",
                "legs/pants/male/hurt.png",
                "head/heads/zombie/adult/hurt.png",
            ],
            "combat_idle": [
                "body/bodies/zombie/walk/zombie.png",
                "legs/pants/male/combat_idle.png",
                "head/heads/zombie/adult/combat_idle.png",
            ],
        }
    },
    "monster_orc": {
        "output_dir": os.path.join(OUTPUT_BASE, "monsters", "orc"),
        "layers": {
            "walk": [
                "body/bodies/muscular/walk.png",
                "legs/pants/muscular/walk.png",
                "torso/armour/leather/male/walk.png",
                "head/heads/orc/male/walk.png",
                "weapon/sword/arming/universal/fg/walk/iron.png",
            ],
            "slash": [
                "body/bodies/muscular/slash.png",
                "legs/pants/muscular/slash.png",
                "torso/armour/leather/male/slash.png",
                "head/heads/orc/male/slash.png",
                "weapon/sword/arming/attack_slash/fg/iron.png",
            ],
            "thrust": [
                "body/bodies/muscular/thrust.png",
                "legs/pants/muscular/thrust.png",
                "torso/armour/leather/male/thrust.png",
                "head/heads/orc/male/thrust.png",
            ],
            "hurt": [
                "body/bodies/muscular/hurt.png",
                "legs/pants/muscular/hurt.png",
                "torso/armour/leather/male/hurt.png",
                "head/heads/orc/male/hurt.png",
            ],
            "combat_idle": [
                "body/bodies/muscular/combat_idle.png",
                "legs/pants/muscular/combat_idle.png",
                "torso/armour/leather/male/combat_idle.png",
                "head/heads/orc/male/combat_idle.png",
                "weapon/sword/arming/universal/fg/combat_idle/iron.png",
            ],
        }
    },
    "monster_goblin": {
        "output_dir": os.path.join(OUTPUT_BASE, "monsters", "goblin"),
        "layers": {
            "walk": [
                "body/bodies/child/walk.png",
                "legs/shorts/shorts/male/walk.png",
                "head/heads/goblin/adult/walk.png",
                "weapon/sword/arming/universal/fg/walk/bronze.png",
            ],
            "slash": [
                "body/bodies/child/slash.png",
                "legs/shorts/shorts/male/slash.png",
                "head/heads/goblin/adult/slash.png",
                "weapon/sword/arming/attack_slash/fg/bronze.png",
            ],
            "thrust": [
                "body/bodies/child/thrust.png",
                "legs/shorts/shorts/male/thrust.png",
                "head/heads/goblin/adult/thrust.png",
            ],
            "hurt": [
                "body/bodies/child/hurt.png",
                "legs/shorts/shorts/male/hurt.png",
                "head/heads/goblin/adult/hurt.png",
            ],
            "combat_idle": [
                "body/bodies/child/combat_idle.png",
                "legs/shorts/shorts/male/combat_idle.png",
                "head/heads/goblin/adult/combat_idle.png",
                "weapon/sword/arming/universal/fg/combat_idle/bronze.png",
            ],
        }
    },
    "monster_minotaur": {
        "output_dir": os.path.join(OUTPUT_BASE, "monsters", "minotaur"),
        "layers": {
            "walk": [
                "body/bodies/muscular/walk.png",
                "legs/pantaloons/muscular/walk.png",
                "head/heads/minotaur/male/walk.png",
                "head/horns/curled/adult/walk.png",
                "weapon/sword/arming/universal/fg/walk/iron.png",
            ],
            "slash": [
                "body/bodies/muscular/slash.png",
                "legs/pantaloons/muscular/slash.png",
                "head/heads/minotaur/male/slash.png",
                "head/horns/curled/adult/slash.png",
                "weapon/sword/arming/attack_slash/fg/iron.png",
            ],
            "thrust": [
                "body/bodies/muscular/thrust.png",
                "legs/pantaloons/muscular/thrust.png",
                "head/heads/minotaur/male/thrust.png",
                "head/horns/curled/adult/thrust.png",
            ],
            "hurt": [
                "body/bodies/muscular/hurt.png",
                "legs/pantaloons/muscular/hurt.png",
                "head/heads/minotaur/male/hurt.png",
                "head/horns/curled/adult/hurt.png",
            ],
            "combat_idle": [
                "body/bodies/muscular/combat_idle.png",
                "legs/pantaloons/muscular/combat_idle.png",
                "head/heads/minotaur/male/combat_idle.png",
                "head/horns/curled/adult/combat_idle.png",
                "weapon/sword/arming/universal/fg/combat_idle/iron.png",
            ],
        }
    }
}

def generate_preset(name, config):
    out_dir = config["output_dir"]
    os.makedirs(out_dir, exist_ok=True)
    print(f"\n--- Generating: {name} into {out_dir} ---")

    for anim_name, layers in config["layers"].items():
        res = composite_layers(layers)
        if res:
            out_path = os.path.join(out_dir, f"{anim_name}.png")
            res.save(out_path)
            print(f"  [OK] {anim_name}.png ({res.size[0]}x{res.size[1]})")

    # Extract 64x64 Front Idle Icon
    walk_path = os.path.join(out_dir, "walk.png")
    if os.path.exists(walk_path):
        walk_im = Image.open(walk_path)
        # LPC Walk: Row 2 (index 2) is facing DOWN (Front). Col 0 is idle standing frame!
        # y = 2 * 64 = 128, x = 0
        front_idle = walk_im.crop((0, 128, 64, 192))
        front_idle.save(os.path.join(out_dir, "idle_front.png"))
        print(f"  [OK] idle_front.png (64x64)")

def main():
    print(f"=== LPC SPRITESHEET COMPOSER ===")
    print(f"LPC Library Root: {LPC_ROOT}")
    if not os.path.exists(LPC_ROOT):
        print("ERROR: LPC spritesheets directory not found!")
        sys.exit(1)

    for preset_name, preset_cfg in PRESETS.items():
        generate_preset(preset_name, preset_cfg)

    print("\n=== All Character & Monster Spritesheets generated successfully! ===")

if __name__ == "__main__":
    main()
