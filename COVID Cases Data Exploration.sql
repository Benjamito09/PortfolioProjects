
-- Exploring the data of the COVID-19 Pandemic during its peak, between 01/01/2020 and 04/30/2021


SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking at the total cases compared to the population overall
-- This query shows the percentage of the population that contracted COVID-19 (The comment was to take a peek at the U.S. specifically)


SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;


-- Looking at the countries with the highest infection rate compared to the population


SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
(MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PopulationPercentageInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PopulationPercentageInfected DESC;


-- Looking at the amount of deaths per total cases reported
-- This query looks into the percentage of people in the U.S. who passed away after contracting the virus (or in this case, the likelihood) of passing away 


SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;


-- Breaking down by continent
-- This query shows the continents with the highest death counts


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
OR continent = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Breaking down by country
-- This query shows the countries with the highest death counts


SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc;


-- Breaking down Asia
-- This query looked at the death counts of the different countries in Asia, where the COVID-19 virus is thought to have originated from


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent = 'Asia'
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- Using a CTE to perform a calculation on the "Partition By" from the previous query


With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


-- This query uses a temporary table to perform a calculation on the "Partition By" from the previous query


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


-- Created a view to store the data for visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dboCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;