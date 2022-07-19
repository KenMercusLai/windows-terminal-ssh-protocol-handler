import csv
import sys
from typing import List

import requests


def read_content(csv_file: str) -> List:
    with open(csv_file) as f:
        reader = csv.DictReader(f, delimiter=';')
        return [i for i in reader]


def import_content(bookmark_content: List, server: str, token: str):
    headers = {'Authorization': 'Token {}'.format(token)}
    api = "/api/bookmarks/"
    url = server + api
    for i in bookmark_content:
        if not i['Hostname']:
            continue

        protocol = i['Protocol'].lower().strip()
        if protocol == 'ssh2':
            protocol = 'ssh'
        payload = {
            "url": "{}://PA_ACCOUNT@{}:{}".format(protocol, i['Hostname'], i['Port']),
            "title": i['Name'],
            "is_archived": False,
        }
        response = requests.post(url=url, headers=headers, json=payload, verify=False)
        if not response.ok:
            print(i)


def main():
    _, bookmark_file, server, token = sys.argv
    bookmark_content = read_content(bookmark_file)
    import_content(bookmark_content, server, token)


if __name__ == '__main__':
    main()
