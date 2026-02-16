from typing import List, Dict

class AllergenDetector:
    # Common allergens and their associated keywords
    # This list can be expanded or moved to a config file/database later
    ALLERGEN_KEYWORDS: Dict[str, List[str]] = {
        "Peanuts": ["peanut", "groundnut", "goober"],
        "Dairy": ["milk", "cream", "cheese", "butter", "yogurt", "whey", "casein", "lactose"],
        "Eggs": ["egg", "mayonnaise", "meringue", "albumin"],
        "Tree Nuts": ["almond", "walnut", "pecan", "cashew", "pistachio", "macadamia", "hazelnut"],
        "Soy": ["soy", "tofu", "edamame", "miso", "tempeh", "lecithin"],
        "Wheat/Gluten": ["wheat", "barley", "rye", "gluten", "flour", "bread", "pasta", "couscous", "seitan"],
        "Fish": ["fish", "salmon", "tuna", "cod", "anchovy", "sardine", "tilapia", "trout"],
        "Shellfish": ["shellfish", "shrimp", "oyster", "crab", "lobster", "clam", "mussel", "scallop"],
        "Sasame": ["sesame", "tahini"],
    }

    def detect_allergens(self, text: str) -> List[str]:
        """
        Scans the input text for allergen keywords and returns a list of detected allergen categories.
        """
        detected = set()
        text_lower = text.lower()

        for category, keywords in self.ALLERGEN_KEYWORDS.items():
            for keyword in keywords:
                # Basic substring matching for now.
                # In a robust system, we might want word boundary checks (regex \b)
                # to avoid false positives (e.g., "grape" matching "ape" if 'ape' was an allergen).
                # For this MVP, substring is acceptable but explicit word boundaries are safer.
                
                # Using simple check first
                if keyword in text_lower:
                     detected.add(category)
                     break # Found one keyword for this category, move to next category

        return sorted(list(detected))

allergen_detector = AllergenDetector()
