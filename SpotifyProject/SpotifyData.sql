--EDA
SELECT *
FROM Spotify;

SELECT COUNT(DISTINCT(Artist))
FROM Spotify;

SELECT COUNT(DISTINCT(Track))
FROM Spotify;

SELECT DISTINCT(Album_type)
FROM Spotify;

SELECT MAX(Duration_min)
FROM Spotify;
SELECT MIN(Duration_min)
FROM Spotify;

SELECT *
FROM Spotify
WHERE Duration_min < 1;

SELECT COUNT(DISTINCT(Channel))
FROM Spotify;


--Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track, title, stream
FROM Spotify
WHERE Stream > 1000000000
ORDER BY stream DESC;


--List all albums along with their respective artists.
SELECT artist, COUNT(album) AS total_album
FROM Spotify
GROUP BY Artist
ORDER BY total_album DESC;

SELECT DISTINCT album, Artist
FROM Spotify
ORDER BY Artist ASC;

--Get the total number of comments for tracks where licensed = TRUE.
SELECT track, SUM(comments) as Total_comments
FROM Spotify
WHERE licensed = 'True'
GROUP BY track
ORDER BY Total_comments DESC;

SELECT SUM(comments) as Total_comments
FROM Spotify
WHERE licensed = 'True';

--Find all tracks that belong to the album type single.
SELECT *
FROM Spotify
WHERE album_type = 'single';

--Count the total number of tracks by each artist.
SELECT artist, COUNT(track) total_track
FROM Spotify
GROUP BY artist
ORDER BY 2 DESC;

--Calculate the average danceability of tracks in each album.
SELECT album, ROUND(AVG(danceability),3) avg_danceabilty 
FROM Spotify
GROUP BY album
ORDER BY 2 DESC;

--Find the top 5 tracks with the highest energy values.
SELECT TOP 5 track, ROUND(MAX(energy),3) as Highest_energy
FROM Spotify
GROUP BY track
ORDER BY 2 DESC;

--List all tracks along with their views and likes where official_video = TRUE.
SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes
FROM Spotify
WHERE official_video = 'True'
GROUP BY track
ORDER BY 2 DESC;

--For each album, calculate the total views of all associated tracks.
SELECT album, track, SUM(views) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY 3 DESC;

--Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT *
FROM
(SELECT 
    track,
    SUM(CASE WHEN most_playedon = 'Youtube' THEN stream ELSE 0 END) AS streamed_on_youtube,
    SUM(CASE WHEN most_playedon = 'Spotify' THEN stream ELSE 0 END) AS streamed_on_spotify
FROM 
    Spotify
GROUP BY 
    track)
	as T1
	WHERE streamed_on_spotify>streamed_on_youtube
	AND streamed_on_youtube <> 0;

SELECT track, stream, most_playedon
FROM Spotify
WHERE most_playedon = 'Spotify'
ORDER BY 2 DESC;


--Find the top 3 most-viewed tracks for each artist using window functions. 
WITH ranking_artist
AS(
SELECT artist, track, SUM(views) AS totalviews,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM Spotify
GROUP BY artist, track)
SELECT * FROM ranking_artist 
WHERE rank <=3;


--Write a query to find tracks where the liveness score is above the average.
SELECT track, artist, liveness
FROM Spotify
WHERE liveness > (SELECT AVG(liveness) as livenessavg FROM Spotify)
ORDER BY liveness DESC;

--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH maxandmin AS
(
SELECT album, MAX(energy) AS highest, MIN(energy) AS lowest
FROM Spotify
GROUP BY album)
SELECT album, highest - lowest AS differenceenergy
FROM maxandmin
ORDER BY differenceenergy DESC;

-- Query optimization

CREATE INDEX artist_index ON spotify (artist);