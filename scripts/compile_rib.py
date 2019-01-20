import re
import os
import sys
import subprocess



DATE_RGX = re.compile(r'^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2} ')

ERROR_PARSE_RGX = re.compile(r'^Parse error at (.+):(\d+) \(col (\d+)\) while reading (.+): (.+)$')

def parse_message(msg: str):
    # Remove date string.
    msg = re.sub(DATE_RGX, '', msg)
    
    message_type = msg[0:msg.find(": ")]
    msg = msg[msg.find(": ") + 2::]
    
    if msg.beginswith("Parse error"):




def run_compiler(path: str):
    result = subprocess.run(
        ['aqsis', '-shaders="./shaders/:&"', path],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )

    for output in result.stdout.decode('utf-8').splitlines():
        print("OUTPUT:", output)

    for msg in result.stderr.decode('utf-8').splitlines():
        parse_message(msg)


def main():
    if len(sys.argv) == 1:
        sys.exit(1)
    
    rib_path = sys.argv[1]
    run_compiler(rib_path)

    print("Done!")

main()