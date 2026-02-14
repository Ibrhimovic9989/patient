-- Seed Assessments Table with AQ-10 and CAT-Q
-- This script populates the assessments table with autism screening questionnaires

-- Insert AQ-10 Assessment
INSERT INTO assessments (name, description, category, cutoff_score, image_url, questions) VALUES (
  'Autism Spectrum Quotient (AQ-10)',
  'A brief screening tool for autism spectrum traits in adults aged 16 and over. It consists of 10 statements to assess behaviors and preferences.',
  'Autism Assessment',
  6,
  NULL, -- Image URL can be added later when images are uploaded to Supabase Storage
  '[
    {
      "question_id": "aq10_q1",
      "text": "I often notice small sounds when others do not",
      "options": [
        { "option_id": "aq10_q1_o1", "text": "Definitely agree", "score": 1 },
        { "option_id": "aq10_q1_o2", "text": "Slightly agree", "score": 1 },
        { "option_id": "aq10_q1_o3", "text": "Slightly disagree", "score": 0 },
        { "option_id": "aq10_q1_o4", "text": "Definitely disagree", "score": 0 }
      ]
    },
    {
      "question_id": "aq10_q2",
      "text": "I usually concentrate more on the whole picture, rather than the small details",
      "options": [
        { "option_id": "aq10_q2_o1", "text": "Definitely agree", "score": 0 },
        { "option_id": "aq10_q2_o2", "text": "Slightly agree", "score": 0 },
        { "option_id": "aq10_q2_o3", "text": "Slightly disagree", "score": 1 },
        { "option_id": "aq10_q2_o4", "text": "Definitely disagree", "score": 1 }
      ]
    },
    {
      "question_id": "aq10_q3",
      "text": "I find it easy to do more than one thing at once",
      "options": [
        { "option_id": "aq10_q3_o1", "text": "Definitely agree", "score": 0 },
        { "option_id": "aq10_q3_o2", "text": "Slightly agree", "score": 0 },
        { "option_id": "aq10_q3_o3", "text": "Slightly disagree", "score": 1 },
        { "option_id": "aq10_q3_o4", "text": "Definitely disagree", "score": 1 }
      ]
    },
    {
      "question_id": "aq10_q4",
      "text": "If there is an interruption, I can switch back to what I was doing very quickly",
      "options": [
        { "option_id": "aq10_q4_o1", "text": "Definitely agree", "score": 0 },
        { "option_id": "aq10_q4_o2", "text": "Slightly agree", "score": 0 },
        { "option_id": "aq10_q4_o3", "text": "Slightly disagree", "score": 1 },
        { "option_id": "aq10_q4_o4", "text": "Definitely disagree", "score": 1 }
      ]
    },
    {
      "question_id": "aq10_q5",
      "text": "I find it easy to read between the lines when someone is talking to me",
      "options": [
        { "option_id": "aq10_q5_o1", "text": "Definitely agree", "score": 0 },
        { "option_id": "aq10_q5_o2", "text": "Slightly agree", "score": 0 },
        { "option_id": "aq10_q5_o3", "text": "Slightly disagree", "score": 1 },
        { "option_id": "aq10_q5_o4", "text": "Definitely disagree", "score": 1 }
      ]
    },
    {
      "question_id": "aq10_q6",
      "text": "I know how to tell if someone listening to me is getting bored",
      "options": [
        { "option_id": "aq10_q6_o1", "text": "Definitely agree", "score": 0 },
        { "option_id": "aq10_q6_o2", "text": "Slightly agree", "score": 0 },
        { "option_id": "aq10_q6_o3", "text": "Slightly disagree", "score": 1 },
        { "option_id": "aq10_q6_o4", "text": "Definitely disagree", "score": 1 }
      ]
    },
    {
      "question_id": "aq10_q7",
      "text": "When I''m reading a story, I find it difficult to work out the characters'' intentions",
      "options": [
        { "option_id": "aq10_q7_o1", "text": "Definitely agree", "score": 1 },
        { "option_id": "aq10_q7_o2", "text": "Slightly agree", "score": 1 },
        { "option_id": "aq10_q7_o3", "text": "Slightly disagree", "score": 0 },
        { "option_id": "aq10_q7_o4", "text": "Definitely disagree", "score": 0 }
      ]
    },
    {
      "question_id": "aq10_q8",
      "text": "I like to collect information about categories of things (e.g., types of car, types of bird, types of train, types of plant, etc.)",
      "options": [
        { "option_id": "aq10_q8_o1", "text": "Definitely agree", "score": 1 },
        { "option_id": "aq10_q8_o2", "text": "Slightly agree", "score": 1 },
        { "option_id": "aq10_q8_o3", "text": "Slightly disagree", "score": 0 },
        { "option_id": "aq10_q8_o4", "text": "Definitely disagree", "score": 0 }
      ]
    },
    {
      "question_id": "aq10_q9",
      "text": "I find it easy to work out what someone is thinking or feeling just by looking at their face",
      "options": [
        { "option_id": "aq10_q9_o1", "text": "Definitely agree", "score": 0 },
        { "option_id": "aq10_q9_o2", "text": "Slightly agree", "score": 0 },
        { "option_id": "aq10_q9_o3", "text": "Slightly disagree", "score": 1 },
        { "option_id": "aq10_q9_o4", "text": "Definitely disagree", "score": 1 }
      ]
    },
    {
      "question_id": "aq10_q10",
      "text": "I find it difficult to work out people''s intentions",
      "options": [
        { "option_id": "aq10_q10_o1", "text": "Definitely agree", "score": 1 },
        { "option_id": "aq10_q10_o2", "text": "Slightly agree", "score": 1 },
        { "option_id": "aq10_q10_o3", "text": "Slightly disagree", "score": 0 },
        { "option_id": "aq10_q10_o4", "text": "Definitely disagree", "score": 0 }
      ]
    }
  ]'::jsonb
) ON CONFLICT DO NOTHING;

-- Insert CAT-Q Assessment (simplified version - you can add more questions later)
INSERT INTO assessments (name, description, category, cutoff_score, image_url, questions) VALUES (
  'Camouflaging Autistic Traits Questionnaire (CAT-Q)',
  'A self-report measure of social camouflaging behaviors in autistic and non-autistic adults.',
  'Autism Assessment',
  100,
  NULL, -- Image URL can be added later when images are uploaded to Supabase Storage
  '[
    {
      "question_id": "catq_q1",
      "text": "In social situations, I feel like I am pretending to be ''normal''.",
      "options": [
        { "option_id": "catq_q1_o1", "text": "Strongly Disagree", "score": 1 },
        { "option_id": "catq_q1_o2", "text": "Disagree", "score": 2 },
        { "option_id": "catq_q1_o3", "text": "Somewhat Disagree", "score": 3 },
        { "option_id": "catq_q1_o4", "text": "Neither Agree nor Disagree", "score": 4 },
        { "option_id": "catq_q1_o5", "text": "Somewhat Agree", "score": 5 },
        { "option_id": "catq_q1_o6", "text": "Agree", "score": 6 },
        { "option_id": "catq_q1_o7", "text": "Strongly Agree", "score": 7 }
      ]
    },
    {
      "question_id": "catq_q2",
      "text": "When talking to other people, I feel like the conversation flows naturally.",
      "options": [
        { "option_id": "catq_q2_o1", "text": "Strongly Disagree", "score": 7 },
        { "option_id": "catq_q2_o2", "text": "Disagree", "score": 6 },
        { "option_id": "catq_q2_o3", "text": "Somewhat Disagree", "score": 5 },
        { "option_id": "catq_q2_o4", "text": "Neither Agree nor Disagree", "score": 4 },
        { "option_id": "catq_q2_o5", "text": "Somewhat Agree", "score": 3 },
        { "option_id": "catq_q2_o6", "text": "Agree", "score": 2 },
        { "option_id": "catq_q2_o7", "text": "Strongly Agree", "score": 1 }
      ]
    },
    {
      "question_id": "catq_q3",
      "text": "I have spent time learning social skills from television shows and films, and try to use these in my interactions.",
      "options": [
        { "option_id": "catq_q3_o1", "text": "Strongly Disagree", "score": 1 },
        { "option_id": "catq_q3_o2", "text": "Disagree", "score": 2 },
        { "option_id": "catq_q3_o3", "text": "Somewhat Disagree", "score": 3 },
        { "option_id": "catq_q3_o4", "text": "Neither Agree nor Disagree", "score": 4 },
        { "option_id": "catq_q3_o5", "text": "Somewhat Agree", "score": 5 },
        { "option_id": "catq_q3_o6", "text": "Agree", "score": 6 },
        { "option_id": "catq_q3_o7", "text": "Strongly Agree", "score": 7 }
      ]
    },
    {
      "question_id": "catq_q4",
      "text": "In social interactions, I do not pay attention to what my face or body are doing.",
      "options": [
        { "option_id": "catq_q4_o1", "text": "Strongly Disagree", "score": 7 },
        { "option_id": "catq_q4_o2", "text": "Disagree", "score": 6 },
        { "option_id": "catq_q4_o3", "text": "Somewhat Disagree", "score": 5 },
        { "option_id": "catq_q4_o4", "text": "Neither Agree nor Disagree", "score": 4 },
        { "option_id": "catq_q4_o5", "text": "Somewhat Agree", "score": 3 },
        { "option_id": "catq_q4_o6", "text": "Agree", "score": 2 },
        { "option_id": "catq_q4_o7", "text": "Strongly Agree", "score": 1 }
      ]
    },
    {
      "question_id": "catq_q5",
      "text": "In social situations, I feel like I am pretending to be ''normal''.",
      "options": [
        { "option_id": "catq_q5_o1", "text": "Strongly Disagree", "score": 1 },
        { "option_id": "catq_q5_o2", "text": "Disagree", "score": 2 },
        { "option_id": "catq_q5_o3", "text": "Somewhat Disagree", "score": 3 },
        { "option_id": "catq_q5_o4", "text": "Neither Agree nor Disagree", "score": 4 },
        { "option_id": "catq_q5_o5", "text": "Somewhat Agree", "score": 5 },
        { "option_id": "catq_q5_o6", "text": "Agree", "score": 6 },
        { "option_id": "catq_q5_o7", "text": "Strongly Agree", "score": 7 }
      ]
    }
  ]'::jsonb
) ON CONFLICT DO NOTHING;

-- Verify the data was inserted
SELECT name, category, cutoff_score, jsonb_array_length(questions) as question_count 
FROM assessments;
