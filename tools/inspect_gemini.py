from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context(
        user_data_dir=r'C:\Users\Admin\.gemini\gemini-chrome-profile',
        headless=True,
        channel='chrome'
    )
    page = ctx.new_page()
    page.goto('https://gemini.google.com/app', timeout=60000)
    page.wait_for_timeout(5000)
    page.screenshot(path='d:/QVVC/gemini_conversation_screen.png', full_page=True)
    print('Current URL:', page.url)

    # Print images
    imgs = page.query_selector_all('img')
    print('Found images:', len(imgs))
    for i, img in enumerate(imgs):
        src = img.get_attribute('src') or ''
        alt = img.get_attribute('alt') or ''
        print(f'{i}: src={src[:80]}... alt={alt}')

    # Print text content of responses
    responses = page.query_selector_all('model-response, message-content, div.message-content')
    print('Responses found:', len(responses))
    for i, r in enumerate(responses):
        print(f'Response {i}: {r.inner_text()[:300]}')
    ctx.close()
