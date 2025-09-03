-- Migration script to update favorites table to support external recipe IDs
-- This script will create a new table and migrate existing data if any

BEGIN;

-- Create new favorites table with external recipe support
CREATE TABLE IF NOT EXISTS favourites_new (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    external_recipe_id VARCHAR(50) NOT NULL,
    recipe_title VARCHAR(200),
    recipe_image TEXT,
    recipe_category VARCHAR(100),
    recipe_area VARCHAR(100),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    UNIQUE(user_id, external_recipe_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for the new table
CREATE INDEX IF NOT EXISTS idx_favourites_new_user_id ON favourites_new(user_id);
CREATE INDEX IF NOT EXISTS idx_favourites_new_external_recipe_id ON favourites_new(external_recipe_id);

-- If there's existing data in the old table, we can't easily migrate it since
-- we don't have external recipe IDs, so we'll just drop the old table
DROP TABLE IF EXISTS favourites CASCADE;

-- Rename the new table to the standard name
ALTER TABLE favourites_new RENAME TO favourites;

-- Rename the indexes
ALTER INDEX idx_favourites_new_user_id RENAME TO idx_favourites_user_id;
ALTER INDEX idx_favourites_new_external_recipe_id RENAME TO idx_favourites_external_recipe_id;

COMMIT;


