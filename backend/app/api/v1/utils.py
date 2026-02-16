from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

from app.services.hash_service import generate_ingredient_hash

router = APIRouter()

class IngredientList(BaseModel):
    ingredients: List[str]

class HashResponse(BaseModel):
    hash: str
    normalized_string: str # returning this for debug purposes

@router.post("/hash", response_model=HashResponse)
def get_ingredient_hash(payload: IngredientList):
    """
    Returns the deterministic hash for the given list of ingredients.
    Useful for client checking if a recipe already exists.
    """
    # Isolate logic to service
    # We reconstruct the string here just for debug return, 
    # but in prod we might not need 'normalized_string' in response.
    
    # Re-implementing the join logic just for the debug field if we want it,
    # or better, update the service to return both if needed.
    # For now, let's keep it simple and just call the service for the hash.
    
    hashed_value = generate_ingredient_hash(payload.ingredients)
    
    # For debugging visualization (optional, can remove later)
    normalized = [i.strip().lower() for i in payload.ingredients if i.strip()]
    normalized.sort()
    serialized = "|".join(normalized)

    return HashResponse(hash=hashed_value, normalized_string=serialized)

from app.services.allergen_service import allergen_detector

class AllergenRequest(BaseModel):
    text: str

class AllergenResponse(BaseModel):
    allergens: List[str]

@router.post("/detect-allergens", response_model=AllergenResponse)
def detect_allergens(payload: AllergenRequest):
    """
    Scans the input text for common allergens.
    """
    detected = allergen_detector.detect_allergens(payload.text)
    return AllergenResponse(allergens=detected)
