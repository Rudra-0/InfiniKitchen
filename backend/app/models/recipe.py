import datetime
from typing import List, Optional
from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, Float, ARRAY
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.sql import func
from app.models.base import Base

class RecipeIngredient(Base):
    __tablename__ = 'recipe_ingredients'
    recipe_id = Column(ForeignKey('recipes.id'), primary_key=True)
    ingredient_id = Column(ForeignKey('ingredients.id'), primary_key=True)
    quantity = Column(String, nullable=True)  # e.g., "200g", "1 cup"
    
    ingredient = relationship("Ingredient", back_populates="recipes")
    recipe = relationship("Recipe", back_populates="ingredients")

class Recipe(Base):
    __tablename__ = "recipes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String, index=True)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    instructions: Mapped[Optional[List[str]]] = mapped_column(ARRAY(String), nullable=True)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    ingredients: Mapped[List["RecipeIngredient"]] = relationship(back_populates="recipe")

class Ingredient(Base):
    __tablename__ = "ingredients"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String, unique=True, index=True)
    category: Mapped[Optional[str]] = mapped_column(String, index=True)
    
    # Relationships
    recipes: Mapped[List["RecipeIngredient"]] = relationship(back_populates="ingredient")
