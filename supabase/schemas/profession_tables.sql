-- Create profession table
CREATE TABLE IF NOT EXISTS profession (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create profession_details table
CREATE TABLE IF NOT EXISTS profession_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    profession_id INT NOT NULL REFERENCES profession(id) ON DELETE CASCADE,
    regulatory_body TEXT,
    specialization TEXT,
    therapy_offered TEXT
);

-- Insert default profession data
INSERT INTO profession (id, name) VALUES
    (1, 'Neuropsychologist'),
    (2, 'Neurologist'),
    (3, 'Neuropsychiatrist'),
    (4, 'Child Specialist'),
    (5, 'Pediatrician')
ON CONFLICT (id) DO NOTHING;

-- Insert profession_details data
-- Regulatory Bodies
INSERT INTO profession_details (profession_id, regulatory_body) VALUES
    (1, 'CDSCO'),
    (2, 'NMC'),
    (3, 'TGA')
ON CONFLICT DO NOTHING;

-- Specializations
INSERT INTO profession_details (profession_id, specialization) VALUES
    (1, 'Neuropsychologist'),
    (2, 'Neurologist'),
    (3, 'Neuropsychiatrist'),
    (4, 'Child Specialist'),
    (5, 'Pediatrician')
ON CONFLICT DO NOTHING;

-- Therapies (you may need to add more based on your requirements)
INSERT INTO profession_details (profession_id, therapy_offered) VALUES
    (1, 'Cognitive Behavioral Therapy'),
    (1, 'Neuropsychological Assessment'),
    (2, 'Neurological Assessment'),
    (3, 'Psychiatric Assessment'),
    (4, 'Child Development Therapy'),
    (5, 'Pediatric Care')
ON CONFLICT DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profession_details_profession_id ON profession_details(profession_id);
