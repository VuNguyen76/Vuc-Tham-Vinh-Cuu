"""
Quái Vật Vĩnh Cửu (QVVC) - Gemini Image Generator
Kế thừa từ phiên làm việc trước: Tự động tạo ảnh Boss, Trang Bị, Vật Phẩm bằng Imagen 3 qua Gemini Web.
"""

import os
import sys
import io
import json
import asyncio
import argparse
from pathlib import Path
from datetime import datetime

# Đảm bảo in tiếng Việt UTF-8 trên Windows
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

MCP_CONFIG_PATH = Path(r"C:\Users\Admin\.gemini\antigravity\mcp_config.json")

def load_cookies():
    psid = os.environ.get("GEMINI_PSID", "")
    psidts = os.environ.get("GEMINI_PSIDTS", "")
    
    if not psid and MCP_CONFIG_PATH.exists():
        try:
            with open(MCP_CONFIG_PATH, "r", encoding="utf-8") as f:
                data = json.load(f)
                gemini_env = data.get("mcpServers", {}).get("gemini-web", {}).get("env", {})
                psid = gemini_env.get("GEMINI_PSID") or gemini_env.get("__Secure-1PSID", "")
                psidts = gemini_env.get("GEMINI_PSIDTS") or gemini_env.get("__Secure-1PSIDTS", "")
        except Exception as e:
            print(f"[Warning] Không thể đọc cookies từ mcp_config.json: {e}", file=sys.stderr)
            
    return psid, psidts

async def generate_images(prompt: str, output_dir: Path):
    try:
        from gemini_webapi import GeminiClient
    except ImportError:
        print("[Error] Thư viện gemini_webapi chưa được cài đặt trong môi trường hiện tại.", file=sys.stderr)
        return []
        
    psid, psidts = load_cookies()
    if not psid:
        print("[Error] Không tìm thấy cookie GEMINI_PSID! Hãy kiểm tra mcp_config.json", file=sys.stderr)
        return []
        
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"[*] Đang khởi tạo Gemini Web Client...")
    client = GeminiClient(secure_1psid=psid, secure_1psidts=psidts or None)
    await client.init(timeout=60, auto_close=False, auto_refresh=True)
    
    full_prompt = prompt
    lower_prompt = prompt.lower()
    if not any(k in lower_prompt for k in ["tạo ảnh", "vẽ", "generate image", "create image", "draw"]):
        full_prompt = f"Pixel art game asset for dark fantasy RPG game 'Quái Vật Vĩnh Cửu': {prompt}"
        
    print(f"[*] Đang gửi prompt tạo ảnh lên Gemini Web (Imagen 3)...")
    print(f"    Prompt: {full_prompt}")
    
    res = await client.generate_content(full_prompt)
    
    if not res.images:
        print("[!] Không có ảnh nào được trả về từ Gemini. Text phản hồi:")
        print(res.text or "(trống)")
        return []
        
    saved_files = []
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    print(f"[+] Đã tạo thành công {len(res.images)} ảnh! Đang tải về...")
    for i, img in enumerate(res.images):
        filename = f"qvvc_asset_{timestamp}_{i+1}.png"
        filepath = await img.save(
            path=str(output_dir),
            filename=filename,
            verbose=False,
            full_size=True
        )
        if filepath:
            print(f"    -> Đã lưu: {filepath}")
            saved_files.append(filepath)
            
    return saved_files

def main():
    parser = argparse.ArgumentParser(description="Tạo asset game cho Quái Vật Vĩnh Cửu bằng Gemini Web")
    parser.add_argument("prompt", help="Mô tả bức ảnh/vật thể muốn tạo")
    parser.add_argument("--output", "-o", default=r"D:\QVVC\public\assets\generated", help="Thư mục lưu ảnh")
    args = parser.parse_args()
    
    out_dir = Path(args.output).resolve()
    saved = asyncio.run(generate_images(args.prompt, out_dir))
    if saved:
        print(f"\n[DONE] Hoàn tất! Ảnh đã được lưu tại: {out_dir}")
    else:
        print(f"\n[FAIL] Không thể tạo ảnh.")

if __name__ == "__main__":
    main()
