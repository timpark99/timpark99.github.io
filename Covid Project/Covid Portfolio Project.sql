-- ORDER BY 3,4 will order first by column 3 then column 4 in ascending order
-- must add WHERE continent IS NOT NULL because in the data, there are points where continent is null but the location is listed as the continent.  To avoid continents listed as locations, add this clause.
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- SELECT Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- looking at Total Cases vs. Total Deaths
-- shows likelihood of dying if you contract covid in your country
-- must cast as float in order to get a decimal value
-- WHERE clause captures United States as location
-- AS represents an alias

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%' AND
    continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%states%' AND
    continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
-- DESC is highest number first

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Adding date
-- filter only dates before or equal to 2021-04-30

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL AND date <= Convert(datetime, '2021-04-30')
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

-- Showing countries with Highest Death Count per Population
-- must cast because it's an nvarchar

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
   AND location NOT IN ('World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

-- Showing total cases, deaths and death percentage by day

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS float))/SUM(cast(new_cases AS int))*100 AS DeathPercentage--total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' AND
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Showing total cases, total deaths and total death percentage of the world

SELECT SUM(new_cases) AS total_cases, SUM(CONVERT(int,new_deaths)) AS total_deaths, SUM(cast(new_deaths AS float))/SUM(cast(new_cases AS int))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' AND
WHERE continent IS NOT NULL
--Group By date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
    dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
    dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (CAST(RollingPeopleVaccinated AS float)/Population)*100 AS PercentVaccinated
FROM PopvsVac

-- TEMP TABLE
-- Include DROP TABLE at the top in case you want to make any edits, otherwise error message will show a table already exists
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
    dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (CAST(RollingPeopleVaccinated AS float)/Population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
    dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated