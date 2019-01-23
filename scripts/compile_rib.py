# Copyright André Vennberg 2019

import re
import os
import sys
import subprocess

from PIL import Image
from pathlib import Path

DATE_RGX = re.compile(r'^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2} ')
ERROR_PARSE_RGX = re.compile(r'^Parse error at (.+):(\d+) \(col (\d+)\) while reading (.+): (.+)$')

class ParsingError(Exception):
    pass

class ErrorMessage:
    file: str
    msg_type: str

    line: int
    end_line: int

    col: int
    end_col: int

    message: int

    def __init__(self, file, msg_type, line, message, col = None, end_line = None, end_col = None):
        self.file = file
        self.msg_type = msg_type
        self.line = line
        self.message = message
        self.col = col
        self.end_line = end_line
        self.end_col = end_col

    def print(self):
        string = "{}:".format(self.file)

        if self.col is None:
            string += "({})".format(self.line)
        elif self.end_line is None and self.end_col is None:
            string += "({}, {})".format(self.line, self.col)
        else:
            if self.end_line is None:
                self.end_line = self.line
            if self.end_col is None:
                self.end_col = self.col
            
            string += "({}, {}, {}, {})".format(self.line, self.col, self.end_line, self.end_col)
        
        string += " {}: {}".format(self.msg_type, self.message)
        print(string)


def find_string_in_file(file_path: str, pattern: str):
    with open(file_path, 'r') as f:
        line_num = 1

        for line in f:
            if pattern in line:
                index = line.index(pattern)

                return {
                    'line': line_num,
                    'end_line': line_num,
                    'col': index,
                    'end_col': index + len(pattern) + 2
                }
            
            line_num += 1
    
    raise LookupError("'{}' was not found in '{}'".format(pattern, file_path))

def parse_message(path: str, msg: str):
    # Remove date string.
    msg = re.sub(DATE_RGX, '', msg)
    
    message_type = msg[0:msg.find(": ")]
    msg = msg[msg.find(": ") + 2::]

    print(message_type, msg)
    
    if msg.startswith("Parse error"):
        match = re.match(ERROR_PARSE_RGX, msg)

        if match is None:
            raise ParsingError("Parse error doesn't match regex: " + msg)
        
        file, line, column, item, message = match.groups()

        if message.startswith("unrecognized request"):
            end_column = int(column) + len(item)
            message = "Unrecognized keyword (probably misspelled)."

            return ErrorMessage(
                file, message_type, int(line), message, int(column), int(line), end_column
            )
        
        elif message.startswith("{} is invalid at Outer scope".format(item)):
            end_column = int(column) + len(item)
            message = "Keyword can't exist in this scope, there's probably a missing keyword above this."

            return ErrorMessage(
                file, message_type, int(line), message, int(column), int(line), end_column
            )
        
        elif message.startswith("undeclared token"):
            item = message[message.find('"') + 1:message.rfind('"')]
            end_column = int(column) + len(item) + 2
            message = "Parameter to shader has either got the wrong name or the wrong type."

            return ErrorMessage(
                file, message_type, int(line), message, int(column), int(line), end_column
            )
        
        elif message.startswith("Cannot find the primary display"):
            return ErrorMessage(
                file, message_type, int(line), message, int(column)
            )
        
        else:
            raise ParsingError("Unknown parse error: " + message)

    elif msg.startswith("Shader"):
        if "not found" in msg:
            shader_name = msg[msg.find('"') + 1:msg.rfind('"')]
            location = find_string_in_file(path, shader_name)

            message = "Cannot find the compiled shader called {}.slx.".format(shader_name)

            return ErrorMessage(path, message_type, message=message, **location)
    
    else:
        raise ParsingError("Unknown error: " + msg)


def scan_shaders(rib_path: str):
    found_shaders = {}

    rib_dir = Path(rib_path).parent

    # Find all shaders in the same directory as the RIB file.
    for shader in rib_dir.glob('*.sl'):
        name = os.path.splitext(os.path.basename(shader))[0]
        mod_time = os.path.getmtime(shader)

        found_shaders[name] = mod_time

    needed_shaders = {}

    # Find all the shaders that are referenced in the file.
    with open(rib_path, 'r') as rib:
        for line in rib:
            if len(found_shaders) == 0:
                break

            for shader, time in found_shaders.copy().items():
                if shader in line:
                    found_shaders.pop(shader)
                    needed_shaders[shader] = time
    
    # Remove those who have already been compiled and not been changed since.
    for compiled_shader in Path('./shaders/').glob('*.slx'):
        name = os.path.splitext(os.path.basename(compiled_shader))[0]

        if name in needed_shaders:
            shader_mod_time = needed_shaders[name]
            compiled_mod_time = os.path.getmtime(compiled_shader)

            if shader_mod_time < compiled_mod_time:
                # If the shader hasn't been modified since it has been compiled, ignore it.
                needed_shaders.pop(name)
            else:
                # Remove outdated compiled shader.
                compiled_shader.unlink()
    

    # Put the relative path back on the shader names.
    return [rib_dir / f for f in needed_shaders.keys()]
    

def compile_shader(path: str):
    output_file = "shaders/{}.slx".format(
        os.path.basename(path)
    )

    result = subprocess.run(
        ['aqsl', "-o", output_file, str(path) + ".sl"],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    
    for msg in result.stderr.decode('utf-8').splitlines():
        # TODO: Improve error handling here.
        print("Compile error!:", msg)
        sys.exit(1)


def compile_rib(path: str):
    result = subprocess.run(
        ['aqsis', path],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )

    for output in result.stdout.decode('utf-8').splitlines():
        print(output)

    for msg in result.stderr.decode('utf-8').splitlines():
        error = parse_message(path, msg)
        error.print()


def convert_image():
    try:
        image_path = [p for p in Path('.').glob('*.tif')][0]
    except IndexError:
        print("Error! Cannot find .tif file in project root.\nPlease check the display attribute of the RIB file.", file=sys.stderr)
    
    image_name, ext = os.path.splitext(image_path.name)

    image = Image.open(image_name + ext)
    image.save('images/{}.png'.format(image_name))

    image_path.unlink()


def find_rib_file(path: str):
    try:
        rib_path = [p for p in Path(path).parent.glob('*.rib')][0]
    except IndexError:
        print("Error! Cannot find a .rib file in the same directory as this shader.\n", file=sys.stderr)
        sys.exit(1)
    
    return str(rib_path)

def main():
    if len(sys.argv) == 1:
        sys.exit(1)

    path = sys.argv[1]

    if path.endswith('.sl'):
        path = find_rib_file(path)

    for shader in scan_shaders(path):
        compile_shader(shader)

    compile_rib(path)
    convert_image()

main()