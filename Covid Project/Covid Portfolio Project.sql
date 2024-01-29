Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

/* Select *
From PortfolioProject..CovidVaccinations
order by 3,4 */

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' AND
    continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%' AND
    continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

-- Showing total cases, deaths and death percentage by day

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as int))*100 as DeathPercentage--total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%' AND
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Showing total cases, total deaths and total death percentage of the world

SELECT SUM(new_cases) AS total_cases, SUM(CONVERT(int,new_deaths)) AS total_deaths, SUM(cast(new_deaths AS float))/SUM(cast(new_cases AS int))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%' AND
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