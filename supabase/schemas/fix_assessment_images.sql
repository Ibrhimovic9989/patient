-- Fix assessment image URLs (set to NULL to remove broken URLs)
-- Run this if you see ERR_NAME_NOT_RESOLVED errors for assessment images

UPDATE assessments 
SET image_url = NULL 
WHERE image_url LIKE '%gezbvdcskabwweanvfhu%' 
   OR image_url LIKE '%ouzgddcxfynjhwjnvdtb%';

-- Verify
SELECT name, image_url FROM assessments;
