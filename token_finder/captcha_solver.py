import xml.etree.ElementTree as ET
import cairosvg
import easyocr


class CaptchaSolver:
    def __init__(self, languages=['en']):
        self.reader = easyocr.Reader(languages)

    def solve_captcha(self, svg_data, filter_fill_none=True, replace_spaces=True):
        """
        Solve a captcha from an SVG image

        Parameters:
        - svg_data (str): SVG image data
        - filter_fill_none (bool): Remove paths with fill='none' attribute
        - replace_spaces (bool): Replace spaces with empty string

        Returns:
        - captcha (str): The solved captcha text
        """
        if filter_fill_none:
            root = ET.fromstring(svg_data)
            for path in root.iter('{http://www.w3.org/2000/svg}path'):
                if path.attrib['fill'] == 'none':
                    root.remove(path)
            svg_data = ET.tostring(root, encoding='unicode')

        captcha = self.reader.readtext(cairosvg.svg2png(bytestring=svg_data))[0][1]
        return captcha.replace(' ', '') if replace_spaces else captcha