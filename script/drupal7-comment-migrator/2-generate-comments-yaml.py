import csv
import os
import yaml
from datetime import datetime
from collections import defaultdict

INPUT_CSV = 'comments.csv'  # Adjust if your CSV is named differently
OUTPUT_DIR = '_data/comments/'

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Read and group comments by nid (Drupal node ID)
comments_by_nid = defaultdict(list)

with open(INPUT_CSV, newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        try:
            comment = {
                'cid': int(row['cid']),
                'pid': int(row['pid']),
                'name': row['name'] or 'Anonymous',
                'date': datetime.utcfromtimestamp(int(row['created'])).isoformat(),
                'body': row['comment_body_value'].strip(),
                'replies': []
            }
            nid = row['nid']
            comments_by_nid[nid].append(comment)
        except Exception as e:
            print(f"Error processing row {row}: {e}")

# Nest replies by cid/pid
for nid, comments in comments_by_nid.items():
    by_cid = {c['cid']: c for c in comments}
    top_level = []

    for comment in comments:
        if comment['pid'] == 0:
            top_level.append(comment)
        elif comment['pid'] in by_cid:
            by_cid[comment['pid']]['replies'].append(comment)
        else:
            # Orphaned reply — treat as top-level
            top_level.append(comment)

    # Write YAML file for this post
    output_path = os.path.join(OUTPUT_DIR, f'{nid}.yml')
    with open(output_path, 'w', encoding='utf-8') as f:
        yaml.dump(top_level, f, allow_unicode=True, sort_keys=False)

print(f"✅ Finished writing {len(comments_by_nid)} YAML files to {OUTPUT_DIR}")
