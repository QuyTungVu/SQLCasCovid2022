/*
Covid 19 Data Exploration
*/

-- Select CovidDeaths Data 
SELECT *
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
ORDER BY 3,4

-- Select Data will be used to explore
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL -- Focus on city location data
ORDER BY location, date

-- Total Cases vs Total Deaths
-- Shows likelihood of dying (in percentage) if you contact covid in France
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
WHERE location = 'France'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
WHERE location = 'France'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
-- France is in 13th position

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
-- France is in 11th position




-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
-- Europe is in 4/6 position



-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCaseCount, SUM(CAST(new_deaths AS int)) AS TotalDeathCount, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Covid Timeseries Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS -- CTE
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Covid Timeseries Project].[dbo].[CovidDeaths] dea
JOIN [Covid Timeseries Project].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
FROM PopvsVac
ORDER BY 2,3



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Covid Timeseries Project].[dbo].[CovidDeaths] dea
JOIN [Covid Timeseries Project].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3


-- Creating View to store data for later visualizations
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Covid Timeseries Project].[dbo].[CovidDeaths] dea
JOIN [Covid Timeseries Project].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

