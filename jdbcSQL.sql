SET search_path TO A2;

-- If you define any views for a question (you are encouraged to), you must drop them
-- after you have populated the answer table for that question.
-- Good Luck!

-- Query 1 --------------------------------------------------
CREATE VIEW Classified_player AS
(SELECT id, email, playername, 100 AS classification
FROM PlayerRatings JOIN Player ON Player.id = PlayerRatings.p_id
WHERE PlayerRatings.monthly_rating > 0
GROUP BY id, email, playername
HAVING avg(rolls) > 99)
UNION
(SELECT p_id AS id, email, playername, 10 AS classification
FROM Lilmon, LilmonInventory, Player
WHERE Player.id = LilmonInventory.p_id
    AND Lilmon.id = LilmonInventory.l_id
    AND Lilmon.rarity = 5
GROUP BY LilmonInventory.p_id, email, playername, Player.rolls
HAVING count(LilmonInventory.id) > 0.05 * Player.rolls)
UNION
(SELECT id, email, playername, 1 AS classification
FROM PlayerRatings JOIN Player ON Player.id = PlayerRatings.p_id
WHERE PlayerRatings.monthly_rating > 0
GROUP BY p_id, email, playername
HAVING avg(coins) > 9999)

CREATE VIEW All_player AS
SELECT id AS p_id, email, playername, sum(coalesce(classification, 0))
FROM Player LEFT JOIN Classified_player ON Player.id = Classified_player.id
GROUP BY id, email, playername;


INSERT INTO Query1 (SELECT id, email, playername, (case classificatioin
                                                   when 0 then '--'
                                                   when 1 then '--hoarder'
                                                   when 10 then '-lucky-'
                                                   when 11 then '-lucky-hoarder'
                                                   when 100 then 'whale--' 
                                                   when 101 then 'whale--hoarder'
                                                   when 110 then 'whale-lucky-'
                                                   when 111 then 'whale-lucky-hoarder'
                                                end) 
                    FROM All_player
                    ORDER BY id);

DROP VIEW Classified_player;
DROP VIEW All_player;
-- Query 2 --------------------------------------------------
CREATE VIEW Distinct_pairs AS 
SELECT DISTINCT l_id, p_id
FROM LilmonInventory
WHERE in_team = true OR fav = true

CREATE VIEW Populatiry AS
(SELECT 'Water' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Water' OR element2 = 'Water';)
UNION
(SELECT 'Fire' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Fire' OR element2 = 'Fire';)
UNION
(SELECT 'Air' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Air' OR element2 = 'Air';)
UNION
(SELECT 'Earth' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Earthr' OR element2 = 'Earth';)
UNION
(SELECT 'Ice' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Ice' OR element2 = 'Ice';)
UNION
(SELECT 'Electric' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Electric' OR element2 = 'Electric';)
UNION
(SELECT 'Light' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Light' OR element2 = 'Light';)
UNION
(SELECT 'Dark' AS element, count(*) AS popularity_count
FROM Lilmon JOIN Distinct_pairs ON Lilmon.id = Distinct_pairs.l_id
WHERE element1 = 'Dark' OR element2 = 'Dark';)


INSERT INTO Query2 (SELECT * FROM Populatiry ORDER BY popularity_count DESC);

DROP VIEW Distinct_pairs;
DROP VIEW Populatiry;

-- Query 3 --------------------------------------------------
CREATE VIEW Active AS
(SELECT p_id, count(PlayerRatings.id) AS active_months
FROM Player JOIN PlayerRatings ON player.id = PlayerRatings.p_id
WHERE PlayerRatings.monthly_rating > 0
GROUP BY p_id)
UNION
(SELECT p_id, 1 AS active_months
FROM Player LEFT JOIN PlayerRatings ON player.id = PlayerRatings.p_id
WHERE PlayerRatings.monthly_rating = null)
UNION 
(SELECT p_id, 1 AS active_months
FROM Player JOIN PlayerRatings ON player.id = PlayerRatings.p_id
GROUP BY p_id
HAVING max(monthly_rating = 0)

CREATE VIEW Incomplete AS
SELECT p_id, total_battles-wins-losses AS incomplete_battles
FROM Player;

CREATE VIEW Avg_complete AS
SELECT incomplete_battles/active_months AS avg_incomplete
FROM Active JOIN Incomplete ON Active.p_id = Incomplete.p_id;

INSERT INTO Query3(SELECT  avg(*) AS avg_ig_per_month_per_player FROM Avg_complete)

DROP VIEW Active;
DROP VIEW Incomplete;
DROP VIEW Avg_complete;
-- Query 4 --------------------------------------------------
CREATE VIEW Distinct_pairs AS 
SELECT DISTINCT l_id, p_id
FROM LilmonInventory
WHERE in_team = true OR fav = true

INSERT INTO Query4(SELECT l_id AS id, name, rarity, count(Distinct_pairs.p_id) AS popularity_count
                   FROM Distinct_pairs JOIN Lilmon ON Distinct_pairs.l_id = Lilmon.id
                   GROUP BY Lilmon.id, name, rarity
                   ORDER BY popularity_count DESC, rarity DESC, l_id DESC);

DROP VIEW Distinct_pairs;
-- Query 5 --------------------------------------------------
CREATE VIEW Latest_six_month AS 
SELECT *, row_number() OVER(PARTITION BY p_id ORDER BY year DESC, month DESC) rn
FROM PlayerRatings
WHERE rn <7;

INSERT INTO Query5 (SELECT p_id, playername, email, min(monthly_rating) AS min_mr , max(monthly_rating) AS max_mr
                    FROM Latest_six_month JOIN Player ON Latest_six_month.p_id = Player.id
                    WHERE Player.country_code = 'USA' OR Player.country_code = 'MEX' OR Player.country_code = 'CAN'
                    GROUP BY p_id, playername, email
                    HAVING max(monthly_rating) - min(monthly_rating) < 50 AND max(all_time_rating) >= 2000
                    ORDER BY max_mr DESC, min_mr DESC, p_id);

DROP VIEW Lastest_six_month;
-- Query 6 --------------------------------------------------
CREATE VIEW Guild_with_rate AS
SELECT g_id, all_time_rating, row_number() OVER(PARTITION BY p_id ORDER BY year DESC, month DESC) rn
FROM GuildRatings
WHERE rn = 1;

CREATE VIEW Guild_with_size AS
SELECT g_id, (case 
                when (members>499) then 'large'
                When (members>99) then 'medium'
                when (members>0) then 'small'
              end) AS size
FROM (SELECT guild AS g_id, count(id) AS members FROM Player GROUP BY guild);

CREATE VIEW Classified_guild AS 
(SELECT g_id, all_time_rating, size, (case 
                                        when (size = 'large' AND all_time_rating>1999) then 'elite'
                                        when (size = 'large' AND all_time_rating>1499) then 'average'
                                        when (size = 'large' AND all_time_rating>0) then 'casual'
                                        when (size = 'medium' AND all_time_rating>1749) then 'elite'
                                        when (size = 'medium' AND all_time_rating>1249) then 'average'
                                        when (size = 'medium' AND all_time_rating>0) then 'casual'
                                        when (size = 'small' AND all_time_rating>1499) then 'elite'
                                        when (size = 'small' AND all_time_rating>999) then 'elite'
                                        when (size = 'small' AND all_time_rating>0) then 'elite'
                                        else 'new'
                                    end) AS classification
FROM Guild_with_size s LEFT JOIN Guild_with_rate r  ON r.g_id = s.g_id)


INSERT INTO Query6 (SELECT g_id, guildname, tag, leader AS leader_id, playername AS leader_name, country_code AS leader_country, size, classification
                    FROM Guild, Classified_guild, Player
                    WHERE Guild.id = Classified_guild.g_id
                        AND Guild.leader = Player.id
                    ORDER BY g_id);

DROP VIEW Guild_with_rate;
DROP VIEW Guild_with_size;
DROP VIEW Classified_guild;
-- Query 7 --------------------------------------------------
INSERT INTO Query7 (SELECT country_code, avg(active_month) AS player_retention 
                    FROM (SELECT p_id, count(id) AS active_month
                          FROM PlayerRating
                          WHERE monthly_rating > 0
                          GROUP BY p_id) p JOIN Player ON Player.id = p.p_id
                    GROUP BY country_code
                    ORDER BY player_retention DESC)

-- Query 8 --------------------------------------------------
CREATE VIEW Player_with_wr AS
SELECT id, playername, wins/(wins + losses) AS player_wr, guild
FROM Player;

CREATE VIEW Guild_with_wr AS
SELECT guild AS g_id, sum(wins)/(sum(wins) + sum(lossws)) AS guild_aggregate_wr
FROM Player
GROUP BY guild;

INSERT INTO Query8 (SELECT p.id AS p_id, playername, player_wr, g_id, guildname, tag, guild_aggregate_wr
                    FROM Player_with_wr p, Guild_with_wr g, Guild
                    WHERE p.guild = g.g_id AND g.g_id = Guild.id
                    ORDER BY player_wr DESC, guild_aggregate_wr DESC)

DROP VIEW Player_with_wr;
DROP VIEW Guild_with_wr;
-- Query 9 --------------------------------------------------
CREATE VIEW Top_ten AS
SELECT g_id, all_time_rating, monthly_rating
FROM (SELECT g_id, monthly_rating, all_time_rating, row_number() OVER(PARTITION BY p_id ORDER BY year DESC, month DESC) rn
      FROM GuildRatings
      WHERE rn = 1)
ORDER BY all_time_rating DESC, monthly_rating DESC, g_id
LIMIT 10;

CREATE VIEW Guild_with_total AS
SELECT g_id, count(Player.id) AS total_pcount
FROM Top_ten JOIN Player ON g_id = guild
GROUP BY g_id;

CREATE VIEW Guild_with_country AS
SELECT g_id, count(Player.id) AS country_pcount, country_code
FROM Top_ten JOIN Player ON g_id = guild
GROUP BY g_id, country_code;

CREATE VIEW Most_freq_country AS
SELECT g_id, country_code, country_pcount
FROM Guild_with_country g JOIN (SELECT g_id, max(country_pcount) AS country_pcount, country_code
                                FROM Guild_with_country
                                GROUP BY g_id, country_code) m 
                          ON g.g_id = m.g_id, g,country_pcount = m.country_pcount, g.country_code = m.country_code;

INSERT INTO Query9 (SELECT Top_ten.g_id, guildname, monthly_rating, all_time_rating, country_pcount, total_pcount, country_code
                    FROM Guild, Most_freq_country, Guild_with_total, Top_ten
                    WHERE Guild.id = Most_freq_country.g_id
                        AND Guild.id = Guild_with_total.g_id
                        And Guild.id = Top_ten.g_id
                    ORDER BY all_time_rating DESC, monthly_rating DESC, Top_ten.g_id);

DROP VIEW Top_ten;
DROP VIEW Guild_with_total;
DROP VIEW Guild_with_country;
DROP VIEW Most_freq_country;
-- Query 10 --------------------------------------------------
CREATE VIEW Guild_veteranness AS
SELECT avg(v.veteran_ness) AS avg_veteranness, guild
FROM Player JOIN (SELECT count(id)/12 AS veteran_ness, p_id
                  FROM PlayerRatings
                  GROUP BY p_id) v ON Player.id = v.p_id 
GROUP BY guild;

INSERT INTO Query10 (SELECT Guild.id AS g_id, guildname, avg_veteranness
                     FROM Guild JOIN Guild_veteranness g ON Guild.id = g.guild
                     ORDER BY avg_veteranness DESC, g_id);

DROP VIEW Guild_veteranness;