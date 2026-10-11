import os, sys, time, json
from pathlib import Path
from playwright.sync_api import sync_playwright

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')

PROFILE_DIR = r"C:\Users\Admin\.gemini\gemini-chrome-profile"
REFERENCE_IMAGE = r"C:\Users\Admin\.gemini\antigravity\brain\d732af13-5821-4892-a1fc-832fb1bf5365\.user_uploaded\media_1791686131799_09b65659.png"
OUTPUT_DIR = r"d:\QVVC\assets"
OUTPUT_IMAGE = os.path.join(OUTPUT_DIR, "player_skills_spritesheet.png")

PROMPT = (
    "A 2D pixel art character sprite sheet in the exact chibi anime pixel art style, proportions, "
    "and character design of the uploaded image (chibi boy with black hair, shirtless, red shorts). "
    "Clean pure white background, neat grid with 4 rows and 6 columns of action skill animation frames: "
    "Row 1: 6 frames of 3-hit sword slash combo animation. "
    "Row 2: 6 frames of spinning whirlwind dual blade attack skill. "
    "Row 3: 6 frames of dashing forward lance thrust piercing skill. "
    "Row 4: 6 frames of casting ultimate divine sword celestial magic skill. "
    "Keep uniform frame spacing, isolated pixel art on white background."
)

def run_automation():
    os.makedirs(PROFILE_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("[1/5] Dang khoi dong trinh duyet Chrome tu dong hoa...")
    with sync_playwright() as p:
        # Launch real Chrome with persistent user data dir
        context = p.chromium.launch_persistent_context(
            user_data_dir=PROFILE_DIR,
            headless=False,
            channel="chrome",
            args=[
                "--disable-blink-features=AutomationControlled",
                "--start-maximized"
            ]
        )

        page = context.new_page()
        print("[2/5] Dang truy cap https://gemini.google.com/app...")
        page.goto("https://gemini.google.com/app", timeout=60000)

        # Check login status
        print("[3/5] Kiem tra trang thai dang nhap...")
        time.sleep(3)

        input_selector = 'div[contenteditable="true"], rich-textarea, textarea, div.ql-editor'

        # Check if there is a Sign in button
        sign_in_btn = page.query_selector('a[href*="accounts.google.com"], button:has-text("Sign in"), a:has-text("Sign in")')
        signed_in = (sign_in_btn is None)

        if not signed_in:
            print("==================================================================")
            print("THONG BAO: Vui long click 'Sign in' / Dang nhap Google tren Chrome.")
            print("Ban chi can dang nhap 1 lan duy nhat de luu phien.")
            print("Script dang cho ban dang nhap hoan tat trong toi da 5 phut...")
            print("==================================================================")
            logged_in = False
            for _ in range(150):
                time.sleep(2)
                btn = page.query_selector('a[href*="accounts.google.com"], button:has-text("Sign in"), a:has-text("Sign in")')
                if btn is None:
                    print("Dang nhap thanh cong!")
                    logged_in = True
                    time.sleep(3)
                    break
            if not logged_in:
                print("Het thoi gian cho dang nhap (300s). Vui long thu lai.")
                context.close()
                return False

        print("[4/5] Dang dinh kem anh mau va nhap prompt tao skill spritesheet...")
        
        # Upload reference image if file input exists
        file_input = page.query_selector('input[type="file"]')
        if not file_input:
            # Click add/plus button to reveal file upload
            plus_btn = page.query_selector('button[aria-label*="Upload"], button[aria-label*="Add"], button[aria-label*="Tải lên"], button[aria-label*="Thêm"]')
            if plus_btn:
                plus_btn.click()
                time.sleep(1)
                file_input = page.query_selector('input[type="file"]')

        if file_input and os.path.exists(REFERENCE_IMAGE):
            print("Dang dinh kem anh mau:")
            print(" ->", REFERENCE_IMAGE)
            file_input.set_input_files(REFERENCE_IMAGE)
            time.sleep(3)
        else:
            print("Canh bao: Chua tim thay nut dinh kem file, se gui prompt truc tiep.")

        # Enter prompt into focused Gemini input
        input_elem = page.query_selector('div[contenteditable="true"], rich-textarea, textarea, div.ql-editor, p')
        if not input_elem:
            input_elem = page.query_selector(input_selector)

        if input_elem:
            input_elem.click()
            time.sleep(1)
            # Use keyboard.insert_text for rich text editor
            page.keyboard.insert_text(PROMPT)
            time.sleep(1)

            # Send message
            send_btn = page.query_selector('button[aria-label*="Send"], button[aria-label*="Gửi"], button.send-button')
            if send_btn:
                send_btn.click()
            else:
                page.keyboard.press("Enter")
            print("Da gui yeu cau sinh anh den Gemini!")
        else:
            print("Loi: Khong tim thay khung nhap lieu cua Gemini.")
            context.close()
            return False

        print("[5/5] Dang cho Gemini (Nano Banana) sinh anh hoan tat...")
        # Poll for generated images
        start_time = time.time()
        downloaded = False
        while time.time() - start_time < 180:
            time.sleep(5)
            # Look for generated images inside model responses
            imgs = page.query_selector_all('img[src*="googleusercontent.com"], img[alt*="Generated"], img[alt*="Tạo"]')
            valid_imgs = []
            for img in imgs:
                src = img.get_attribute("src") or ""
                # Ignore user avatars (small)
                if "googleusercontent.com" in src and "default-user" not in src and "/a/" not in src and len(src) > 50:
                    valid_imgs.append(img)

            if valid_imgs:
                target_img = valid_imgs[-1]
                src = target_img.get_attribute("src")
                print("Da phat hien anh sinh tu Gemini:")
                print(" -> URL:", src[:100] + "...")

                # Download high-res version
                high_res_url = src.split("=")[0] + "=s0"
                import urllib.request
                try:
                    # Download via browser evaluate or urllib
                    cookies_dict = {c['name']: c['value'] for c in context.cookies()}
                    req = urllib.request.Request(high_res_url, headers={
                        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                        "Cookie": "; ".join([f"{k}={v}" for k, v in cookies_dict.items()])
                    })
                    with urllib.request.urlopen(req) as response, open(OUTPUT_IMAGE, "wb") as out_f:
                        out_f.write(response.read())
                    print("LUU ANH THANH CONG:")
                    print(" -> File:", OUTPUT_IMAGE)
                    downloaded = True
                    import subprocess
                    subprocess.run([sys.executable, r"d:\QVVC\tools\process_spritesheet.py", OUTPUT_IMAGE])
                    break
                except Exception as e:
                    print("Tai truc tiep qua URL loi, luu anh qua screenshot element:", e)
                    target_img.screenshot(path=OUTPUT_IMAGE)
                    downloaded = True
                    break

        if not downloaded:
            print("Gemini dang xu ly hoac chua xuat anh. Vui long kiem tra tren cua so Chrome.")

        time.sleep(3)
        context.close()
        return downloaded

if __name__ == "__main__":
    success = run_automation()
    sys.exit(0 if success else 1)
