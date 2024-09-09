import sys
import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from captcha_solver import CaptchaSolver


def setup_chrome_driver(headless=True):
    """
    Setup a headless Chrome WebDriver

    Parameters:
    - headless (bool): Whether to run the WebDriver in headless mode

    Returns:
    - driver (WebDriver): The Chrome WebDriver
    """
    options = Options()
    if headless:
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--start-maximized')
        options.add_argument('--disable-blink-features=AutomationControlled')
        options.add_experimental_option('useAutomationExtension', False)
        options.add_experimental_option('excludeSwitches', ['enable-automation', 'enable-logging'])
    return webdriver.Chrome(options=options)

def wait_for_element(driver, by, value, timeout=10):
    """
    Wait for an element to appear in the DOM

    Parameters:
    - driver (WebDriver): The Chrome WebDriver
    - by (By): The locator strategy
    - value (str): The locator value

    Returns:
    - element (WebElement): The element
    """
    return WebDriverWait(driver, timeout).until(lambda driver: driver.find_element(by, value))

def attempt_login(driver, sid, password, captcha_solver, login_url="https://my.edu.sharif.edu/", max_attempts=10, timeout=10):
    """
    Attempt to login to the Sharif University portal

    Parameters:
    - driver (WebDriver): The Chrome WebDriver
    - sid (str): The student ID
    - password (str): The password
    - captcha_solver (CaptchaSolver): The captcha solver

    Returns:
    - success (bool): Whether the login was successful
    """
    driver.get(login_url)
    wait_for_element(driver, By.NAME, 'username').send_keys(sid)
    wait_for_element(driver, By.NAME, 'password').send_keys(password)

    for _ in range(max_attempts):
        captcha_svg = wait_for_element(driver, By.TAG_NAME, 'svg').get_attribute('outerHTML')
        captcha = captcha_solver.solve_captcha(captcha_svg)

        driver.find_element(By.NAME, 'securityCode').send_keys(captcha)
        driver.find_element(By.TAG_NAME, 'button').click()

        WebDriverWait(driver, timeout).until(lambda driver: driver.current_url != login_url or driver.find_element(By.CLASS_NAME, 'error'))
        if driver.current_url != login_url:
            break

    return driver.current_url != login_url

def get_token(driver):
    data = driver.execute_script("return localStorage.getItem('persist:root')")
    return json.loads(data)['token'].replace('"', '')

def main():
    """
    Main function to run the script and get the JWT token

    Usage:
    - python main.py <sid> <password> [no-headless]

    Parameters:
    - sid (str): The student ID
    - password (str): The password
    """
    if len(sys.argv) < 3:
        print('Usage: python main.py <sid> <password>')
        sys.exit(1)
    sid, password = sys.argv[1], sys.argv[2]
    headless = len(sys.argv) < 4 or sys.argv[3] != 'no-headless'

    captcha_solver, driver = CaptchaSolver(), setup_chrome_driver(headless)
    if not attempt_login(driver, sid, password, captcha_solver):
        print('\033[91mFailed to login\033[0m')
        sys.exit(1)

    print(get_token(driver))
    driver.quit()


if __name__ == '__main__':
    main()