SELECT *
FROM CovidDeaths;

SELECT *
FROM CovidVaccinations;


--Select the data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

--Total cases vs total deaths
SELECT Location, date, total_cases, total_deaths,
	CASE 
        WHEN total_cases > 0 THEN (CAST(total_deaths AS FLOAT) / total_cases) * 100 
        ELSE NULL 
    END AS DeathPercentage
FROM 
    CovidDeaths
WHERE location LIKE '%states%';

--Total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_cases
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY population_cases DESC;

--Country with the most hightest infection rate
SELECT location, population, MAX(total_cases) AS HighestTotalCase, MAX((total_cases/population))*100 AS population_cases
FROM CovidDeaths
GROUP BY location, population
ORDER BY population_cases DESC;

--People how died for Covid-19 by country
SELECT location, population, MAX(total_deaths) AS HighestTotalDeaths,  MAX((total_deaths/population))*100 AS deathcasesperpopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY deathcasesperpopulation DESC;

SELECT location, population, MAX(total_deaths) AS HighestTotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestTotalDeaths DESC;

--People how died for Covid-19 by continent
SELECT continent, SUM(population) AS populations, MAX(total_deaths) AS HighestTotalDeaths,  MAX((total_deaths/population))*100 AS deathcasesperpopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY deathcasesperpopulation DESC;

SELECT continent, MAX(total_deaths) AS HighestTotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeaths DESC;

--Continents with the highest death count per population
SELECT continent, MAX((total_deaths)/population)*100 as DeathPerPopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPerPopulation DESC;

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
ORDER BY 1;

--total data
SELECT *
FROM CovidVaccinations;

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, newVaccinations)
AS
(
--Total population vs vaccinations
SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
	V.new_vaccinations,
    SUM(CAST(V.new_vaccinations AS FLOAT)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS newVaccinations
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location 
	AND D.date = V.date
WHERE D.continent IS NOT NULL
)
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT *, (newVaccinations/population)*100 AS percentajePeopleWithVaccine
FROM PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentajePopulationVaccinated
CREATE TABLE #PercentajePopulationVaccinated
	(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
newVaccinations numeric,
)

INSERT INTO #PercentajePopulationVaccinated
SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
	V.new_vaccinations,
    SUM(CAST(V.new_vaccinations AS FLOAT)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS newVaccinations
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location 
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *, (newVaccinations/population)*100 AS percentajePeopleWithVaccine
FROM #PercentajePopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
	V.new_vaccinations,
    SUM(CAST(V.new_vaccinations AS FLOAT)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS newVaccinations
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.location = V.location 
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;