-- =====================================================
-- 16. FAKE GIRL PROFILES (50 Seed Profiles)
-- Seeds 50 realistic female profiles for app demo/testing.
-- All profiles have 100% completion with culturally
-- appropriate Banjara community data.
--
-- ⚠️ Run in Supabase SQL Editor (bypasses RLS as postgres).
-- ⚠️ Run AFTER 01_profiles, 02_photos, 08_subscriptions.
-- Idempotent: safe to re-run (ON CONFLICT skips).
--
-- 🗑️ CLEANUP (removes ALL fake data):
--   DELETE FROM auth.users WHERE email LIKE 'fake_girl_%@banjarabio.com';
-- =====================================================
-- Step 1: Create 50 auth users
-- (Supabase auth.users requires id, email, encrypted_password, role, aud, etc.)
DO $$
DECLARE v_user_id UUID;
v_profile_id UUID;
i INTEGER;
v_email TEXT;
-- Arrays for realistic data distribution
v_names TEXT [] := ARRAY [
        'Priya', 'Sneha', 'Anjali', 'Pooja', 'Neha',
        'Swati', 'Komal', 'Rina', 'Kavita', 'Manisha',
        'Sunita', 'Rekha', 'Aarti', 'Savita', 'Meena',
        'Lata', 'Suman', 'Deepa', 'Geeta', 'Rani',
        'Pallavi', 'Archana', 'Bhavna', 'Chhaya', 'Divya',
        'Ekta', 'Fatima', 'Gauri', 'Heena', 'Isha',
        'Jyoti', 'Kiran', 'Lakshmi', 'Madhuri', 'Nandini',
        'Omika', 'Pratibha', 'Ranjana', 'Sarika', 'Tanvi',
        'Uma', 'Vaishali', 'Warda', 'Yamini', 'Zara',
        'Shruti', 'Nikita', 'Rashmi', 'Vandana', 'Padma'
    ];
v_surnames TEXT [] := ARRAY [
        'Rathod','Rathod','Rathod','Rathod','Rathod',
        'Rathod','Rathod','Rathod','Rathod','Rathod',
        'Rathod','Rathod','Rathod','Rathod','Rathod',
        'Chauhan','Chauhan','Chauhan','Chauhan','Chauhan',
        'Chauhan','Chauhan','Chauhan','Chauhan','Chauhan',
        'Jadhav','Jadhav','Jadhav','Jadhav','Jadhav',
        'Jadhav','Jadhav','Jadhav','Jadhav','Jadhav',
        'Pawar','Pawar','Pawar','Pawar','Pawar',
        'Pawar','Pawar','Pawar',
        'Ade','Ade','Ade','Ade','Ade',
        'Naik','Naik'
    ];
v_gotras TEXT [] := ARRAY [
        'Bhaanaavath','Kumaavath','Raamavath','Sangaavath','Kodaavath',
        'Meghaavath','Nenaavath','Depaavath','Raajavath','Khaatroth',
        'Devsoth','Bhilavath','Karamtoth','Aaloth','Kholavath',
        'Dumaavath / Chauradiya','Keluth','Lavidiya / Lavhadiya','Sabavat','Korra / Kurra / Mood',
        'Paalthyaa','Dumaavath / Chauradiya','Keluth','Sabavat','Lavidiya / Lavhadiya',
        'Ajmera','Gugloth','Maaloth','Salaavath','Barmaavath',
        'Dhaaraavath','Gangaavath','Bharoth','Tejaavath','Lokaavath',
        'Aamgoth','Injraavath','Vislaavath','Vankdoth','Baanni',
        'Chaivoth / Pammar','Jharapla','Lunsavath / Nunsavath',
        'Rupavath','Mudavath','Dheeravath','Baanoth','Daanaavath',
        NULL, NULL
    ];
v_ages INTEGER [] := ARRAY [
        22, 23, 24, 25, 21, 26, 27, 23, 24, 25,
        22, 28, 23, 26, 24, 25, 22, 27, 23, 24,
        21, 26, 25, 28, 23, 24, 22, 25, 27, 26,
        23, 24, 21, 25, 22, 26, 23, 27, 24, 25,
        28, 22, 23, 24, 25, 26, 21, 27, 23, 24
    ];
v_dobs DATE [] := ARRAY [
        '2004-03-15','2003-07-22','2002-11-08','2001-01-14','2005-06-30',
        '2000-09-12','1999-04-25','2003-12-03','2002-08-17','2001-05-21',
        '2004-02-28','1998-10-09','2003-06-11','2000-03-07','2002-07-19',
        '2001-11-24','2004-01-16','1999-08-30','2003-04-05','2002-09-13',
        '2005-05-18','2000-12-22','2001-02-09','1998-07-14','2003-10-27',
        '2002-06-03','2004-04-20','2001-08-11','1999-12-16','2000-11-01',
        '2003-03-28','2002-05-15','2005-01-07','2001-10-23','2004-08-06',
        '2000-04-19','2003-09-02','1999-06-14','2002-12-25','2001-07-08',
        '1998-11-17','2004-05-30','2003-02-12','2002-10-04','2001-04-27',
        '2000-08-13','2005-03-21','1999-10-06','2003-07-31','2002-01-18'
    ];
v_heights TEXT [] := ARRAY [
        '5''2"','5''3"','5''1"','5''4"','5''0"',
        '5''5"','5''3"','5''2"','5''4"','5''1"',
        '5''6"','5''0"','5''3"','5''2"','5''4"',
        '5''1"','5''5"','5''3"','5''2"','5''4"',
        '5''0"','5''6"','5''3"','5''1"','5''2"',
        '5''4"','5''5"','5''3"','5''2"','5''1"',
        '5''0"','5''4"','5''7"','5''3"','5''2"',
        '5''1"','5''5"','5''3"','5''4"','5''2"',
        '5''6"','5''0"','5''3"','5''1"','5''4"',
        '5''2"','4''11"','5''5"','5''3"','5''2"'
    ];
v_complexions TEXT [] := ARRAY [
        'Fair','Wheatish','Fair','Very Fair','Wheatish',
        'Fair','Dusky','Fair','Wheatish','Fair',
        'Very Fair','Wheatish','Fair','Dusky','Fair',
        'Wheatish','Fair','Very Fair','Fair','Wheatish',
        'Fair','Dusky','Wheatish','Fair','Very Fair',
        'Fair','Wheatish','Fair','Dusky','Wheatish',
        'Fair','Very Fair','Fair','Wheatish','Fair',
        'Dusky','Fair','Wheatish','Very Fair','Fair',
        'Wheatish','Fair','Dusky','Fair','Very Fair',
        'Wheatish','Fair','Dusky','Fair','Wheatish'
    ];
v_blood_groups TEXT [] := ARRAY [
        'B+','A+','O+','AB+','B+',
        'A+','O+','B-','A+','O+',
        'AB+','B+','A-','O+','B+',
        'A+','AB+','O+','B+','A+',
        'O-','B+','A+','O+','AB-',
        'B+','A+','O+','B+','A+',
        'O+','AB+','B+','A+','O+',
        'B-','A+','O+','B+','AB+',
        'A+','O+','B+','A-','O+',
        'B+','AB+','A+','O+','B+'
    ];
v_educations TEXT [] := ARRAY [
        'B.Com','MBA','B.Ed','MBBS','BE',
        'BA','MSc','MA','B.Pharm','BCA',
        'B.Tech','M.Ed','BSc Nursing','B.Com','MBA',
        'BA','MSW','BCA','B.Ed','MA',
        'MBBS','BE','MBA','BSc','B.Com',
        'B.Pharm','MA','BCA','MSc','B.Ed',
        'BA','B.Tech','MBBS','MBA','BSc',
        'B.Com','MA','BE','BCA','B.Ed',
        'MSW','B.Pharm','BA','MBA','BSc Nursing',
        'B.Com','B.Tech','MA','BSc','BCA'
    ];
v_education_details TEXT [] := ARRAY [
        'B.Com from Nagpur University','MBA in Finance from SPPU Pune','B.Ed from RTM Nagpur University','MBBS from GMC Nagpur','BE in Computer Science from VNIT',
        'BA in Marathi Literature from Aurangabad University','MSc in Chemistry from RTM Nagpur University','MA in Sociology from Amravati University','B.Pharm from UDPS Nagpur','BCA from Nagpur University',
        'B.Tech in IT from COEP Pune','M.Ed from SNDT Mumbai','BSc Nursing from AIIMS Nagpur','B.Com from Kolhapur University','MBA in HR from Symbiosis Pune',
        'BA in Hindi from Bhopal University','MSW from TISS Mumbai','BCA from Osmania University Hyderabad','B.Ed from Bangalore University','MA in English from Mumbai University',
        'MBBS from KMC Manipal','BE in Electronics from Pune University','MBA in Marketing from IIM Nagpur','BSc in Biology from Nashik University','B.Com from Aurangabad University',
        'B.Pharm from Hyderabad University','MA in Economics from Nagpur University','BCA from Amravati University','MSc in Physics from IIT Bombay','B.Ed from Kolhapur University',
        'BA in Political Science from Nagpur University','B.Tech in Mechanical from NIT Nagpur','MBBS from AFMC Pune','MBA from SP Jain Mumbai','BSc in Mathematics from Pune University',
        'B.Com from MP Bhoj University','MA in History from Nagpur University','BE in Civil from VJTI Mumbai','BCA from Bangalore University','B.Ed from Hyderabad University',
        'MSW from Nagpur University','B.Pharm from Nashik University','BA in Psychology from Pune University','MBA in Operations from NITIE Mumbai','BSc Nursing from CMC Vellore',
        'B.Com from Nagpur University','B.Tech in CSE from MIT Pune','MA in Sanskrit from BHU','BSc in Microbiology from Amravati University','BCA from Indore University'
    ];
v_professions TEXT [] := ARRAY [
        'Accountant','Business Analyst','Teacher','Doctor','Software Engineer',
        'Content Writer','Lab Technician','Social Worker','Pharmacist','Web Developer',
        'IT Consultant','School Principal','Staff Nurse','Bank Officer','HR Manager',
        'Journalist','Counsellor','Data Analyst','Primary Teacher','Lecturer',
        'Surgeon','Electronics Engineer','Marketing Manager','Research Assistant','CA Intern',
        'Hospital Pharmacist','Economist','App Developer','Physics Researcher','Headmistress',
        'Government Officer','Mechanical Engineer','Pediatrician','Operations Manager','Maths Teacher',
        'Shopkeeper','Museum Curator','Civil Engineer','UX Designer','Kindergarten Teacher',
        'NGO Coordinator','Medical Rep','Clinical Psychologist','Supply Chain Analyst','ICU Nurse',
        'Chartered Accountant','Full Stack Developer','Sanskrit Lecturer','Microbiologist','MCA Student'
    ];
v_job_details TEXT [] := ARRAY [
        'Works at Deloitte Nagpur office','Business analyst at TCS Pune','Government school teacher in Nagpur','Resident doctor at GMC Nagpur','Works at Infosys Pune',
        'Freelance content writer','Lab tech at Orange City Hospital','Works with NGO in rural Maharashtra','Pharmacist at Apollo Pharmacy','Web developer at local startup',
        'IT consultant at Wipro Hyderabad','Principal at DAV School Nagpur','Staff nurse at Wockhardt Hospital','SBI bank officer Amravati branch','HR manager at Mahindra Mumbai',
        'Reporter at Lokmat newspaper','School counsellor at Ryan International','Data analyst at Accenture Bangalore','Teaches at ZP school near Yavatmal','Assistant professor at RTMNU',
        'Surgeon at Lata Mangeshkar Hospital','Engineer at BHEL Bhopal','Marketing at Asian Paints Mumbai','Research at ICAR Nagpur','Pursuing CA articleship in Nagpur',
        'Pharmacist at Medicover Hospital Hyderabad','Government economist at RBI Nagpur','Developer at Tech Mahindra Pune','Researcher at IIT Bombay','Principal at Nutan Vidyalaya Nashik',
        'MPSC officer at Mantralaya','Mechanical engineer at L&T Pune','Pediatrician at Rainbow Hospital','Ops manager at Flipkart Bangalore','Maths teacher at Kendriya Vidyalaya',
        'Family kirana shop in Kolhapur','Curator at Nagpur Museum','Civil engineer at PWD Maharashtra','UX designer at Freshworks Chennai','Runs kindergarten in Aurangabad',
        'Coordinator at Pratham NGO','Medical rep for Cipla','Clinical psychologist at private clinic','Analyst at Amazon Hyderabad','ICU nurse at Fortis Hospital Mumbai',
        'CA at KPMG Pune','Developer at Google Hyderabad','Lecturer at Sanskrit Mahavidyalaya','Microbiologist at NEERI Nagpur','Pursuing MCA at NIT Nagpur'
    ];
v_companies TEXT [] := ARRAY [
        'Deloitte','TCS','Government School','GMC Nagpur','Infosys',
        'Freelance','Orange City Hospital','Rural NGO Maharashtra','Apollo Pharmacy','Local Startup',
        'Wipro','DAV School','Wockhardt Hospital','SBI','Mahindra',
        'Lokmat','Ryan International','Accenture','ZP School','RTMNU',
        'Lata Mangeshkar Hospital','BHEL','Asian Paints','ICAR','CA Firm',
        'Medicover Hospital','RBI','Tech Mahindra','IIT Bombay','Nutan Vidyalaya',
        'Government of Maharashtra','L&T','Rainbow Hospital','Flipkart','KV School',
        'Family Business','Nagpur Museum','PWD Maharashtra','Freshworks','Own School',
        'Pratham NGO','Cipla','Private Clinic','Amazon','Fortis Hospital',
        'KPMG','Google','Sanskrit Mahavidyalaya','NEERI','NIT Nagpur'
    ];
v_annual_incomes TEXT [] := ARRAY [
        '5-7 LPA','6-8 LPA','3-4 LPA','8-10 LPA','7-9 LPA',
        '2-3 LPA','3-4 LPA','2-3 LPA','4-5 LPA','5-6 LPA',
        '8-10 LPA','5-6 LPA','4-5 LPA','5-7 LPA','7-9 LPA',
        '3-4 LPA','4-5 LPA','6-8 LPA','2-3 LPA','5-6 LPA',
        '10-15 LPA','6-8 LPA','8-10 LPA','3-4 LPA','4-5 LPA',
        '5-6 LPA','6-8 LPA','7-9 LPA','5-7 LPA','5-6 LPA',
        '6-8 LPA','7-9 LPA','10-15 LPA','8-10 LPA','3-4 LPA',
        '3-5 LPA','4-5 LPA','7-9 LPA','6-8 LPA','2-3 LPA',
        '3-4 LPA','5-6 LPA','5-7 LPA','8-10 LPA','5-6 LPA',
        '8-10 LPA','15-20 LPA','3-4 LPA','5-6 LPA','2-3 LPA'
    ];
v_states TEXT [] := ARRAY [
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Maharashtra',
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Maharashtra',
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Maharashtra',
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Maharashtra',
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Maharashtra',
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Maharashtra',
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Maharashtra',
        'Karnataka','Karnataka','Karnataka','Karnataka','Karnataka',
        'Telangana','Telangana','Telangana','Telangana','Telangana',
        'Madhya Pradesh','Madhya Pradesh','Madhya Pradesh','Madhya Pradesh','Madhya Pradesh'
    ];
v_districts TEXT [] := ARRAY [
        'Nagpur','Pune','Nagpur','Nagpur','Pune',
        'Amravati','Nagpur','Nashik','Nagpur','Pune',
        'Nagpur','Aurangabad','Nagpur','Kolhapur','Pune',
        'Nagpur','Nagpur','Pune','Yavatmal','Nagpur',
        'Nagpur','Pune','Mumbai','Nashik','Aurangabad',
        'Nagpur','Nagpur','Amravati','Nagpur','Nashik',
        'Nagpur','Pune','Pune','Nagpur','Nagpur',
        'Bangalore Urban','Dharwad','Belgaum','Gulbarga','Bangalore Urban',
        'Hyderabad','Hyderabad','Warangal','Hyderabad','Rangareddy',
        'Bhopal','Indore','Bhopal','Jabalpur','Indore'
    ];
v_talukas TEXT [] := ARRAY [
        'Nagpur','Haveli','Kamptee','Saoner','Khed',
        'Amravati','Hingna','Nashik','Nagpur','Pune City',
        'Katol','Aurangabad','Nagpur','Kolhapur','Baramati',
        'Umred','Parseoni','Mulshi','Yavatmal','Nagpur',
        'Nagpur','Pune City','Andheri','Nashik','Paithan',
        'Ramtek','Nagpur','Achalpur','Nagpur','Igatpuri',
        'Nagpur','Pune City','Pune City','Nagpur','Narkhed',
        'Bangalore South','Dharwad','Belgaum','Gulbarga','Yelahanka',
        'Hyderabad','Secunderabad','Warangal','Kukatpally','Shamshabad',
        'Bhopal','Indore','Huzur','Jabalpur','Mhow'
    ];
v_villages TEXT [] := ARRAY [
        'Dharampeth','Wakad','Kalmeshwar','Saoner Town','Chakan',
        'Badnera','Wadi','Deolali','Sitabuldi','Kothrud',
        'Katol Town','CIDCO','Ramdaspeth','Rankala','Baramati Town',
        'Umred Town','Parseoni Town','Hinjewadi','Yavatmal Town','Mahal',
        'Civil Lines','Shivajinagar','Goregaon','Panchavati','Paithan Town',
        'Ramtek Town','Laxmi Nagar','Achalpur Town','Wardha Road','Igatpuri Town',
        'Manewada','Aundh','Kothrud','Mankapur','Narkhed Town',
        'Jayanagar','Hubli','Belgaum City','Gulbarga City','Yelahanka New Town',
        'Banjara Hills','Ameerpet','Kazipet','Madhapur','Shamshabad Town',
        'Arera Colony','Vijay Nagar','TT Nagar','Napier Town','Mhow Cantonment'
    ];
v_father_names TEXT [] := ARRAY [
        'Rajesh','Sunil','Mohan','Prakash','Ramesh',
        'Vijay','Sanjay','Kishor','Ashok','Bhimrao',
        'Ganesh','Suresh','Dilip','Mahadev','Shivaji',
        'Anil','Balu','Chandrakant','Devendra','Eknath',
        'Firoz','Govind','Hari','Ishwar','Jagdish',
        'Kalyan','Laxman','Mahesh','Narayan','Omkar',
        'Pandit','Raju','Santosh','Tulsiram','Umesh',
        'Vasant','Waman','Yashwant','Zambarlal','Ankush',
        'Balaji','Chandu','Dattatray','Erabadh','Fakir',
        'Gopinath','Hanumant','Indrajit','Jivba','Keshav'
    ];
v_father_occupations TEXT [] := ARRAY [
        'Farmer','Government Job','Business','Teacher','Retired',
        'Shop Owner','Farmer','Driver','Government Job','Business',
        'Farmer','Teacher','Shop Owner','Farmer','Government Job',
        'Business','Farmer','Retired','Teacher','Farmer',
        'Doctor','Government Job','Business','Farmer','Shop Owner',
        'Farmer','Government Job','Business','Teacher','Farmer',
        'Retired','Government Job','Farmer','Business','Teacher',
        'Farmer','Shop Owner','Government Job','Business','Farmer',
        'Teacher','Government Job','Farmer','Business','Retired',
        'Farmer','Government Job','Teacher','Business','Farmer'
    ];
v_mother_names TEXT [] := ARRAY [
        'Savita','Sunanda','Mangala','Pushpa','Radha',
        'Vijaya','Sushila','Kamala','Asha','Bhagirathi',
        'Gangubai','Seema','Durga','Maya','Shobha',
        'Anita','Banu','Chanda','Devki','Eravati',
        'Farida','Godavari','Hema','Indira','Jayashree',
        'Kalawati','Laxmi','Manda','Nirmala','Ojaswini',
        'Parvati','Rukmini','Saroja','Tulsa','Ujwala',
        'Vatsala','Wahida','Yashodha','Zeenat','Aparna',
        'Bharati','Champa','Draupadi','Era','Fulabai',
        'Gauri','Hirabai','Indu','Janaki','Kasturi'
    ];
v_mother_occupations TEXT [] := ARRAY [
        'Homemaker','Homemaker','Homemaker','Teacher','Homemaker',
        'Homemaker','Homemaker','Homemaker','Government Job','Homemaker',
        'Homemaker','Homemaker','Homemaker','Homemaker','Homemaker',
        'Homemaker','Homemaker','Homemaker','Teacher','Homemaker',
        'Homemaker','Homemaker','Homemaker','Homemaker','Homemaker',
        'Anganwadi Worker','Homemaker','Homemaker','Homemaker','Homemaker',
        'Homemaker','Teacher','Homemaker','Homemaker','Homemaker',
        'Homemaker','Homemaker','Homemaker','Homemaker','Homemaker',
        'ASHA Worker','Homemaker','Homemaker','Homemaker','Nurse',
        'Homemaker','Homemaker','Teacher','Homemaker','Homemaker'
    ];
v_about_selfs TEXT [] := ARRAY [
        'I am a simple, family-oriented girl who values traditions and education. I enjoy cooking, reading, and spending time with family.',
        'A confident and career-oriented woman who believes in balancing professional growth with family values. I love traveling and exploring new cuisines.',
        'I am a dedicated teacher who loves working with children. In my free time, I enjoy painting and gardening.',
        'A passionate doctor committed to serving people. I believe in leading a healthy and balanced life.',
        'I am a tech enthusiast who loves coding and problem-solving. I also enjoy yoga and meditation.',
        'A creative soul who loves writing and expressing through words. Family and culture are very important to me.',
        'I am a hardworking and sincere person. I enjoy learning new things and staying updated with current affairs.',
        'A friendly and cheerful person who believes in spreading positivity. My hobbies include dancing and singing.',
        'I am a disciplined pharmacist who values honesty and integrity. I enjoy hiking and nature photography.',
        'A tech-savvy girl who loves building websites. I am also passionate about social work and community service.',
        'I value education and career growth equally. I enjoy classical music and Bharatanatyam dance.',
        'An experienced educator who loves shaping young minds. I believe in continuous learning and self-improvement.',
        'I am a caring and compassionate nurse who loves helping others. I enjoy cooking traditional Banjara recipes.',
        'A detail-oriented banking professional. I love solving financial puzzles and enjoy weekend trekking.',
        'I am an enthusiastic HR professional who believes in creating positive work environments.',
        'A curious journalist who loves uncovering stories. I enjoy reading books and watching documentaries.',
        'I am a dedicated counsellor who helps students achieve their goals. I believe in mental wellness.',
        'A data-driven professional who loves analytics. In my spare time, I enjoy photography and blogging.',
        'I am a passionate primary teacher who loves creating fun learning experiences for children.',
        'An academic at heart who loves research and literature. I enjoy cultural events and festivals.',
        'I am a committed medical professional dedicated to saving lives. I value discipline and compassion.',
        'An engineering graduate who loves innovation. I enjoy painting and exploring historical places.',
        'A dynamic marketing professional. I believe in hard work and smart strategies.',
        'I am a curious researcher who loves science. I also enjoy cooking and trying new recipes.',
        'A focused CA aspirant working hard towards my goal. I love playing badminton in my free time.',
        'I am a healthcare professional passionate about patient care. I enjoy reading and yoga.',
        'An economics enthusiast who loves analyzing market trends. I enjoy teaching and mentoring.',
        'A creative app developer who loves building useful products. I enjoy music and outdoor activities.',
        'I am a dedicated researcher pursuing excellence in physics. I enjoy stargazing and trekking.',
        'An experienced educator committed to quality education. I love gardening and community service.',
        'I am a disciplined government officer who values integrity. I enjoy running and fitness activities.',
        'An innovative engineer who loves solving real-world problems. I enjoy chess and strategy games.',
        'I am a compassionate pediatrician who loves children. I enjoy volunteering and charity work.',
        'A results-oriented operations professional. I believe in efficiency and continuous improvement.',
        'I am a passionate mathematics teacher. I love solving complex problems and enjoy playing chess.',
        'A business-minded person who manages our family shop. I enjoy cooking and festive decorations.',
        'I am interested in history and heritage preservation. I enjoy visiting museums and historical sites.',
        'An aspiring civil engineer working on infrastructure projects. I love sketching buildings and bridges.',
        'I am a creative UX designer who loves making products user-friendly. I enjoy art and craft.',
        'A loving kindergarten teacher who adores children. I enjoy storytelling and puppet shows.',
        'I am passionate about social work and community development. I enjoy volunteering and organizing events.',
        'A healthcare professional dedicated to patient well-being. I enjoy traveling and cultural activities.',
        'I am a thoughtful psychologist who loves understanding human behavior. I enjoy reading novels.',
        'An analytical professional who loves supply chain optimization. I enjoy cooking and gardening.',
        'I am a dedicated ICU nurse who works with commitment. I enjoy singing and dance.',
        'A meticulous chartered accountant who loves numbers. I enjoy painting and weekend hiking.',
        'I am a passionate full-stack developer who loves building scalable applications.',
        'A Sanskrit lover who believes in preserving our cultural heritage through education.',
        'I am a curious microbiologist who loves research. I enjoy nature walks and bird watching.',
        'A tech student who is passionate about learning new programming languages and frameworks.'
    ];
v_expectations TEXT [] := ARRAY [
        'Looking for a well-educated, family-oriented boy from the Banjara community who respects traditions.',
        'Seeking a supportive and understanding life partner who values career growth and family equally.',
        'Want a kind-hearted, sincere boy who respects elders and believes in simple living.',
        'Looking for an educated professional who shares my passion for service and leading a healthy life.',
        'Seeking a technically-minded, progressive partner who supports women empowerment.',
        'Want someone who appreciates creativity and loves family traditions. Should be well-settled.',
        'Looking for an honest, hardworking boy who is focused on career and family responsibilities.',
        'Seeking a cheerful, positive partner who enjoys cultural activities and family gatherings.',
        'Want a nature-loving, adventurous partner who values honesty and has a good sense of humor.',
        'Looking for a tech-savvy partner who also values social service and community development.',
        'Seeking a cultured, well-educated boy who appreciates art, music, and traditions.',
        'Want someone who values education and continuous personal growth. Should be from a good family.',
        'Looking for a compassionate, understanding partner who respects healthcare professionals.',
        'Seeking a financially stable, responsible boy who loves traveling and outdoor activities.',
        'Want a supportive partner who believes in teamwork and creating a happy family environment.',
        'Looking for an intellectually curious partner who loves reading and meaningful conversations.',
        'Seeking a mentally strong, emotionally intelligent partner who supports each other''s growth.',
        'Want a logical thinker who also values emotions and family bonds. Should be well-settled.',
        'Looking for a patient, loving partner who adores children and believes in quality education.',
        'Seeking an academic or professional partner who values culture and heritage.',
        'Want a disciplined, health-conscious partner who leads an active lifestyle.',
        'Looking for an innovative, forward-thinking partner who is also rooted in traditions.',
        'Seeking a dynamic, ambitious boy who believes in hard work and enjoys life.',
        'Want a science-loving partner who is curious about the world and values family.',
        'Looking for a goal-oriented, focused partner who balances work and personal life well.',
        'Seeking a caring, empathetic partner who values healthcare and helping others.',
        'Want someone with strong analytical skills and a kind heart. Should love family.',
        'Looking for a creative, tech-savvy partner who enjoys outdoor activities and music.',
        'Seeking a research-oriented partner who values knowledge and academic excellence.',
        'Want a community-minded partner who believes in giving back to society.',
        'Looking for an honest, principled partner with a stable government or private job.',
        'Seeking a problem-solving partner who enjoys strategy and intellectual discussions.',
        'Want a child-loving, compassionate partner who values health and family well-being.',
        'Looking for an efficient, organized partner who believes in continuous improvement.',
        'Seeking an intelligent, logical partner who also has a creative side.',
        'Want a business-minded or employed partner who values family and traditions.',
        'Looking for a heritage-loving partner who respects culture and intellectual pursuits.',
        'Seeking an infrastructure-minded partner who builds things and loves engineering.',
        'Want a design-thinking partner who values aesthetics and user experience.',
        'Looking for a loving, patient partner who enjoys children and family life.',
        'Seeking a socially responsible partner who believes in making a difference.',
        'Want a healthcare or science professional who travels and experiences life.',
        'Looking for an emotionally intelligent partner who values psychological well-being.',
        'Seeking an organized, systematic partner who loves cooking and family activities.',
        'Want a dedicated, hardworking partner who is also fun-loving and caring.',
        'Looking for a numbers-oriented professional who also appreciates art and nature.',
        'Seeking a tech professional who is passionate about coding and innovation.',
        'Want someone who values Indian culture, Sanskrit, and traditional learning.',
        'Looking for a science enthusiast who loves nature and values research.',
        'Seeking a tech-oriented partner who is ambitious and values learning.'
    ];
v_marital TEXT [] := ARRAY [
        'Never Married','Never Married','Never Married','Never Married','Never Married',
        'Never Married','Never Married','Never Married','Never Married','Never Married',
        'Never Married','Divorced','Never Married','Never Married','Never Married',
        'Never Married','Never Married','Never Married','Never Married','Never Married',
        'Never Married','Never Married','Never Married','Widowed','Never Married',
        'Never Married','Never Married','Never Married','Never Married','Never Married',
        'Divorced','Never Married','Never Married','Never Married','Never Married',
        'Never Married','Never Married','Never Married','Never Married','Never Married',
        'Never Married','Never Married','Never Married','Never Married','Never Married',
        'Never Married','Never Married','Never Married','Never Married','Never Married'
    ];
v_family_types TEXT [] := ARRAY [
        'Nuclear','Joint','Nuclear','Joint','Nuclear',
        'Nuclear','Joint','Nuclear','Nuclear','Joint',
        'Nuclear','Joint','Nuclear','Joint','Nuclear',
        'Joint','Nuclear','Nuclear','Joint','Nuclear',
        'Joint','Nuclear','Nuclear','Joint','Nuclear',
        'Nuclear','Joint','Nuclear','Nuclear','Joint',
        'Joint','Nuclear','Joint','Nuclear','Nuclear',
        'Joint','Nuclear','Nuclear','Joint','Nuclear',
        'Nuclear','Joint','Nuclear','Nuclear','Joint',
        'Nuclear','Nuclear','Joint','Nuclear','Joint'
    ];
v_family_statuses TEXT [] := ARRAY [
        'Middle Class','Upper Middle Class','Middle Class','Upper Middle Class','Middle Class',
        'Middle Class','Middle Class','Middle Class','Upper Middle Class','Upper Middle Class',
        'Upper Middle Class','Middle Class','Middle Class','Middle Class','Upper Middle Class',
        'Middle Class','Middle Class','Upper Middle Class','Middle Class','Middle Class',
        'Upper Middle Class','Upper Middle Class','Upper Middle Class','Middle Class','Middle Class',
        'Middle Class','Upper Middle Class','Middle Class','Upper Middle Class','Middle Class',
        'Upper Middle Class','Upper Middle Class','Upper Middle Class','Upper Middle Class','Middle Class',
        'Middle Class','Middle Class','Upper Middle Class','Upper Middle Class','Middle Class',
        'Middle Class','Middle Class','Middle Class','Upper Middle Class','Middle Class',
        'Upper Middle Class','Upper Middle Class','Middle Class','Middle Class','Middle Class'
    ];
v_siblings_counts INTEGER [] := ARRAY [
        2,1,3,2,1,2,3,1,2,2,
        1,2,3,2,1,2,1,2,3,2,
        1,2,2,3,1,2,2,1,2,3,
        2,1,2,2,3,1,2,2,1,2,
        3,2,1,2,2,1,2,3,2,1
    ];
v_sister_counts INTEGER [] := ARRAY [
        1,0,2,1,0,1,2,0,1,1,
        0,1,2,1,0,1,0,1,2,1,
        0,1,1,2,0,1,1,0,1,2,
        1,0,1,1,2,0,1,1,0,1,
        2,1,0,1,1,0,1,2,1,0
    ];
v_brother_counts INTEGER [] := ARRAY [
        1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1
    ];
v_birth_places TEXT [] := ARRAY [
        'Nagpur','Pune','Kamptee','Nagpur','Chakan',
        'Amravati','Nagpur','Nashik','Nagpur','Pune',
        'Katol','Aurangabad','Nagpur','Kolhapur','Pune',
        'Nagpur','Nagpur','Pune','Yavatmal','Nagpur',
        'Nagpur','Pune','Mumbai','Nashik','Aurangabad',
        'Nagpur','Nagpur','Amravati','Nagpur','Nashik',
        'Nagpur','Pune','Pune','Nagpur','Nagpur',
        'Bangalore','Dharwad','Belgaum','Gulbarga','Bangalore',
        'Hyderabad','Hyderabad','Warangal','Hyderabad','Hyderabad',
        'Bhopal','Indore','Bhopal','Jabalpur','Indore'
    ];
v_birth_times TEXT [] := ARRAY [
        '06:30 AM','09:15 AM','11:45 AM','02:30 PM','05:00 AM',
        '08:20 AM','10:55 AM','01:15 PM','03:45 PM','07:30 AM',
        '12:00 PM','04:20 AM','06:50 AM','09:40 AM','11:30 AM',
        '02:15 PM','05:45 AM','08:00 AM','10:30 AM','01:00 PM',
        '03:30 PM','06:15 AM','09:00 AM','11:20 AM','02:00 PM',
        '04:40 AM','07:10 AM','10:00 AM','12:30 PM','03:00 PM',
        '05:30 AM','08:45 AM','11:00 AM','01:45 PM','04:15 AM',
        '06:45 AM','09:30 AM','12:15 PM','02:45 PM','05:15 AM',
        '07:55 AM','10:20 AM','01:30 PM','03:15 PM','06:00 AM',
        '08:30 AM','11:15 AM','02:00 PM','04:00 AM','07:00 AM'
    ];
v_phone TEXT;
BEGIN FOR i IN 1..50 LOOP v_email := 'fake_girl_' || LPAD(i::TEXT, 2, '0') || '@banjarabio.com';
v_phone := '+91' || (7000000000 + i)::TEXT;
-- Skip if auth user already exists
IF EXISTS (
    SELECT 1
    FROM auth.users
    WHERE email = v_email
) THEN RAISE NOTICE 'User % already exists, skipping...',
v_email;
CONTINUE;
END IF;
-- Create auth user
v_user_id := uuid_generate_v4();
INSERT INTO auth.users (
        id,
        instance_id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    )
VALUES (
        v_user_id,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        v_email,
        crypt('FakePass123!', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}',
        '{}',
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    );
-- Also insert into auth.identities (required by Supabase GoTrue)
INSERT INTO auth.identities (
        id,
        user_id,
        identity_data,
        provider,
        provider_id,
        last_sign_in_at,
        created_at,
        updated_at
    )
VALUES (
        v_user_id,
        v_user_id,
        jsonb_build_object('sub', v_user_id::TEXT, 'email', v_email),
        'email',
        v_user_id::TEXT,
        NOW(),
        NOW(),
        NOW()
    );
-- Create profile
INSERT INTO public.profiles (
        user_id,
        email,
        phone_number,
        full_name,
        surname,
        gotra,
        age,
        date_of_birth,
        gender,
        height,
        complexion,
        blood_group,
        marital_status,
        birth_place,
        birth_time,
        education,
        education_details,
        profession,
        job_details,
        company,
        annual_income,
        state,
        district,
        taluka,
        village,
        current_location,
        permanent_location,
        native_place,
        father_name,
        father_occupation,
        mother_name,
        mother_occupation,
        siblings_count,
        sister_count,
        brother_count,
        siblings_data,
        family_type,
        family_status,
        marriage_readiness,
        about_self,
        partner_expectations,
        expectation,
        is_premium,
        profile_completion,
        is_verified,
        trust_score,
        is_active,
        email_verified,
        phone_verified,
        created_at,
        updated_at
    )
VALUES (
        v_user_id,
        v_email,
        v_phone,
        v_names [i] || ' ' || v_surnames [i],
        v_surnames [i],
        v_gotras [i],
        v_ages [i],
        v_dobs [i],
        'Female',
        v_heights [i],
        v_complexions [i],
        v_blood_groups [i],
        v_marital [i],
        v_birth_places [i],
        v_birth_times [i],
        v_educations [i],
        v_education_details [i],
        v_professions [i],
        v_job_details [i],
        v_companies [i],
        v_annual_incomes [i],
        v_states [i],
        v_districts [i],
        v_talukas [i],
        v_villages [i],
        v_talukas [i] || ', ' || v_districts [i] || ', ' || v_states [i],
        v_villages [i] || ', ' || v_talukas [i] || ', ' || v_districts [i] || ', ' || v_states [i],
        v_villages [i] || ', ' || v_districts [i],
        v_father_names [i] || ' ' || v_surnames [i],
        v_father_occupations [i],
        v_mother_names [i] || ' ' || v_surnames [i],
        v_mother_occupations [i],
        v_siblings_counts [i],
        v_sister_counts [i],
        v_brother_counts [i],
        -- Siblings data: generate based on counts
        CASE
            WHEN v_siblings_counts [i] = 1 THEN '[{"position":1,"relation":"Brother","is_married":false}]'::JSONB
            WHEN v_siblings_counts [i] = 2 THEN '[{"position":1,"relation":"Brother","is_married":false},{"position":2,"relation":"Sister","is_married":true}]'::JSONB
            WHEN v_siblings_counts [i] = 3 THEN '[{"position":1,"relation":"Brother","is_married":true},{"position":2,"relation":"Sister","is_married":false},{"position":3,"relation":"Sister","is_married":true}]'::JSONB
            ELSE '[]'::JSONB
        END,
        v_family_types [i],
        v_family_statuses [i],
        'Ready for marriage',
        v_about_selfs [i],
        v_expectations [i],
        v_expectations [i],
        FALSE,
        -- is_premium
        100,
        -- profile_completion
        TRUE,
        -- is_verified
        85,
        -- trust_score
        TRUE,
        -- is_active
        TRUE,
        -- email_verified (for trust score)
        TRUE,
        -- phone_verified (for trust score)
        NOW() - (i || ' hours')::INTERVAL,
        -- stagger created_at
        NOW()
    )
RETURNING id INTO v_profile_id;
-- Insert a placeholder photo record
INSERT INTO public.photos (
        profile_id,
        storage_path,
        public_url,
        semantic_label,
        is_primary,
        is_approved,
        uploaded_at
    )
VALUES (
        v_profile_id,
        v_user_id::TEXT || '/profile_photo.jpg',
        'https://ui-avatars.com/api/?name=' || v_names [i] || '+' || v_surnames [i] || '&size=512&background=E8395A&color=ffffff&bold=true&format=png',
        'Profile photo of ' || v_names [i] || ' ' || v_surnames [i],
        TRUE,
        TRUE,
        NOW()
    );
RAISE NOTICE 'Created fake profile #% : % %',
i,
v_names [i],
v_surnames [i];
END LOOP;
RAISE NOTICE '✅ All 50 fake girl profiles created successfully!';
END $$;
-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these after the script to verify:
-- 1. Count check
-- SELECT COUNT(*) FROM profiles WHERE email LIKE 'fake_girl_%@banjarabio.com';
-- 2. Completion check (all should be 100)
-- SELECT full_name, profile_completion, is_verified, trust_score
-- FROM profiles WHERE email LIKE 'fake_girl_%@banjarabio.com'
-- ORDER BY created_at;
-- 3. Photo check
-- SELECT p.full_name, ph.public_url
-- FROM profiles p JOIN photos ph ON ph.profile_id = p.id
-- WHERE p.email LIKE 'fake_girl_%@banjarabio.com';
-- =====================================================
-- CLEANUP (removes ALL fake data via CASCADE)
-- =====================================================
-- DELETE FROM auth.users WHERE email LIKE 'fake_girl_%@banjarabio.com';