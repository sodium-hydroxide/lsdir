#!/usr/bin/env python3
import os
import stat
import pwd
import grp
import magic
# import time
from datetime import datetime

def get_file_details(path):
    """Get detailed file information similar to ls -la"""
    stats = os.stat(path)

    # Get file mode (permissions)
    mode = stat.filemode(stats.st_mode)

    # Get owner and group names
    try:
        owner = pwd.getpwuid(stats.st_uid).pw_name
    except KeyError:
        owner = str(stats.st_uid)
    try:
        group = grp.getgrgid(stats.st_gid).gr_name
    except KeyError:
        group = str(stats.st_gid)

    # Get file size
    size = stats.st_size

    # Get modification time
    mtime = datetime.fromtimestamp(stats.st_mtime).strftime('%b %d %H:%M')

    return f"{mode} {stats.st_nlink} {owner} {group} {size:8d} {mtime} {os.path.basename(path)}"

def is_binary_heuristic(file_path):
    """
    Simple heuristic to check if a file is binary by reading its first few kb
    and checking for null bytes and unprintable characters
    """
    try:
        with open(file_path, 'rb') as f:
            chunk = f.read(1024)  # Read first 1KB

            # Check for null bytes
            if b'\x00' in chunk:
                return True

            # Try to decode as text
            try:
                chunk.decode('utf-8')
                return False
            except UnicodeDecodeError:
                return True

    except Exception:
        return True

def is_binary_magic(file_path):
    """
    Use python-magic to check if a file is binary
    """
    try:
        import magic
        mime = magic.from_file(file_path, mime=True)
        return not mime.startswith('text/')
    except Exception:
        return True

# Try to import python-magic and set up the appropriate binary detection function
try:
    import magic
    print("Using python-magic for binary detection")
    is_binary = is_binary_magic
except ImportError:
    print("python-magic not available, using heuristic binary detection")
    is_binary = is_binary_heuristic

def process_directory(directory, ignore_dirs):
    """Process a directory and its subdirectories"""
    # Skip .git directories
    if os.path.basename(directory) in ignore_dirs:
        return

    # First, get all entries and sort them
    try:
        entries = sorted(os.listdir(directory))
    except PermissionError:
        print(f"Permission denied: {directory}")
        return

    # Print directory header
    print(f"\nDirectory: {directory}")
    print("total", len(entries))

    # Process all entries
    for entry in entries:
        # Skip .git directories at any level
        if entry in ignore_dirs:
            continue

        full_path = os.path.join(directory, entry)

        # Print ls -la style information
        try:
            print(get_file_details(full_path))

            # If it's a regular file and not binary, print its contents
            if os.path.isfile(full_path) and not is_binary(full_path):
                print("\n==> File contents of:", entry, "<==")
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        print(f.read())
                    print("=" * 40)
                except Exception as e:
                    print(f"Error reading file: {e}")

            # If it's a directory, recursively process it
            if os.path.isdir(full_path):
                process_directory(full_path, ignore_dirs)

        except Exception as e:
            print(f"Error processing {entry}: {e}")

def main():
    import sys

    if len(sys.argv) != 2:
        print("Usage: script.py <directory>")
        sys.exit(1)

    directory = sys.argv[1]
    if not os.path.isdir(directory):
        print(f"Error: {directory} is not a directory")
        sys.exit(1)
    IGNORE_DIRS = [
        ".git"
    ]
    process_directory(directory, ignore_dirs=IGNORE_DIRS)

if __name__ == "__main__":
    main()
