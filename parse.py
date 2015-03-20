import sys
import json
import lxml.html

result = {'fragments': {}}
html = lxml.html.fromstring(sys.argv[1].decode('utf-8'))
for item in html.getchildren():
    quality = item.find_class('quality')
    if quality:
        result['fragments'][quality[0].text_content()[1:-1]] = [
            link.get('href') for link in item.find_class('furl')]
print(json.dumps(result))
