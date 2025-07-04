-- Beispieldaten für Prometheus Influencer Discovery Dashboard
-- Führe dieses SQL NACH dem Schema aus

-- Team-Mitglieder einfügen
INSERT INTO team_members (name, email, avatar, role) VALUES
  ('Sarah Martinez', 'sarah.martinez@prometheus.com', 'SM', 'manager'),
  ('Tom Wilson', 'tom.wilson@prometheus.com', 'TW', 'specialist'),
  ('Lisa Chen', 'lisa.chen@prometheus.com', 'LC', 'analyst'),
  ('Max Müller', 'max.mueller@prometheus.com', 'MM', 'coordinator');

-- Influencer-Daten einfügen (neues Schema)
INSERT INTO influencers (
  name, handle, bio, follower_count, engagement_rate, post_count, 
  status, assigned_to, last_contact_date, notes, category_tags, 
  email, instagram_url
) VALUES
  (
    'Aleksandra | Lifestyle Coach', 
    '@aleksfit_', 
    'Certified fitness coach specializing in women''s health and lifestyle transformation. 💪✨',
    89700, 
    4.2, 
    1240,
    'contacted', 
    'Sarah Martinez', 
    NOW() - INTERVAL '2 days',
    'Sehr responsiv und professionell. Interesse an langfristiger Partnerschaft geäußert.',
    ARRAY['fitness','female','dach','lifestyle'],
    'aleksandra.fitness@gmail.com',
    'https://instagram.com/aleksfit_'
  ),
  (
    'Max | Personal Trainer', 
    '@maxfitness', 
    'Personal trainer helping people achieve their strength goals. 🏋️‍♂️ Based in Munich.',
    156000, 
    3.8, 
    890,
    'new_lead', 
    'Tom Wilson', 
    NULL,
    'Großes Potential aufgrund hoher Follower-Zahl. Spezialisiert auf Krafttraining.',
    ARRAY['fitness','male','dach','strength'],
    'max.training@gmail.com',
    'https://instagram.com/maxfitness'
  ),
  (
    'Lisa | Yoga & Mindfulness', 
    '@liveyoga', 
    'Yoga instructor & mindfulness coach. Finding balance in busy lives 🧘‍♀️🌿',
    73000, 
    5.1, 
    2100,
    'negotiating', 
    'Sarah Martinez', 
    NOW() - INTERVAL '5 hours',
    'Verhandlungen über Exclusive Partnership. Sehr hohe Engagement-Rate.',
    ARRAY['fitness','yoga','female','wellness','mindfulness'],
    'lisa.yoga@gmail.com',
    'https://instagram.com/liveyoga'
  ),
  (
    'John | Strength Coach', 
    '@johntraining', 
    'Strength & conditioning coach. Helping athletes reach peak performance.',
    42000, 
    6.3, 
    650,
    'partner', 
    'Tom Wilson', 
    NULL,
    'Aktiver Partner seit 3 Monaten. Überdurchschnittliche Performance bei Kampagnen.',
    ARRAY['fitness','strength','male','dach'],
    'john.strength@gmail.com',
    'https://instagram.com/johntraining'
  ),
  (
    'Marie | Fitness Guru', 
    '@fitnessguru_marie', 
    'Fitness enthusiast & nutrition expert. Transforming lives through health 💖',
    234000, 
    3.9, 
    1560,
    'new_lead',
    'Lisa Chen',
    NULL,
    'Neu entdeckt durch AI-Analyse. Sehr starker Content im Nutrition-Bereich.',
    ARRAY['fitness','female','nutrition','wellness'],
    'marie.fitness@gmail.com',
    'https://instagram.com/fitnessguru_marie'
  ),
  (
    'Marcus | Lifestyle & Fitness', 
    '@stronglifestyle', 
    'Lifestyle blogger focusing on fitness, fashion & motivation. Join the journey! 🚀',
    187000, 
    4.7, 
    980,
    'partner',
    'Max Müller',
    NOW() - INTERVAL '1 week',
    'Top-Partner mit exzellenten Conversion-Raten. Fokus auf Premium-Produkte.',
    ARRAY['fitness','lifestyle','male','fashion'],
    'marcus.lifestyle@gmail.com',
    'https://instagram.com/stronglifestyle'
  );

-- Aktivitäten einfügen
INSERT INTO activities (type, content, value, avatar, created_at) VALUES
  ('discovery', 'New influencer discovered', '@fitnessguru_marie', 'I', NOW() - INTERVAL '2 hours'),
  ('partnership', 'Partnership confirmed', '@stronglifestyle', 'P', NOW() - INTERVAL '4 hours'),
  ('revenue', 'Revenue milestone reached', '€2,500', 'R', NOW() - INTERVAL '1 day'),
  ('outreach', 'Positive response received', '@yoga_with_anna', 'O', NOW() - INTERVAL '1 day'),
  ('campaign', 'Campaign launched', 'Summer Fitness 2025', 'C', NOW() - INTERVAL '2 days'),
  ('discovery', 'AI found potential match', '@wellness_warrior', 'I', NOW() - INTERVAL '3 days'),
  ('partnership', 'Contract signed', '@johntraining', 'P', NOW() - INTERVAL '1 week'),
  ('outreach', 'Initial contact made', '@powerlift_pro', 'O', NOW() - INTERVAL '1 week'),
  ('revenue', 'Commission earned', '€850', 'R', NOW() - INTERVAL '10 days'),
  ('discovery', 'Manual addition', '@aleksfit_', 'I', NOW() - INTERVAL '2 weeks');

-- Detaillierte Notizen hinzufügen
INSERT INTO influencer_notes (influencer_id, author, content) 
SELECT i.id, 'Sarah Martinez', 'Erstkontakt sehr positiv verlaufen. Interesse an Protein-Produkten.' 
FROM influencers i WHERE i.handle = '@aleksfit_';

INSERT INTO influencer_notes (influencer_id, author, content) 
SELECT i.id, 'Tom Wilson', 'Follower-Analyse zeigt 78% weibliche Zielgruppe, Alter 25-35.' 
FROM influencers i WHERE i.handle = '@liveyoga';

INSERT INTO influencer_notes (influencer_id, author, content) 
SELECT i.id, 'Max Müller', 'Q4 Performance: 12% Conversion-Rate, €1,240 Revenue generiert.' 
FROM influencers i WHERE i.handle = '@johntraining';

INSERT INTO influencer_notes (influencer_id, author, content) 
SELECT i.id, 'Lisa Chen', 'AI-Score: 94/100. Predicted Engagement: 4.1%. Empfehlung: High Priority.' 
FROM influencers i WHERE i.handle = '@fitnessguru_marie';

-- Weitere Demo-Influencer für größere Datenmenge
insert into influencers (handle, name, avatar, verified, status, followers, engagement_rate, categories, assigned_to, last_contact)
values
  ('@healthy_hannah', 'Hannah | Healthy Living', 'HH', false, 'new', 45000, 6.1, ARRAY['Lifestyle','Female','Nutrition'], 'Lisa Chen', null),
  ('@muscle_mike', 'Mike | Muscle Building', 'MM', true, 'contacted', 198000, 3.2, ARRAY['Fitness','Male','Bodybuilding'], 'Tom Wilson', now() - interval '5 days'),
  ('@cardio_queen', 'Queen of Cardio', 'CQ', true, 'new', 112000, 4.8, ARRAY['Fitness','Female','Cardio'], 'Sarah Martinez', null),
  ('@nutrition_ninja', 'Nutrition Expert', 'NN', false, 'negotiating', 89000, 5.3, ARRAY['Nutrition','Health','Education'], 'Lisa Chen', now() - interval '2 days'),
  ('@crossfit_chris', 'Chris | CrossFit Athlete', 'CC', true, 'partner', 156000, 4.4, ARRAY['Fitness','CrossFit','Male'], 'Max Müller', now() - interval '1 month');

-- Weitere Aktivitäten für realistischere Timeline
insert into activities (type, content, value, avatar, created_at) values
  ('discovery', 'Trending hashtag analysis', '#FitnessMotivation', 'T', now() - interval '5 hours'),
  ('outreach', 'Follow-up email sent', '@muscle_mike', 'O', now() - interval '6 hours'),
  ('analytics', 'Weekly report generated', '247 total influencers', 'A', now() - interval '8 hours'),
  ('partnership', 'Trial period started', '@cardio_queen', 'P', now() - interval '12 hours'),
  ('discovery', 'Competitor analysis', 'FitnessBrand X', 'C', now() - interval '1 day'),
  ('revenue', 'Monthly target achieved', '€5,000', 'R', now() - interval '3 days'),
  ('outreach', 'Instagram DM sent', '@healthy_hannah', 'O', now() - interval '4 days'),
  ('analytics', 'Engagement rate analysis', 'Q1 2025 Report', 'A', now() - interval '5 days');
