import os, json, base64, sqlite3
import win32crypt, win32file
from Crypto.Cipher import AES

def copy_locked_file(src, dst):
    handle = win32file.CreateFile(
        src,
        win32file.GENERIC_READ,
        win32file.FILE_SHARE_READ | win32file.FILE_SHARE_WRITE | win32file.FILE_SHARE_DELETE,
        None,
        win32file.OPEN_EXISTING,
        win32file.FILE_ATTRIBUTE_NORMAL,
        None
    )
    with open(dst, 'wb') as f_out:
        while True:
            err, data = win32file.ReadFile(handle, 64 * 1024)
            if not data:
                break
            f_out.write(data)
    win32file.CloseHandle(handle)

def get_chrome_cookies():
    local_state_path = r'C:\Users\Admin\AppData\Local\Google\Chrome\User Data\Local State'
    cookies_path = r'C:\Users\Admin\AppData\Local\Google\Chrome\User Data\Default\Network\Cookies'

    with open(local_state_path, 'r', encoding='utf-8') as f:
        local_state = json.loads(f.read())
    key = base64.b64decode(local_state['os_crypt']['encrypted_key'])[5:]
    decrypted_key = win32crypt.CryptUnprotectData(key, None, None, None, 0)[1]

    temp_cookies = r'd:\QVVC\temp_cookies.db'
    copy_locked_file(cookies_path, temp_cookies)
    conn = sqlite3.connect(temp_cookies)
    cursor = conn.cursor()
    cursor.execute("SELECT host_key, name, encrypted_value FROM cookies WHERE host_key LIKE '%google%'")

    def decrypt_val(enc_val):
        iv = enc_val[3:15]
        payload = enc_val[15:]
        cipher = AES.new(decrypted_key, AES.MODE_GCM, iv)
        dec = cipher.decrypt(payload)[:-16]
        return dec.decode('utf-8', errors='ignore')

    cookies = {}
    for host, name, enc in cursor.fetchall():
        try:
            val = decrypt_val(enc)
            if any(k in name for k in ['PSID', 'SAPISID', 'COMPASS', 'NID', 'AEC', 'SSID', 'ENID', 'BUCKET', 'STRP']):
                cookies[f'{host}:{name}'] = val
                print(f'{host} | {name} = {val[:25]}... (len {len(val)})')
        except Exception:
            pass

    conn.close()
    if os.path.exists(temp_cookies):
        os.remove(temp_cookies)
    return cookies

if __name__ == '__main__':
    c = get_chrome_cookies()
    with open('d:/QVVC/live_chrome_cookies.json', 'w', encoding='utf-8') as f:
        json.dump(c, f, indent=2)
    print('Extracted cookies count:', len(c))
