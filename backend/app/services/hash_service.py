import hashlib
from typing import List

def generate_ingredient_hash(ingredients: List[str]) -> str:
    """
    Generates a deterministic hash for a list of ingredients.
    
    The process:
    1. Normalize: Lowercase and strip whitespace.
    2. Sort: Alphabetically to ensure order doesn't matter.
    3. Join: Create a single string delimited by '|'.
    4. Hash: Generate an MD5 hash of the string.
    """
    if not ingredients:
        return ""

    # 1. Normalize
    normalized = [i.strip().lower() for i in ingredients if i.strip()]
    
    # 2. Sort
    normalized.sort()
    
    # 3. Join
    serialized = "|".join(normalized)
    
    # 4. Hash
    return hashlib.md5(serialized.encode("utf-8")).hexdigest()
