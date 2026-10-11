from playwright.sync_api import sync_playwright

raw_cookies = [
    ('SAPISID', 'Elxo3cbLkdsxOKdc/AqS5j8WcFlYDXqVJG', '.google.com'),
    ('__Secure-3PAPISID', 'Elxo3cbLkdsxOKdc/AqS5j8WcFlYDXqVJG', '.google.com'),
    ('AEC', 'Aaa9EJo4r_Bpa7TVdAS2VxDn7jrMt4-WRjQMBeiI6HIkbRsukdEFfye5P3g', '.google.com'),
    ('NID', 'CsADCAES8gIBOxGDSE66A42Frik6Ynmp9eLORBXW_AllNbPR1Y_PXQuzlotV2AD5Z-rGfgN4WSUNwboyjWC1Pnz5tRY3XazfrJphybgbJUkAXwMHbvKqrRbwf1Ml0oyZvBO3C50BULiZ_--y3W7H-tsBGNOVN59zilADWlvuR-LvM0t_OoxtG-PGfOfndD9btPfJ4pE3QqOPDLOWXJ7_wOxE7vBYfnWH6AloLxnEnHuFgIrHKXGBdU4WfCEFDddeTOBHT76dbR1iEgng1lDSJCngVsCK36KRi6BjkDxer_qjMjkU5t-A2uFntbO7J4ulKnIgZ6dP02JXL76x-V8XMhkFuhVKWZkNT8pMF8x530HkJzZg2a_fSCUaE5AP7HJrygVrA6rj-j1wDHRIUF_1GhtWRhFgoXnIyunWwMwmJrUPIXP6XdBaUTo-414CHe3POCVL8JehhMN1a220rCItTWSlgWHM2cxKeMy425d-n2KCB6Nzq6d5W8EEKAEyRQHSrAfPnh-AtC0l_P8z5sD1eJOffkn-H_uERlCGw-25fbPxfwa7bbWzZ2PxKI3klf6ydPbDJ34oiOwjrEs-ZdtvYwrXCA', '.google.com'),
    ('__Secure-1PSIDTS', 'sidts-CjIBkldj_9B-IZb_DyDTjUsfYVvUWeBHcdwHHL0Y-Po_6XAi1-DsOVa4DhjUVrKEC3hJoxAA', '.google.com'),
    ('COMPASS', 'gwus-pd=CjYACWuJV6bdbSKCsd3u60qAkVAfygccGCCfpHkG4CElBKJ49ycMN55fMbrGk3w4rTFjTPKDAK8QxPSw1gYaYAAJa4lXLitmZfFcSpxB8Fyi-UUB7782umPK4HlL1sHAVYBXrOVzF6ZcufDI7lw_s7XYdhGW-Y3CSRGuHQxNfPUVFyfbkiYCTFJ6T3ZRIPjROrZMQ3_j82RTa-J_-aS5gSABMAE', '.gemini.google.com'),
    ('__Secure-1PAPISID', 'Elxo3cbLkdsxOKdc/AqS5j8WcFlYDXqVJG', '.google.com'),
    ('__Secure-3PSID', 'g.a000DAlQyMEybIiWKKG1jz5s-UgyvzpJCNR55CM--KM92bQJxr7bnnY_Sheg1e7oTZlVI_7EiwACgYKASgSARMSFQHGX2Mi22MOWsqQX3zFTt02CwOQRRoVAUF8yKpHNcrE7ZB8yldUgiKjF2TD0076', '.google.com'),
    ('__Secure-1PSID', 'g.a000DAlQyMEybIiWKKG1jz5s-UgyvzpJCNR55CM--KM92bQJxr7bAFdt1x4lhU9gsiCBikPqfAACgYKAcMSARMSFQHGX2MigpWm5a8TWetLMDWV78FgQRoVAUF8yKpOJf-jx9NhBtDKCxdbs5lU0076', '.google.com'),
    ('__Secure-1PSIDCC', 'AKEyXzUKAfSMRjRV2phvEi0uMU25wGbjDi5EHz7JTf51E-sS4H1KT0C_akgzQrTDBurumEjt8p0', '.google.com'),
    ('__Secure-3PSIDCC', 'AKEyXzUKrWOC_tUKnMFSIBgcTfj4Gv1gxTTmF_IKhe2ZjLwRABT4LlXhr29amOByMnkdMVq-sxA', '.google.com'),
    ('__Secure-3PSIDTS', 'sidts-CjIBkldj_9B-IZb_DyDTjUsfYVvUWeBHcdwHHL0Y-Po_6XAi1-DsOVa4DhjUVrKEC3hJoxAA', '.google.com'),
    ('__Secure-BUCKET', 'CN8D', '.google.com'),
    ('__Secure-ENID', '35.SE=JWbh5sIW1ykhpa6yB08BJu6KXfwxXm1FySxvgVopaIWJFF5LR7Ep5XOmB3HZbxcLc0AYs1xrRQfimZiffDMfLCkciH56OoniI9mkjU5XtLzQx8S4vMYt6rA2xxVq7QL4zh8HbZrZdZzqtMtsawVB-bmvp37811NK4hlX_6_cLRcw3cPVM_AYIGpvzv5lXdbEyzR4Oq58g_KeakZ-gRIEp27tQMl-RsZXjjxEfwL8Ha9pS9wEeoDg7r9_wK3DDGBBvvsuDb6bMc5ifcjLtateWXp849LCp-jzZx6KNyzHe7317mKFx0s4mGMsfwmuO913W1CxymMGRmAz3k0', '.google.com'),
    ('__Secure-STRP', 'ABNhA6idSy86uSOK8RBFQVLBvb7h7tAxdEdqSNymk_NNlumCmUjckYyZUHXNA7eQJiaHh65vebsY6j7YPKYN67A4BxZj1Z6ZP2_j', '.google.com'),
    ('SSID', 'ARQ3Rq-5f38IZynEY', '.google.com')
]

pw_cookies = []
for name, val, domain in raw_cookies:
    url = 'https://gemini.google.com' if 'gemini' in domain else 'https://google.com'
    pw_cookies.append({
        'name': name,
        'value': val,
        'url': url
    })

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    context.add_cookies(pw_cookies)
    page = context.new_page()
    page.goto('https://gemini.google.com/app', timeout=30000)
    page.wait_for_timeout(5000)
    print('Current URL:', page.url)
    print('Page title:', page.title())
    page.screenshot(path='d:/QVVC/gemini_playwright_screen.png')
    browser.close()
