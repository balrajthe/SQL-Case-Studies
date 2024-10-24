CREATE DATABASE indianelections;
USE indianelections;

CREATE TABLE constituencywise_details(
	SN int,
    Candidate varchar(255),
    Party varchar(255),
    EVM_Votes int,
    Postal_Votes int,
	Total_Votes int,
    PercentofVotes DECIMAL(10,2),
    ConstituencyID varchar(255)
    );

-- Total Seats

SELECT DISTINCT COUNT("Parliament Constituency") AS Total_seats
FROM constituencywise_results;

-- SELECT s.State, COUNT(s.ParliamentConstituency) AS seatcount
-- FROM statewiseresultsnew AS s
-- JOIN states AS c ON s.State = c.State
-- GROUP BY s.State;

-- SELECT sn.StateID, COUNT(ParliamentConstituency) AS seatcount
-- FROM statewiseresultsnew sn
-- JOIN states s ON s.StateID = sn.StateID
-- GROUP BY sn.StateID;

--  What is the total number of seats available for elections in each state

SELECT statewiseresultsnew.StateID,states.State, COUNT(statewiseresultsnew.ParliamentConstituency) AS Total_seats
FROM statewiseresultsnew
JOIN states ON states.StateID = statewiseresultsnew.StateID
GROUP BY statewiseresultsnew.StateID, states.State
ORDER BY states.State;

-- Total seat Won by NDA Allianz
-- Here we need to find then parties that form the NDA and 
-- then we can use Case statement with insert

SELECT SUM( CASE 
			WHEN 
				Party IN (
				'Bharatiya Janata Party - BJP', 
                'Telugu Desam - TDP', 
				'Janata Dal  (United) - JD(U)',
                'Shiv Sena - SHS', 
                'AJSU Party - AJSUP', 
                'Apna Dal (Soneylal) - ADAL', 
                'Asom Gana Parishad - AGP',
                'Hindustani Awam Morcha (Secular) - HAMS', 
				'Janasena Party - JnP', 
				'Janata Dal  (Secular) - JD(S)',
                'Lok Janshakti Party(Ram Vilas) - LJPRV', 
                'Nationalist Congress Party - NCP',
                'Rashtriya Lok Dal - RLD', 
                'Sikkim Krantikari Morcha - SKM') THEN Won
                ELSE 0 END) AS Total_seats_won
FROM partywise_results;

--  Seats Won by NDA Allianz Parties

SELECT
Party, SUM(Won) AS Total_seats
FROM partywise_results
WHERE Party IN (
				'Bharatiya Janata Party - BJP', 
                'Telugu Desam - TDP', 
				'Janata Dal  (United) - JD(U)',
                'Shiv Sena - SHS', 
                'AJSU Party - AJSUP', 
                'Apna Dal (Soneylal) - ADAL', 
                'Asom Gana Parishad - AGP',
                'Hindustani Awam Morcha (Secular) - HAMS', 
				'Janasena Party - JnP', 
				'Janata Dal  (Secular) - JD(S)',
                'Lok Janshakti Party(Ram Vilas) - LJPRV', 
                'Nationalist Congress Party - NCP',
                'Rashtriya Lok Dal - RLD', 
                'Sikkim Krantikari Morcha - SKM')
GROUP BY Party
ORDER BY Total_seats DESC;



 -- Add new column field in table partywise_results to get the Party Allianz as NDA, 
-- I.N.D.I.A and OTHER
-- To add new column we use ALTER (Add, Delete, Modify) command but to
-- Update we use UPDATE for any row item

ALTER TABLE partywise_results
ADD Party_Allianz VARCHAR(50);

UPDATE partywise_results 
SET Party_Allianz = 'N.D.A'
WHERE Party IN (
				'Bharatiya Janata Party - BJP', 
                'Telugu Desam - TDP', 
				'Janata Dal  (United) - JD(U)',
                'Shiv Sena - SHS', 
                'AJSU Party - AJSUP', 
                'Apna Dal (Soneylal) - ADAL', 
                'Asom Gana Parishad - AGP',
                'Hindustani Awam Morcha (Secular) - HAMS', 
				'Janasena Party - JnP', 
				'Janata Dal  (Secular) - JD(S)',
                'Lok Janshakti Party(Ram Vilas) - LJPRV', 
                'Nationalist Congress Party - NCP',
                'Rashtriya Lok Dal - RLD', 
                'Sikkim Krantikari Morcha - SKM');
                
UPDATE partywise_results 
SET Party_Allianz = 'I.N.D.I.A'
WHERE Party IN (
    'Indian National Congress - INC',
    'Aam Aadmi Party - AAAP',
    'All India Trinamool Congress - AITC',
    'Bharat Adivasi Party - BHRTADVSIP',
    'Communist Party of India  (Marxist) - CPI(M)',
    'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
    'Communist Party of India - CPI',
    'Dravida Munnetra Kazhagam - DMK',	
    'Indian Union Muslim League - IUML',
    'Jammu & Kashmir National Conference - JKN',
    'Jharkhand Mukti Morcha - JMM',
    'Kerala Congress - KEC',
    'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
    'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
    'Rashtriya Janata Dal - RJD',
    'Rashtriya Loktantrik Party - RLTP',
    'Revolutionary Socialist Party - RSP',
    'Samajwadi Party - SP'
    'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
    'Viduthalai Chiruthaigal Katchi - VCK'
);

UPDATE partywise_results 
SET Party_Allianz = 'Others'
WHERE Party_Allianz IS NULL;

SELECT Party_Allianz, SUM(Won) AS Total_Seats
FROM partywise_results
GROUP BY Party_Allianz
ORDER BY Total_Seats DESC;

-- Which party alliance (NDA, I.N.D.I.A, or OTHER) won the most seats across all states?
-- I am assuming here that partywise results table doesnot have Party_AllianZ column

SELECT cr.Party_Allianz, COUNT(cr.ConstituencyID)
FROM constituencywise_results as cr
JOIN partywise_results AS pr ON pr.PartyID = cr.PartyID
GROUP BY cr.Party_Allianz;

-- In this I am tryimg tp create a New Column in the constituencywise_results table

-- UPDATE constituencywise_results
-- SET Party_Allianz = 
-- FROM 


UPDATE constituencywise_results AS cr
JOIN partywise_results AS pr ON cr.PartyID = pr.PartyID
SET cr.Party_Allianz = pr.Party_Allianz;

-- Winning candidate's name, their party name, total votes, and the margin of 
-- victory for a specific state and constituency?

-- constituencywise_results AS cr, Winning Candidate,PartyID, TotalVotes,Margin, 
-- ParliamentConstituency
-- partywise_results AS pr, Party, PartyID
-- statewiseresultsnew AS sr, ParliamentConstituency

SELECT cr.WinningCandidate,pr.Party,cr.TotalVotes,cr.Margin,s.State,cr.Party_Allianz,cr.ConstituencyName
FROM constituencywise_results AS cr
JOIN statewiseresultsnew AS sr ON 
	sr.ParliamentConstituency = cr.ParliamentConstituency
JOIN partywise_results AS pr ON cr.PartyID = pr.PartyID
JOIN states s ON s.StateID = sr.StateID;



-- What is the distribution of EVM votes versus postal votes 
-- in a specific constituency?


SELECT cr.ConstituencyName,SUM(EVMVotes) as EVM, SUM(PostalVotes) as 'Postal', SUM(EVMVotes + PostalVotes) as 'Total',
		SUM(EVMVotes)/SUM(EVMVotes + PostalVotes)*100 AS 'EVMShare', 
        SUM(PostalVotes)/SUM(EVMVotes + PostalVotes)*100 AS 'PostalShare'
FROM constituencywise_details1 cd
JOIN constituencywise_results cr ON cr.ConstituencyID = cd.ConstituencyID
GROUP BY cr.ConstituencyName, cr.ConstituencyID;


-- What is the distribution of EVM votes versus postal votes for candidates 
-- in a specific constituency?

SELECT cd.Candidate,cd.Party,cd.EVMVotes as EVM, cd.PostalVotes as 'Postal',cr.ConstituencyName
-- 		SUM(EVMVotes)/SUM(EVMVotes + PostalVotes)*100 AS 'EVMShare', 
--        SUM(PostalVotes)/SUM(EVMVotes + PostalVotes)*100 AS 'PostalShare'
FROM constituencywise_details1 cd
JOIN constituencywise_results cr ON cr.ConstituencyID = cd.ConstituencyID
-- GROUP BY cr.ConstituencyName, cr.ConstituencyID
WHERE cr.ConstituencyName = 'MATHURA'
ORDER BY cd.EVMVotes DESC;


-- Which parties won the most seats in s State, and how many seats did each party win?

SELECT s.State, pr.Party, COUNT(pr.Won)
FROM constituencywise_results cr
JOIN partywise_results pr ON cr.PartyID = pr.PartyID
JOIN statewiseresultsnew sr ON cr.ParliamentConstituency = sr.ParliamentConstituency
JOIN states s ON s.StateID = sr.StateID
WHERE s.State = 'Kerala'
GROUP BY s.State,pr.Party
ORDER BY COUNT(pr.Won) DESC;

-- What is the total number of seats won by each party alliance 
-- (NDA, I.N.D.I.A, and OTHER) in a state(Selected) for the India Elections 2024


SELECT s.State, COUNT(pr.Won),pr.Party_Allianz
FROM constituencywise_results cr
JOIN partywise_results pr ON cr.PartyID = pr.PartyID
JOIN statewiseresultsnew sr ON cr.ParliamentConstituency = sr.ParliamentConstituency
JOIN states s ON s.StateID = sr.StateID
WHERE s.State = 'Kerala'
GROUP BY s.State,pr.Party_Allianz
ORDER BY COUNT(pr.Won) DESC;

-- What is the total number of seats won by each party alliance 
-- (NDA, I.N.D.I.A, and OTHER) in each state for the India Elections 2024

SELECT s.State,
SUM(CASE WHEN pr.Party_Allianz = "I.N.D.I.A" THEN 1 ELSE 0 END) AS "INDIA_COUNT",
SUM(CASE WHEN pr.Party_Allianz = "N.D.A" THEN 1 ELSE 0 END) AS "NDA_COUNT",
SUM(CASE WHEN pr.Party_Allianz = "Others" THEN 1 ELSE 0 END) AS "OTHERS_COUNT"
FROM constituencywise_results cr
JOIN partywise_results pr ON cr.PartyID = pr.PartyID
JOIN statewiseresultsnew sr ON cr.ParliamentConstituency = sr.ParliamentConstituency
JOIN states s ON s.StateID = sr.StateID
GROUP BY s.State
ORDER BY s.State;

-- Which candidate received the highest number of EVM votes in each constituency (Top 10)?

SELECT cd.Candidate,cd.Party,cd.EVMVotes as EVM, cd.PostalVotes as 'Postal',cr.ConstituencyName
FROM constituencywise_details1 cd
JOIN constituencywise_results cr ON cr.ConstituencyID = cd.ConstituencyID
WHERE cr.ConstituencyName = 'MATHURA'
ORDER BY cd.EVMVotes DESC;


-- Which candidate received the highest number of EVM votes in each constituency (Top 10)?
SELECT * FROM constituencywise_details1;

WITH ranked_table AS (SELECT *, 
						ROW_NUMBER() OVER(PARTITION BY ConstituencyID ORDER BY EVMVotes DESC) AS "Rankwithin"
						FROM constituencywise_details1)
SELECT cr.ConstituencyName,rt.Candidate,rt.EVMVotes FROM ranked_table rt
JOIN constituencywise_results cr ON cr.ConstituencyID = rt.ConstituencyID
WHERE rt.Rankwithin = 1

ORDER BY rt.EVMVotes DESC
;


-- Which candidate won and which candidate was the runner-up in each constituency of State for the 2024 elections?

USE indianelections;

SELECT  Constituency,LeadingCandidate AS "Winning_Can", TrailingCandidate AS "Runner_up"
FROM statewiseresultsnew
WHERE Constituency = "jalna";


WITH RankedCandidates AS (
    SELECT 
        cd.ConstituencyID,
        cd.Candidate,
        cd.Party,
        cd.EVMVotes,
        cd.PostalVotes,
        cd.EVMVotes + cd.PostalVotes AS TotalVotes,
        ROW_NUMBER() OVER (PARTITION BY cd.ConstituencyID ORDER BY cd.EVMVotes + cd.PostalVotes DESC) AS VoteRank
    FROM 
        constituencywise_details1 cd
    JOIN 
        constituencywise_results cr ON cd.ConstituencyID = cr.ConstituencyID
    JOIN 
        statewiseresultsnew sr ON cr.ParliamentConstituency = sr.ParliamentConstituency
    JOIN 
        states s ON sr.StateID = s.StateID
    WHERE 
        s.State = 'Maharashtra'
)

SELECT 
    cr.ConstituencyName,
    MAX(CASE WHEN rc.VoteRank = 1 THEN rc.Candidate END) AS Winning_Candidate,
    MAX(CASE WHEN rc.VoteRank = 2 THEN rc.Candidate END) AS Runnerup_Candidate
FROM 
    RankedCandidates rc
JOIN 
    constituencywise_results cr ON rc.ConstituencyID = cr.ConstituencyID
GROUP BY 
    cr.ConstituencyName
ORDER BY 
    cr.ConstituencyName;

-- For the state of Maharashtra, what are the total number of seats, total number of candidates, total number of parties, total votes (including EVM and postal), and the breakdown of EVM and postal votes?

SELECT 
    COUNT(DISTINCT cr.Constituency_ID) AS Total_Seats,
    COUNT(DISTINCT cd.Candidate) AS Total_Candidates,
    COUNT(DISTINCT p.Party) AS Total_Parties,
    SUM(cd.EVM_Votes + cd.Postal_Votes) AS Total_Votes,
    SUM(cd.EVM_Votes) AS Total_EVM_Votes,
    SUM(cd.Postal_Votes) AS Total_Postal_Votes
FROM 
    constituencywise_results cr
JOIN 
    constituencywise_details cd ON cr.Constituency_ID = cd.Constituency_ID
JOIN 
    statewise_results sr ON cr.Parliament_Constituency = sr.Parliament_Constituency
JOIN 
    states s ON sr.State_ID = s.State_ID
JOIN 
    partywise_results p ON cr.Party_ID = p.Party_ID
WHERE 
    s.State = 'Maharashtra';









