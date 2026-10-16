import os
import math
from PIL import Image, ImageDraw, ImageFilter

def create_master_icon():
    # Render at 2048x2048 supersampled
    S = 2048
    canvas = Image.new('RGBA', (S, S), (0, 0, 0, 0))

    # --- 1. Background Squircle ---
    bg_mask = Image.new('L', (S, S), 0)
    bg_mask_draw = ImageDraw.Draw(bg_mask)
    margin = 80
    corner_radius = 440
    bg_mask_draw.rounded_rectangle([margin, margin, S - margin, S - margin], radius=corner_radius, fill=255)

    # Gradient: Deep obsidian teal (8, 48, 44) to vibrant emerald teal (13, 148, 136) to bright cyan (20, 184, 166)
    bg_gradient = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    for y in range(S):
        ty = y / S
        for x in range(0, S, 4):  # step by 4 for speed, then stretch or pixel-fill
            tx = x / S
            t = (tx * 0.45 + ty * 0.85) / 1.3
            t = max(0.0, min(1.0, t))
            r = int(10 * (1 - t) + 14 * t)
            g = int(58 * (1 - t) + 160 * t)
            b = int(54 * (1 - t) + 146 * t)
            for dx in range(4):
                if x + dx < S:
                    bg_gradient.putpixel((x + dx, y), (r, g, b, 255))
    
    bg_gradient.putalpha(bg_mask)
    canvas.alpha_composite(bg_gradient)

    # Subtle inner border / highlight ring
    border_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_layer)
    border_draw.rounded_rectangle([margin, margin, S - margin, S - margin], radius=corner_radius, outline=(255, 255, 255, 45), width=8)
    canvas.alpha_composite(border_layer)

    # --- 2. Clipboard Backing (Dark Slate) ---
    board_w = 1100
    board_h = 1380
    board_x = (S - board_w) // 2 - 40
    board_y = (S - board_h) // 2 + 30
    board_radius = 70

    # Drop shadow for board
    shadow_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_draw.rounded_rectangle(
        [board_x, board_y + 25, board_x + board_w, board_y + board_h + 25],
        radius=board_radius,
        fill=(0, 20, 20, 110)
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(35))
    canvas.alpha_composite(shadow_layer)

    # Board surface (Charcoal Slate #1E293B)
    board_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    board_draw = ImageDraw.Draw(board_layer)
    board_draw.rounded_rectangle(
        [board_x, board_y, board_x + board_w, board_y + board_h],
        radius=board_radius,
        fill=(26, 38, 54, 255)
    )
    # Board edge highlight
    board_draw.rounded_rectangle(
        [board_x, board_y, board_x + board_w, board_y + board_h],
        radius=board_radius,
        outline=(51, 65, 85, 255),
        width=6
    )
    canvas.alpha_composite(board_layer)

    # --- 3. Crisp White Paper Sheet ---
    paper_margin_x = 55
    paper_margin_top = 110
    paper_margin_bottom = 60
    paper_x = board_x + paper_margin_x
    paper_y = board_y + paper_margin_top
    paper_w = board_w - (paper_margin_x * 2)
    paper_h = board_h - paper_margin_top - paper_margin_bottom
    paper_radius = 40

    paper_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    paper_draw = ImageDraw.Draw(paper_layer)
    # Paper fill
    paper_draw.rounded_rectangle(
        [paper_x, paper_y, paper_x + paper_w, paper_y + paper_h],
        radius=paper_radius,
        fill=(252, 254, 255, 255)
    )
    canvas.alpha_composite(paper_layer)

    # --- 4. Notes Content (Inspection Items & Lines) ---
    notes_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    ndraw = ImageDraw.Draw(notes_layer)

    # Header section: Title bar & accent line
    header_x = paper_x + 80
    header_y = paper_y + 110
    # Header badge (Teal pill)
    ndraw.rounded_rectangle([header_x, header_y, header_x + 380, header_y + 44], radius=22, fill=(15, 118, 110, 255))
    ndraw.rounded_rectangle([header_x + 410, header_y + 10, header_x + 640, header_y + 34], radius=12, fill=(203, 213, 225, 255))

    # Divider line
    ndraw.line([(header_x, header_y + 80), (paper_x + paper_w - 80, header_y + 80)], fill=(226, 232, 240, 255), width=6)

    # 3 Inspection Checklist Rows
    row_start_y = header_y + 140
    row_spacing = 150

    for i in range(3):
        ry = row_start_y + (i * row_spacing)
        cb_size = 64
        cb_x = header_x

        if i == 0:
            # First item: COMPLETED with vibrant emerald checkmark
            ndraw.rounded_rectangle([cb_x, ry, cb_x + cb_size, ry + cb_size], radius=16, fill=(16, 185, 129, 255))
            # Draw white checkmark
            check_points = [
                (cb_x + 16, ry + 32),
                (cb_x + 28, ry + 46),
                (cb_x + 50, ry + 18)
            ]
            ndraw.line(check_points, fill=(255, 255, 255, 255), width=8, joint="curve")
            # Text line (Active)
            ndraw.rounded_rectangle([cb_x + 100, ry + 12, cb_x + 660, ry + 38], radius=13, fill=(51, 65, 85, 255))
            ndraw.rounded_rectangle([cb_x + 100, ry + 50, cb_x + 480, ry + 68], radius=9, fill=(148, 163, 184, 255))
        elif i == 1:
            # Second item: IN-PROGRESS with cyan-teal check
            ndraw.rounded_rectangle([cb_x, ry, cb_x + cb_size, ry + cb_size], radius=16, fill=(14, 165, 233, 255))
            check_points = [
                (cb_x + 16, ry + 32),
                (cb_x + 28, ry + 46),
                (cb_x + 50, ry + 18)
            ]
            ndraw.line(check_points, fill=(255, 255, 255, 255), width=8, joint="curve")
            ndraw.rounded_rectangle([cb_x + 100, ry + 12, cb_x + 580, ry + 38], radius=13, fill=(51, 65, 85, 255))
            ndraw.rounded_rectangle([cb_x + 100, ry + 50, cb_x + 400, ry + 68], radius=9, fill=(148, 163, 184, 255))
        else:
            # Third item: PENDING checkbox outline
            ndraw.rounded_rectangle([cb_x, ry, cb_x + cb_size, ry + cb_size], radius=16, outline=(203, 213, 225, 255), width=7)
            ndraw.rounded_rectangle([cb_x + 100, ry + 12, cb_x + 520, ry + 38], radius=13, fill=(148, 163, 184, 255))
            ndraw.rounded_rectangle([cb_x + 100, ry + 50, cb_x + 340, ry + 68], radius=9, fill=(203, 213, 225, 255))

    canvas.alpha_composite(notes_layer)

    # --- 5. Metallic Clip at Top ---
    clip_w = 440
    clip_h = 130
    clip_x = (S - clip_w) // 2 - 40
    clip_y = board_y - 25

    # Clip shadow
    c_shadow = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    cs_draw = ImageDraw.Draw(c_shadow)
    cs_draw.rounded_rectangle([clip_x, clip_y + 15, clip_x + clip_w, clip_y + clip_h + 15], radius=28, fill=(0, 20, 20, 80))
    c_shadow = c_shadow.filter(ImageFilter.GaussianBlur(15))
    canvas.alpha_composite(c_shadow)

    # Clip body (Metallic silver/chrome #E2E8F0)
    clip_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    cdraw = ImageDraw.Draw(clip_layer)
    cdraw.rounded_rectangle([clip_x, clip_y, clip_x + clip_w, clip_y + clip_h], radius=28, fill=(241, 245, 249, 255))
    # Clip highlight top
    cdraw.rounded_rectangle([clip_x + 10, clip_y + 8, clip_x + clip_w - 10, clip_y + 35], radius=14, fill=(255, 255, 255, 180))
    # Clip inner slot / hole
    slot_w = 190
    slot_h = 34
    slot_x = (S - slot_w) // 2 - 40
    slot_y = clip_y + 48
    cdraw.rounded_rectangle([slot_x, slot_y, slot_x + slot_w, slot_y + slot_h], radius=17, fill=(71, 85, 105, 255))
    canvas.alpha_composite(clip_layer)

    # --- 6. Floating Location / GPS Pin Badge (Bottom Right) ---
    badge_size = 460
    pin_center_x = board_x + board_w - 70
    pin_center_y = board_y + board_h - 120

    # Badge Shadow
    p_shadow = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    ps_draw = ImageDraw.Draw(p_shadow)
    ps_draw.ellipse(
        [pin_center_x - badge_size//2, pin_center_y - badge_size//2 + 25,
         pin_center_x + badge_size//2, pin_center_y + badge_size//2 + 25],
        fill=(0, 20, 20, 120)
    )
    p_shadow = p_shadow.filter(ImageFilter.GaussianBlur(35))
    canvas.alpha_composite(p_shadow)

    # Pin Badge Outer Circle (Vibrant Orange-Amber Gradient #F59E0B / #D97706)
    pin_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    pdraw = ImageDraw.Draw(pin_layer)

    pdraw.ellipse(
        [pin_center_x - badge_size//2, pin_center_y - badge_size//2,
         pin_center_x + badge_size//2, pin_center_y + badge_size//2],
        fill=(245, 158, 11, 255)
    )
    # Pin Badge White Rim
    pdraw.ellipse(
        [pin_center_x - badge_size//2, pin_center_y - badge_size//2,
         pin_center_x + badge_size//2, pin_center_y + badge_size//2],
        outline=(255, 255, 255, 255),
        width=16
    )

    # Draw Location Pin Icon inside badge
    # Upper head circle & bottom point
    head_r = 95
    head_cy = pin_center_y - 35
    pdraw.ellipse(
        [pin_center_x - head_r, head_cy - head_r,
         pin_center_x + head_r, head_cy + head_r],
        fill=(255, 255, 255, 255)
    )
    # Triangle pointing down
    tip_y = pin_center_y + 115
    pdraw.polygon(
        [(pin_center_x - head_r + 14, head_cy + 35),
         (pin_center_x + head_r - 14, head_cy + 35),
         (pin_center_x, tip_y)],
        fill=(255, 255, 255, 255)
    )
    # Inner pin dot (Amber)
    dot_r = 42
    pdraw.ellipse(
        [pin_center_x - dot_r, head_cy - dot_r,
         pin_center_x + dot_r, head_cy + dot_r],
        fill=(245, 158, 11, 255)
    )

    canvas.alpha_composite(pin_layer)

    # Downsample from 2048x2048 to 1024x1024 with Lanczos for super-crisp anti-aliasing
    master_1024 = canvas.resize((1024, 1024), Image.Resampling.LANCZOS)
    return master_1024

master = create_master_icon()
os.makedirs("mobile/assets/icons", exist_ok=True)
master.save("mobile/assets/icons/app_logo.png")
master.resize((512, 512), Image.Resampling.LANCZOS).save("mobile/assets/icons/app_logo_512.png")

# Mipmap densities for Android
densities = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

for folder, px in densities.items():
    target_dir = os.path.join("mobile/android/app/src/main/res", folder)
    os.makedirs(target_dir, exist_ok=True)
    icon_resized = master.resize((px, px), Image.Resampling.LANCZOS)
    icon_resized.save(os.path.join(target_dir, "ic_launcher.png"))
    print(f"Saved {folder}/ic_launcher.png ({px}x{px})")

# Web icons
web_icons = {
    "mobile/web/icons/Icon-192.png": 192,
    "mobile/web/icons/Icon-512.png": 512,
    "mobile/web/favicon.png": 64,
}
for path, px in web_icons.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    master.resize((px, px), Image.Resampling.LANCZOS).save(path)
    print(f"Saved {path} ({px}x{px})")

print("All app icons successfully generated!")
