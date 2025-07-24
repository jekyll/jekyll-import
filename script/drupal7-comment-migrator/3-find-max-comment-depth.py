import os
import yaml

def get_max_depth(comment, current_depth=1):
    if not comment.get('replies'):
        return current_depth
    return max(get_max_depth(reply, current_depth + 1) for reply in comment['replies'])

def max_depth_in_file(filepath):
    with open(filepath, 'r') as f:
        data = yaml.safe_load(f)
        if not isinstance(data, list):
            return 0
        return max(get_max_depth(comment) for comment in data)

def overall_max_depth(directory):
    max_depth = 0
    for filename in os.listdir(directory):
        if filename.endswith('.yml') or filename.endswith('.yaml'):
            path = os.path.join(directory, filename)
            try:
                file_max = max_depth_in_file(path)
                print(f"{filename}: max depth = {file_max}")
                max_depth = max(max_depth, file_max)
            except Exception as e:
                print(f"Error processing {filename}: {e}")
    return max_depth

# Change this path to your actual _data/comments directory
directory_path = '_data/comments'
print(f"\nOverall max depth: {overall_max_depth(directory_path)}")
